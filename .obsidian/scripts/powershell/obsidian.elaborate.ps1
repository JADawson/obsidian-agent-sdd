#requires -Version 5.1
param(
    [Parameter(Mandatory)][string]$SelectedPath,
    [switch]$DryRun = $true,
    [switch]$Approve
)

$ErrorActionPreference = 'Stop'
Import-Module -Name "$PSScriptRoot/helpers.psm1" -Force

function Resolve-SelectedPath {
    param([string]$Path)
    if (Test-Path -LiteralPath $Path) { return (Resolve-Path -LiteralPath $Path | Select-Object -ExpandProperty Path) }
    $root = Get-VaultRoot
    $p2 = Join-Path -Path $root -ChildPath $Path
    if (Test-Path -LiteralPath $p2) { return (Resolve-Path -LiteralPath $p2 | Select-Object -ExpandProperty Path) }
    if ($Path -match '^(?i)vault\\(.*)$') {
        $rel = $Matches[1]
        $p3 = Join-Path -Path $root -ChildPath $rel
        if (Test-Path -LiteralPath $p3) { return (Resolve-Path -LiteralPath $p3 | Select-Object -ExpandProperty Path) }
    }
    throw "SelectedPath not found: $Path"
}

function Get-FrontmatterBounds {
    param([string]$Content)
    $lines = $Content -split "`r?`n"
    $start = -1; $end = -1
    for ($i=0; $i -lt $lines.Length; $i++) {
        if ($lines[$i].Trim() -eq '---') { if ($start -eq -1) { $start = $i } else { $end = $i; break } }
    }
    if ($start -eq -1 -or $end -eq -1 -or $end -le $start) { throw 'Frontmatter (---) block not found' }
    return @{ Start=$start; End=$end; Lines=$lines }
}

function Ensure-Sections {
    param(
        [string]$Content,
        [string]$Type,
        [ref]$Questions
    )
    $lines = $Content -split "`r?`n"
    $changed = $false
    $qList = @()

    function Add-HeadingIfMissing {
        param([string]$Title, [string[]]$Body)
        $pattern = "^(?i)##\s+" + [regex]::Escape($Title) + "\s*$"
        $exists = ($lines | Select-String -Pattern $pattern | Measure-Object).Count -gt 0
        if (-not $exists) {
            if ($lines.Count -gt 0 -and $lines[-1] -ne '') { $lines += '' }
            $lines += "## $Title"
            foreach ($b in $Body) { $lines += $b }
            $changed = $true
        }
    }

    if ($Type -eq 'idea') {
        Add-HeadingIfMissing -Title 'Problem' -Body @('', '<What problem are you trying to solve?>','')
        Add-HeadingIfMissing -Title 'Context' -Body @('', '<Relevant background, where/when this applies>','')
        Add-HeadingIfMissing -Title 'Related Areas' -Body @('', '- <Area>','')
        Add-HeadingIfMissing -Title 'Candidate Projects' -Body @('', '- [[<Project>]]','')
        $qList += @{ type='short'; question='Provide Problem summary'; suggested='<=5 words' }
        $qList += @{ type='short'; question='One related Area?'; suggested='[[<Area>]]' }
        $qList += @{ type='short'; question='One candidate Project?'; suggested='[[<Project>]]' }
    }
    elseif ($Type -eq 'project') {
        Add-HeadingIfMissing -Title 'Scope' -Body @('', '<What is in scope>','')
        Add-HeadingIfMissing -Title 'Phases' -Body @('', '- Phase 1: <>','- Phase 2: <>','')
        $qList += @{ type='short'; question='Provide Scope summary'; suggested='<=5 words' }
    }

    $Questions.Value = $qList
    return @{ Changed=$changed; Content=([string]::Join("`r`n", $lines)) }
}

# 1) Resolve and load
$notePath = Resolve-SelectedPath -Path $SelectedPath
$content = Get-Content -LiteralPath $notePath -Raw

# 2) Determine type from frontmatter and update updated date
$bounds = Get-FrontmatterBounds -Content $content
$fmLines = $bounds.Lines[$bounds.Start..$bounds.End]
$fmText = [string]::Join("`r`n", $fmLines)
$typeMatch = [regex]::Match($fmText, "(?m)^type:\s*(?<t>\w+)\s*$")
if (-not $typeMatch.Success) { throw 'Frontmatter type not found' }
$noteType = $typeMatch.Groups['t'].Value.ToLowerInvariant()
if (@('idea','project') -notcontains $noteType) { throw 'obsidian.elaborate v1 supports only Idea and Project notes' }
$today = (Get-Date).ToString('yyyy-MM-dd')
if ($fmText -match "(?m)^updated:\s*\d{4}-\d{2}-\d{2}\s*$") {
    $fmText = [regex]::Replace($fmText, "(?m)^updated:\s*\d{4}-\d{2}-\d{2}\s*$", "updated: $today")
} else {
    $fmText = $fmText -replace "(?m)^created:\s*\d{4}-\d{2}-\d{2}\s*$", "$&`r`nupdated: $today"
}
# Reassemble content with updated fm
$pre = ''
if ($bounds.Start -gt 0) { $pre = [string]::Join("`r`n", $bounds.Lines[0..($bounds.Start-1)]) }
$post = ''
if ($bounds.End -lt ($bounds.Lines.Length-1)) { $post = [string]::Join("`r`n", $bounds.Lines[($bounds.End+1)..($bounds.Lines.Length-1)]) }
$content = if ($pre) { "$pre`r`n$fmText" } else { $fmText }
if ($post) { $content = "$content`r`n$post" }

# 3) Ensure key sections and assemble questions
$questions = $null
$result = Ensure-Sections -Content $content -Type $noteType -Questions ([ref]$questions)
$newContent = $result.Content
$changed = [bool]$result.Changed

# 4) Diff + Trace
$abs = (Resolve-Path -LiteralPath $notePath | Select-Object -ExpandProperty Path)
$vaultRoot = Get-VaultRoot
$relPath = $abs.Substring($vaultRoot.Length)
if ($relPath.StartsWith('\\')) { $relPath = $relPath.TrimStart('\\') }
if ($relPath.StartsWith('/')) { $relPath = $relPath.TrimStart('/') }
$diff = New-DryRunDiff -TargetPath $notePath -NewContent $newContent
$tracePath = Write-Trace -Data @{
    command = 'obsidian.elaborate'
    params = @{ selected_path = $SelectedPath; dryRun = [bool]$DryRun; approve = [bool]$Approve }
    target = $relPath
    diff = $diff
    questions = $questions
}

# 5) Output
Write-Host "Elaborate findings (see trace): $tracePath" -ForegroundColor Cyan
if ($questions -and $questions.Count -gt 0) {
    Write-Host "Questions (up to 5):" -ForegroundColor Yellow
    $i = 1
    foreach ($q in $questions) {
        if ($q.type -eq 'choice') {
            Write-Host ("  {0}. {1} [options: {2}] (suggested: {3})" -f $i, $q.question, ($q.options -join ', '), $q.suggested)
        } else {
            Write-Host ("  {0}. {1} (suggested: {2})" -f $i, $q.question, $q.suggested)
        }
        $i++
    }
}

if ($DryRun -and -not $Approve) {
    Write-Host "Dry-run diff:" -ForegroundColor Cyan
    Write-Host $diff
    Write-Host "To apply, re-run with -Approve or -DryRun:`$false" -ForegroundColor Yellow
    exit 0
}

if ($Approve) {
    Write-Host "Applying changes (approved). Diff:" -ForegroundColor Cyan
    Write-Host $diff
}

# 6) Apply if changed
if ($changed) {
    Set-Content -LiteralPath $notePath -Value $newContent -Encoding UTF8
    Write-Host "Updated: $relPath" -ForegroundColor Green
} else {
    Write-Host "No changes needed: $relPath" -ForegroundColor Yellow
}

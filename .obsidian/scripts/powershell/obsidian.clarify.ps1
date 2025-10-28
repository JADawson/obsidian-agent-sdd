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

function Update-ProjectFrontmatter {
    param(
        [string]$Content,
        [string[]]$AllowedStatus,
        [ref]$Questions
    )
    $bounds = Get-FrontmatterBounds -Content $Content
    $lines = $bounds.Lines
    $start = $bounds.Start
    $end = $bounds.End

    $fmLines = $lines[$start..$end]
    $fmText = [string]::Join("`r`n", $fmLines)

    # Ensure type: project
    if (-not ($fmText -match "(?m)^type:\s*project\s*$")) {
        throw 'Only Project notes are supported by clarify v1 (type: project required)'
    }

    $changed = $false
    $qList = @()

    # Ensure status is allowed
    $statusMatch = [regex]::Match($fmText, "(?m)^status:\s*(?<v>\S+)\s*$")
    if ($statusMatch.Success) {
        $status = $statusMatch.Groups['v'].Value
        if ($AllowedStatus -notcontains $status) {
            $suggested = 'planned'
            $fmText = [regex]::Replace($fmText, "(?m)^status:\s*\S+\s*$", "status: $suggested")
            $changed = $true
            $qList += @{ type='choice'; question='Confirm project status'; options=$AllowedStatus; suggested=$suggested }
        }
    } else {
        $suggested = 'planned'
        $insertAfter = ($fmText -match "(?m)^type:\s*project\s*$")
        $fmText = $fmText -replace "(?m)^type:\s*project\s*$", "type: project`r`nstatus: $suggested"
        $changed = $true
        $qList += @{ type='choice'; question='Set project status'; options=$AllowedStatus; suggested=$suggested }
    }

    # Ensure links block exists and ensure links.area under it
    $fmArr = $fmText -split "`r?`n"
    $linksIndex = ($fmArr | Select-String -Pattern '^(?i)links:\s*$' -SimpleMatch:$false | Select-Object -First 1).LineNumber
    if (-not $linksIndex) {
        # Insert links block after tags block (or after 'tags:' line if simple)
        $insertIdx = ($fmArr | Select-String -Pattern '^(?i)tags:' | Select-Object -Last 1).LineNumber
        if (-not $insertIdx) { $insertIdx = ($fmArr.Count - 1) }
        $before = $fmArr[0..$insertIdx]
        $after = @()
        if ($insertIdx -lt ($fmArr.Count - 1)) { $after = $fmArr[($insertIdx+1)..($fmArr.Count-1)] }
        $fmArr = @()
        $fmArr += $before
        $fmArr += 'links:'
        $fmArr += '  idea: [[<Idea Note>]]'
        $fmArr += '  goal: [[<Goal Note>]]'
        $fmArr += $after
        $changed = $true
        $linksIndex = ($fmArr | Select-String -Pattern '^(?i)links:\s*$' | Select-Object -First 1).LineNumber
    }
    # Recompute in case of changes
    $hasArea = ($fmArr | Select-String -Pattern '^\s{2}area:\s*\[\[.*\]\]' | Measure-Object).Count -gt 0
    if (-not $hasArea) {
        # Insert area immediately after 'links:' line
        $idx = $linksIndex
        $before = $fmArr[0..$idx]
        $after = @()
        if ($idx -lt ($fmArr.Count - 1)) { $after = $fmArr[($idx+1)..($fmArr.Count-1)] }
        $fmArr = @()
        $fmArr += $before
        $fmArr += '  area: [[<Owning Area>]]'
        $fmArr += $after
        $changed = $true
        $qList += @{ type='short'; question='What is the owning Area?'; suggested='<Owning Area>' }
    }
    # Update fmText after fmArr changes
    $fmText = [string]::Join("`r`n", $fmArr)

    # Update updated date
    $today = (Get-Date).ToString('yyyy-MM-dd')
    if ($fmText -match "(?m)^updated:\s*\d{4}-\d{2}-\d{2}\s*$") {
        $fmText = [regex]::Replace($fmText, "(?m)^updated:\s*\d{4}-\d{2}-\d{2}\s*$", "updated: $today")
        $changed = $true
    } else {
        $fmText = $fmText -replace "(?m)^created:\s*\d{4}-\d{2}-\d{2}\s*$", "$&`r`nupdated: $today"
        $changed = $true
    }

    # Reassemble content (pre + updated frontmatter + post)
    $pre = ''
    if ($start -gt 0) {
        $pre = [string]::Join("`r`n", $lines[0..($start-1)])
    }
    $post = ''
    if ($end -lt ($lines.Length-1)) {
        $post = [string]::Join("`r`n", $lines[($end+1)..($lines.Length-1)])
    }
    if ($pre) { $newContent = "$pre`r`n$fmText" } else { $newContent = $fmText }
    if ($post) { $newContent = "$newContent`r`n$post" }

    $Questions.Value = $qList
    return @{ Changed=$changed; Content=$newContent }
}

# 1) Resolve selected path
$projPath = Resolve-SelectedPath -Path $SelectedPath
$content = Get-Content -LiteralPath $projPath -Raw

# 2) Analyze and propose changes
$allowedStatus = @('planned','active','paused','completed','cancelled')
$questions = $null
$result = Update-ProjectFrontmatter -Content $content -AllowedStatus $allowedStatus -Questions ([ref]$questions)
$newContent = $result.Content
$changed = [bool]$result.Changed

# 3) Compute diff and trace
$rel = (Resolve-Path -LiteralPath $projPath | Select-Object -ExpandProperty Path)
$vaultRoot = Get-VaultRoot
$relPath = $rel.Substring($vaultRoot.Length)
if ($relPath.StartsWith('\\')) { $relPath = $relPath.TrimStart('\\') }
if ($relPath.StartsWith('/')) { $relPath = $relPath.TrimStart('/') }
$diff = New-DryRunDiff -TargetPath $projPath -NewContent $newContent
$tracePath = Write-Trace -Data @{
    command = 'obsidian.clarify'
    params = @{ selected_path = $SelectedPath; dryRun = [bool]$DryRun; approve = [bool]$Approve }
    target = $relPath
    diff = $diff
    questions = $questions
}

# 4) Output
Write-Host "Clarify findings (see trace): $tracePath" -ForegroundColor Cyan
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

# 5) Apply if changed
if ($changed) {
    Set-Content -LiteralPath $projPath -Value $newContent -Encoding UTF8
    Write-Host "Updated: $relPath" -ForegroundColor Green
} else {
    Write-Host "No changes needed: $relPath" -ForegroundColor Yellow
}

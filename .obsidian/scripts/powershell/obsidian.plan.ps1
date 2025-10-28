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
    # Try join as given under vault root
    $p2 = Join-Path -Path $root -ChildPath $Path
    if (Test-Path -LiteralPath $p2) { return (Resolve-Path -LiteralPath $p2 | Select-Object -ExpandProperty Path) }
    # If path starts with 'Vault' prefix, strip and try again
    if ($Path -match '^(?i)vault\\(.*)$') {
        $rel = $Matches[1]
        $p3 = Join-Path -Path $root -ChildPath $rel
        if (Test-Path -LiteralPath $p3) { return (Resolve-Path -LiteralPath $p3 | Select-Object -ExpandProperty Path) }
    }
    throw "SelectedPath not found: $Path"
}

# 1) Resolve Idea path and basic metadata
$ideaPath = Resolve-SelectedPath -Path $SelectedPath
$ideaContent = Get-Content -LiteralPath $ideaPath -Raw
$ideaTitle = ($ideaContent -split "`r?`n" | Where-Object { $_ -match '^#\s+' } | Select-Object -First 1)
if ($ideaTitle) { $ideaTitle = $ideaTitle -replace '^#\s+','' } else { $ideaTitle = [System.IO.Path]::GetFileNameWithoutExtension($ideaPath) }

# 2) Compute Project note details
$projectTitle = $ideaTitle
$noteId = New-NoteId -Title $projectTitle
$slug = Get-Slug -Text $projectTitle
$folder = Get-PlacementFolder -Type 'project'
$fileName = (Sanitize-Filename -Name "$slug.md")
$relPath = Join-Path -Path $folder -ChildPath $fileName
$targetPath = Resolve-VaultPath -RelativePath $relPath

# 3) Load Project template and fill
$templatePath = Join-Path -Path "$PSScriptRoot/../../templates" -ChildPath 'project.v1.md'
if (-not (Test-Path -LiteralPath $templatePath)) { throw "Template not found: $templatePath" }
$today = (Get-Date).ToString('yyyy-MM-dd')
$content = Get-Content -LiteralPath $templatePath -Raw
$content = $content `
    -replace '<id>',$noteId `
    -replace '<Title>',$projectTitle `
    -replace '<YYYY-MM-DD>',$today `
    -replace '\[\[<Idea Note>\]\]', "[[${ideaTitle}]]"

# 4) Diff + Trace
$diff = New-DryRunDiff -TargetPath $targetPath -NewContent $content
$tracePath = Write-Trace -Data @{
    command = 'obsidian.plan'
    params = @{ selected_path = $SelectedPath; dryRun = [bool]$DryRun; approve = [bool]$Approve }
    target = $relPath
    diff = $diff
    template = 'project.v1.md'
    idea = @{ path = $ideaPath; title = $ideaTitle }
}

# 5) Dry-run / approval
if ($DryRun -and -not $Approve) {
    Write-Host "Dry-run diff (see trace: $tracePath):" -ForegroundColor Cyan
    Write-Host $diff
    Write-Host "To apply, re-run with -Approve (non-interactive) or -DryRun:$false" -ForegroundColor Yellow
    exit 0
}

if ($Approve) {
    Write-Host "Applying changes (approved). Diff (see trace: $tracePath):" -ForegroundColor Cyan
    Write-Host $diff
}

# 6) Idempotent write
if (Test-Path -LiteralPath $targetPath) {
    $existing = Get-Content -LiteralPath $targetPath -Raw
    if ($existing -eq $content) {
        Write-Host "No changes: $relPath already up-to-date" -ForegroundColor Yellow
        exit 0
    }
}

$targetDir = Split-Path -Path $targetPath -Parent
if (-not (Test-Path -LiteralPath $targetDir)) { New-Item -ItemType Directory -Path $targetDir | Out-Null }
Set-Content -LiteralPath $targetPath -Value $content -Encoding UTF8
Write-Host "Created/Updated: $relPath (id: $noteId)" -ForegroundColor Green

#requires -Version 5.1
param(
    [ValidateSet('idea','goal','project','area')]
    [string]$Type,
    [Parameter(Mandatory)][string]$Title,
    [string]$Description = '',
    [switch]$DryRun = $true,
    [switch]$Approve
)

$ErrorActionPreference = 'Stop'
Import-Module -Name "$PSScriptRoot/helpers.psm1" -Force

$cfg = Get-ObsidianConfig
$today = (Get-Date).ToString('yyyy-MM-dd')
$effectiveType = if ($Type) { $Type } else { 'idea' }
$noteId = New-NoteId -Title $Title
$slug = ConvertTo-Slug -Text $Title
$folder = Get-PlacementFolder -Type $effectiveType

# Build filename and target path
$fileName = (ConvertTo-FilenameSafe -Name "$slug.md")
$relPath = Join-Path -Path $folder -ChildPath $fileName
$targetPath = Resolve-VaultPath -RelativePath $relPath

# Load template and fill placeholders (US1 implementation)
$templateName = "$effectiveType.v1.md"
$templatePath = Join-Path -Path "$PSScriptRoot/../../templates" -ChildPath $templateName
if (-not (Test-Path -LiteralPath $templatePath)) { throw "Template not found: $templatePath" }
$content = Get-Content -LiteralPath $templatePath -Raw
$content = $content `
    -replace '<id>',$noteId `
    -replace '<Title>',$Title `
    -replace '<YYYY-MM-DD>',$today

# Enforce curated tag for Idea (US1); for other types templates already carry correct tag
if ($effectiveType -eq 'idea') {
    # ensure at least one '#idea' tag in YAML; template includes it already
    if ($content -notmatch "#idea") {
        $content = $content -replace "tags:\s*\r?\n", "tags:`r`n  - #idea`r`n"
    }
}

$diff = New-DryRunDiff -TargetPath $targetPath -NewContent $content
$tracePath = Write-Trace -Data @{
    command = 'obsidian.create'
    params = @{ type = $effectiveType; title = $Title; description = $Description; dryRun = [bool]$DryRun; approve = [bool]$Approve }
    target = $relPath
    diff = $diff
    noteId = $noteId
    template = $templateName
}

# Dry-run behavior with optional approval
if ($DryRun -and -not $Approve) {
    Write-Host "Dry-run diff (see trace: $tracePath):" -ForegroundColor Cyan
    Write-Host $diff
    Write-Host "To apply, re-run with -Approve (interactive approval) or -DryRun:$false" -ForegroundColor Yellow
    exit 0
}

if ($Approve) {
    Write-Host "Applying changes (approved). Diff (see trace: $tracePath):" -ForegroundColor Cyan
    Write-Host $diff
}

# Ensure folder exists
$targetDir = Split-Path -Path $targetPath -Parent
if (-not (Test-Path -LiteralPath $targetDir)) { New-Item -ItemType Directory -Path $targetDir | Out-Null }

# No-op if exists with same content
if (Test-Path -LiteralPath $targetPath) {
    $existing = Get-Content -LiteralPath $targetPath -Raw
    if ($existing -eq $content) {
        Write-Host "No changes: $relPath already up-to-date" -ForegroundColor Yellow
        exit 0
    }
}

# Ensure directory and write file
$targetDir = Split-Path -Path $targetPath -Parent
if (-not (Test-Path -LiteralPath $targetDir)) { New-Item -ItemType Directory -Path $targetDir | Out-Null }
Set-Content -LiteralPath $targetPath -Value $content -Encoding UTF8
Write-Host "Created/Updated: $relPath (id: $noteId)" -ForegroundColor Green

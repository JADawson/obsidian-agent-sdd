#requires -Version 5.1
param(
    [ValidateSet('idea','goal','project','area')]
    [string]$Type,
    [Parameter(Mandatory)][string]$Title,
    [string]$Description = '',
    [switch]$DryRun = $true
)

$ErrorActionPreference = 'Stop'
Import-Module -Name "$PSScriptRoot/helpers.ps1" -Force

$cfg = Get-ObsidianConfig
$noteId = New-NoteId -Title $Title
$slug = Get-Slug -Text $Title
$folder = if ($Type) { Get-PlacementFolder -Type $Type } else { Get-PlacementFolder -Type 'idea' }

# Build filename and target path
$fileName = (Sanitize-Filename -Name "$slug.md")
$relPath = Join-Path -Path $folder -ChildPath $fileName
$targetPath = Resolve-VaultPath -RelativePath $relPath

# Load template (basic; placeholder replacement to be expanded in story phases)
$templateName = if ($Type) { "$Type.v1.md" } else { 'idea.v1.md' }
$templatePath = Join-Path -Path "$PSScriptRoot/../../templates" -ChildPath $templateName
if (-not (Test-Path -LiteralPath $templatePath)) { throw "Template not found: $templatePath" }
$content = Get-Content -LiteralPath $templatePath -Raw
$content = $content -replace '<id>',$noteId -replace '<Title>',$Title

$diff = New-DryRunDiff -TargetPath $targetPath -NewContent $content
$tracePath = Write-Trace -Data @{
    command = 'obsidian.create'
    params = @{ type = $Type; title = $Title; description = $Description; dryRun = [bool]$DryRun }
    target = $relPath
    diff = $diff
}

if ($DryRun) {
    Write-Host "Dry-run diff (see trace: $tracePath):" -ForegroundColor Cyan
    Write-Host $diff
    exit 0
}

# Ensure folder exists
$targetDir = Split-Path -Path $targetPath -Parent
if (-not (Test-Path -LiteralPath $targetDir)) { New-Item -ItemType Directory -Path $targetDir | Out-Null }

# Write file
Set-Content -LiteralPath $targetPath -Value $content -Encoding UTF8
Write-Host "Created: $relPath (id: $noteId)" -ForegroundColor Green

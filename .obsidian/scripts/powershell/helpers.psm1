#requires -Version 5.1
<#!
Helper functions for Obsidian Agent scripts
- Slug/id generation (slug+hash)
- Filename sanitization
- Vault path resolution and boundary checks
- Placement rules per constitution (numbered folders)
- Dry-run diff and tracing
!#>

Set-StrictMode -Version Latest

# Global configuration (loaded lazily)
$script:ObsidianConfig = $null

function Get-ObsidianConfig {
    param(
        [string]$ConfigPath = "$PSScriptRoot/../../config.json"
    )
    if (-not $script:ObsidianConfig) {
        if (-not (Test-Path -LiteralPath $ConfigPath)) {
            throw "Obsidian config not found at: $ConfigPath"
        }
        $script:ObsidianConfig = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
    }
    return $script:ObsidianConfig
}

function Get-Slug {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Text
    )
    $t = $Text.Trim().ToLowerInvariant()
    $t = -join ($t.ToCharArray() | ForEach-Object { if ("abcdefghijklmnopqrstuvwxyz0123456789 -_".Contains($_)) { $_ } else { '-' } })
    $t = $t -replace '[\s_]+','-'
    $t = $t -replace '-{2,}','-'
    $t = $t.Trim('-')
    if ([string]::IsNullOrWhiteSpace($t)) { 'note' } else { $t }
}

function Get-ShortHash {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Text,
        [int]$Length = 6
    )
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    $sha1 = [System.Security.Cryptography.SHA1]::Create()
    try {
        $hash = $sha1.ComputeHash($bytes)
    } finally {
        $sha1.Dispose()
    }
    $hex = ($hash | ForEach-Object { $_.ToString('x2') }) -join ''
    return $hex.Substring(0, [Math]::Min($Length, $hex.Length))
}

function New-NoteId {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Title,
        [int]$HashLength = $(Get-ObsidianConfig).id.hashLength,
        [string]$Separator = $(Get-ObsidianConfig).id.separator
    )
    $slug = Get-Slug -Text $Title
    $hash = Get-ShortHash -Text $Title -Length $HashLength
    return "$slug$Separator$hash"
}

function Sanitize-Filename {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name,
        [int]$MaxLength = 120
    )
    $n = $Name -replace '[:\\/*?"<>|]','-'
    $n = $n -replace '-{2,}','-'
    if ($n.Length -gt $MaxLength) { $n = $n.Substring(0,$MaxLength) }
    return $n.Trim().Trim('.')
}

function Get-VaultRoot {
    $cfg = Get-ObsidianConfig
    if (-not $cfg.vaultPath) { throw 'vaultPath missing in config.json' }
    return [System.IO.Path]::GetFullPath($cfg.vaultPath)
}

function Resolve-VaultPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RelativePath
    )
    $root = Get-VaultRoot
    $full = [System.IO.Path]::GetFullPath((Join-Path -Path $root -ChildPath $RelativePath))
    if (-not ($full.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase))) {
        throw "Resolved path '$full' escapes vault root '$root'"
    }
    return $full
}

function Get-PlacementFolder {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateSet('idea','goal','project','area','reference','archive','plan')][string]$Type,
        [string]$ProjectName
    )
    $cfg = Get-ObsidianConfig
    switch ($Type) {
        'idea'      { return $cfg.folders.idea }
        'goal'      { return $cfg.folders.goal }
        'project'   { return $cfg.folders.project }
        'area'      { return $cfg.folders.area }
        'reference' { return $cfg.folders.reference }
        'archive'   { return $cfg.folders.archive }
        'plan'      {
            if (-not $ProjectName) { throw 'ProjectName required for plan placement' }
            return (Join-Path -Path $cfg.folders.project -ChildPath (Join-Path -Path $ProjectName -ChildPath 'Activity Plans'))
        }
    }
}

function Write-Trace {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][hashtable]$Data
    )
    $traceDir = Resolve-Path -LiteralPath "$PSScriptRoot/../../../.agent/logs" | Select-Object -ExpandProperty Path
    if (-not (Test-Path -LiteralPath $traceDir)) { New-Item -ItemType Directory -Path $traceDir | Out-Null }
    $ts = (Get-Date).ToString('yyyyMMdd_HHmmss_ffff')
    $file = Join-Path $traceDir "trace_$ts.json"
    ($Data | ConvertTo-Json -Depth 10) | Out-File -FilePath $file -Encoding UTF8
    return $file
}

function New-DryRunDiff {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$TargetPath,
        [Parameter(Mandatory)][string]$NewContent
    )
    if (-not (Test-Path -LiteralPath $TargetPath)) {
        return "CREATE $(Split-Path -Leaf $TargetPath)`r`n---`r`n$NewContent"
    }
    $old = Get-Content -LiteralPath $TargetPath -Raw
    $oldLines = $old -split "`r?`n"
    $newLines = $NewContent -split "`r?`n"
    $diff = Compare-Object -ReferenceObject $oldLines -DifferenceObject $newLines -IncludeEqual:$false |
        ForEach-Object {
            if ($_.SideIndicator -eq '=>') { "+ " + $_.InputObject }
            elseif ($_.SideIndicator -eq '<=') { "- " + $_.InputObject }
        } | Out-String
    return $diff.Trim()
}

Export-ModuleMember -Function *

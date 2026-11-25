#Requires -Version 5.1
<#
.SYNOPSIS
    Refreshes the Dwengo libraries bundled with the platform from the Blockly-for-Dwenguino repo
    (PowerShell equivalent of sync_dwengo_libraries.sh).
.EXAMPLE
    .\scripts\sync_dwengo_libraries.ps1 1.0.1 unified
#>
param(
    [string]$CoreVersion = "1.0.1",
    [string]$Branch = "unified"
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$RootDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$LibDir = Join-Path $RootDir "nrf52\$CoreVersion\libraries"
$BaseUrl = "https://raw.githubusercontent.com/dwengovzw/Blockly-for-Dwenguino/refs/heads/$Branch/backend/compilation/hardware/dwengo/nrf52/1.0.0/libraries"
$Libs = @("DwengoCompatibilityLayer", "HalberdGripper", "HalberdGripperSensor")

if (-not (Test-Path $LibDir -PathType Container)) {
    Write-Error "Missing libraries folder: $LibDir"
    exit 1
}

$TmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $TmpDir | Out-Null

try {
    foreach ($lib in $Libs) {
        $zip = Join-Path $TmpDir "$lib.zip"
        $extractDir = Join-Path $TmpDir $lib
        Invoke-WebRequest -Uri "$BaseUrl/$lib/$lib.zip" -OutFile $zip -UseBasicParsing
        Expand-Archive -LiteralPath $zip -DestinationPath $extractDir

        $src = Join-Path $extractDir $lib
        $props = Join-Path $src "library.properties"
        if (-not (Test-Path $props -PathType Leaf)) {
            throw "Unexpected archive layout for $lib"
        }

        $dest = Join-Path $LibDir $lib
        if (Test-Path $dest) { Remove-Item -LiteralPath $dest -Recurse -Force }
        Copy-Item -LiteralPath $src -Destination $dest -Recurse

        $version = (Select-String -LiteralPath $props -Pattern '^version=' | Select-Object -First 1).Line
        Write-Output "Synced $lib ($version)"
    }
} finally {
    Remove-Item -LiteralPath $TmpDir -Recurse -Force -ErrorAction SilentlyContinue
}

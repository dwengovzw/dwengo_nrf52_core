#Requires -Version 5.1
<#
.SYNOPSIS
    Builds the Boards Manager release archive (PowerShell equivalent of make_release_archive.sh).
.EXAMPLE
    .\scripts\make_release_archive.ps1 1.0.1
#>
param(
    [string]$CoreVersion = "1.0.1"
)

$ErrorActionPreference = "Stop"

$RootDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$ArchiveBase = "dwengo-nrf52-$CoreVersion"
$ReleasesDir = Join-Path $RootDir "releases"
$ArchivePath = Join-Path $ReleasesDir "$ArchiveBase.tar.bz2"
$PlatformDir = Join-Path $RootDir "nrf52\$CoreVersion"

if (-not (Test-Path $PlatformDir -PathType Container)) {
    Write-Error "Missing platform folder: $PlatformDir"
    exit 1
}

$tar = Join-Path $env:SystemRoot "System32\tar.exe"
if (-not (Test-Path $tar)) {
    Write-Error "Windows bsdtar not found at $tar (requires Windows 10 1803 or later)."
    exit 1
}

New-Item -ItemType Directory -Force -Path $ReleasesDir | Out-Null

# Windows has no executable bit, so take file modes from the git index instead.
$execFiles = New-Object 'System.Collections.Generic.HashSet[string]'
$gitEntries = & git -C $RootDir -c core.quotepath=off ls-files -s -- "nrf52/$CoreVersion" 2>$null
if ($LASTEXITCODE -eq 0) {
    foreach ($line in $gitEntries) {
        if ($line -match '^100755 \S+ \d+\t(.+)$') { [void]$execFiles.Add($Matches[1]) }
    }
} else {
    Write-Warning "git not available; all files will be archived with mode 0644."
}

# mtree escapes whitespace, '#', '\' and non-ASCII bytes as octal.
function ConvertTo-MtreePath([string]$Path) {
    $sb = New-Object System.Text.StringBuilder
    foreach ($b in [System.Text.Encoding]::UTF8.GetBytes($Path)) {
        if ($b -le 32 -or $b -ge 127 -or $b -eq 35 -or $b -eq 92) {
            [void]$sb.Append('\' + [Convert]::ToString($b, 8).PadLeft(3, '0'))
        } else {
            [void]$sb.Append([char]$b)
        }
    }
    $sb.ToString()
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("#mtree")
$lines.Add("/set uid=0 gid=0 uname=root gname=root")
$lines.Add("$(ConvertTo-MtreePath $ArchiveBase) type=dir mode=0755")

$items = Get-ChildItem -LiteralPath $PlatformDir -Recurse -Force | Sort-Object FullName
foreach ($item in $items) {
    $rel = $item.FullName.Substring($PlatformDir.Length + 1).Replace('\', '/')
    $name = ConvertTo-MtreePath "$ArchiveBase/$rel"
    if ($item.PSIsContainer) {
        $lines.Add("$name type=dir mode=0755")
    } else {
        $mode = if ($execFiles.Contains("nrf52/$CoreVersion/$rel")) { "0755" } else { "0644" }
        $contents = ConvertTo-MtreePath ($item.FullName.Replace('\', '/'))
        $lines.Add("$name type=file mode=$mode contents=$contents")
    }
}

$manifest = Join-Path ([System.IO.Path]::GetTempPath()) "$ArchiveBase-$([guid]::NewGuid()).mtree"
try {
    [System.IO.File]::WriteAllLines($manifest, $lines, (New-Object System.Text.UTF8Encoding($false)))
    if (Test-Path $ArchivePath) { Remove-Item $ArchivePath -Force }
    & $tar -cjf $ArchivePath "@$manifest"
    if ($LASTEXITCODE -ne 0) { throw "tar failed with exit code $LASTEXITCODE" }
} finally {
    Remove-Item $manifest -Force -ErrorAction SilentlyContinue
}

$sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $ArchivePath).Hash.ToLower()
$size = (Get-Item -LiteralPath $ArchivePath).Length

Write-Output "Archive: $ArchivePath"
Write-Output "SHA256: $sha256"
Write-Output "Size: $size"

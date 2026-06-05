$ErrorActionPreference = "Stop"

$Repo = "42Wor/maazdb-cli"
$Version = "13.6.0"
$Target = "maazdb-windows-amd64.zip"
$DownloadUrl = "https://github.com/$Repo/releases/download/v$Version/$Target"
$InstallDir = "$env:USERPROFILE\.maazdb\bin"

Write-Host "=== MaazDB Windows Setup ===" -ForegroundColor Cyan

# 1. Elevate Privilege Detection
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# 2. Stage workspace
$TmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ([Guid]::NewGuid().ToString())
New-Item -ItemType Directory -Force -Path $TmpDir | Out-Null
$ZipFile = Join-Path $TmpDir $Target

# 3. Pull Release Bundle
try {
    Write-Host "-> Fetching latest build archive..." -ForegroundColor Gray
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $ZipFile -UseBasicParsing
} catch {
    Write-Error "Failed to download build assets from $DownloadUrl."
    Remove-Item -Recurse -Force $TmpDir -ErrorAction SilentlyContinue
    exit 1
}

# 4. Extract
Write-Host "-> Extracting binaries..." -ForegroundColor Gray
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($ZipFile, $TmpDir)

if (!(Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
}

$ExtractedFolder = Join-Path $TmpDir "maazdb-windows-amd64"
$SourcePath = if (Test-Path $ExtractedFolder) { $ExtractedFolder } else { $TmpDir }

# --- FIX: Stop running services and processes ---
Write-Host "-> Stopping active MaazDB processes..." -ForegroundColor Gray
if ($IsAdmin) {
    if (Get-Service -Name "MaazDB" -ErrorAction SilentlyContinue) {
        Stop-Service -Name "MaazDB" -Force -ErrorAction SilentlyContinue
    }
}
Stop-Process -Name "maazdb-server" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "maazdb-cli" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1
# ------------------------------------------------

Copy-Item -Path "$SourcePath\*.exe" -Destination $InstallDir -Force

# 5. Background Service configuration
if ($IsAdmin) {
    $ServerExe = Join-Path $InstallDir "maazdb-server.exe"
    if (Test-Path $ServerExe) {
        $ServiceObj = Get-Service -Name "MaazDB" -ErrorAction SilentlyContinue
        if ($ServiceObj -eq $null) {
            New-Service -Name "MaazDB" -BinaryPathName "`"$ServerExe`"" -DisplayName "MaazDB Database Engine" -StartupType Automatic | Out-Null
        }
        Start-Service -Name "MaazDB" -ErrorAction SilentlyContinue
    }
}

Remove-Item -Recurse -Force $TmpDir -ErrorAction SilentlyContinue

# 6. Set PATH
$UserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($UserPath -notmatch [regex]::Escape($InstallDir)) {
    $NewPath = $UserPath + ";" + $InstallDir
    [Environment]::SetEnvironmentVariable("PATH", $NewPath, "User")
    Write-Host "-> PATH variable updated." -ForegroundColor Cyan
    Write-Host "👉 Please restart your terminal to load the configuration." -ForegroundColor Yellow
}

Write-Host "🎉 Installation complete. Run: maazdb-cli" -ForegroundColor Green
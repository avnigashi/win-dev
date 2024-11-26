# Require administrator privileges
#Requires -RunAsAdministrator

# Function to check if Docker is installed
function Test-DockerInstalled {
    $dockerApp = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Docker*" }
    return $null -ne $dockerApp
}

# Function to get current username
function Get-CurrentUsername {
    return [System.Environment]::UserName
}

# Script starts here
Write-Host "Docker Installation and Configuration Script" -ForegroundColor Green

# 1. Check and prompt for Docker uninstallation
if (Test-DockerInstalled) {
    $uninstallChoice = Read-Host "Docker is currently installed. Do you want to uninstall it? (Y/N)"
    if ($uninstallChoice -eq 'Y') {
        Write-Host "Please uninstall Docker using Windows Settings > Apps > Apps & features" -ForegroundColor Yellow
        Write-Host "After uninstallation, press any key to continue..."
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    } else {
        Write-Host "Script cannot continue with Docker installed. Exiting..." -ForegroundColor Red
        exit
    }
}

# 2. Get username and remove Docker AppData
$username = Get-CurrentUsername
$defaultAppDataPath = "C:\Users\$username\AppData\Local\Docker"

Write-Host "`nCurrent AppData Docker path: $defaultAppDataPath"
$removeAppData = Read-Host "Do you want to remove the Docker AppData folder? (Y/N)"
if ($removeAppData -eq 'Y') {
    if (Test-Path $defaultAppDataPath) {
        Remove-Item -Path $defaultAppDataPath -Recurse -Force
        Write-Host "Docker AppData folder removed successfully" -ForegroundColor Green
    } else {
        Write-Host "Docker AppData folder not found" -ForegroundColor Yellow
    }
}

# 3. Create Symbolic Link
Write-Host "`nSymbolic Link Configuration"
$targetPath = Read-Host "Enter the target path for Docker data (e.g., Z:\docker-daten)"
$sourcePath = Read-Host "Enter the source path for symbolic link (default: $defaultAppDataPath)"
if ([string]::IsNullOrWhiteSpace($sourcePath)) {
    $sourcePath = $defaultAppDataPath
}

# Create target directory if it doesn't exist
if (-not (Test-Path $targetPath)) {
    New-Item -ItemType Directory -Path $targetPath -Force
    Write-Host "Created target directory: $targetPath" -ForegroundColor Green
}

# Create symbolic link
try {
    New-Item -ItemType SymbolicLink -Target $targetPath -Path $sourcePath -Force
    Write-Host "Symbolic link created successfully" -ForegroundColor Green
} catch {
    Write-Host "Error creating symbolic link: $_" -ForegroundColor Red
    exit
}

# 4. Download and Install Docker
Write-Host "`nDocker Installation"
$installPath = Read-Host "Enter the Docker installation path (e.g., Z:\docker)"

# Download Docker installer
$installerUrl = "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe"
$installerPath = "$env:TEMP\DockerDesktopInstaller.exe"

Write-Host "Downloading Docker Desktop installer..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
    Write-Host "Download completed successfully" -ForegroundColor Green
} catch {
    Write-Host "Error downloading Docker installer: $_" -ForegroundColor Red
    exit
}

# Install Docker
Write-Host "Installing Docker..." -ForegroundColor Yellow
try {
    Start-Process -FilePath $installerPath -ArgumentList "install", "--quiet", "--accept-license", "--installation-dir=$installPath" -Wait
    Write-Host "Docker installation completed successfully" -ForegroundColor Green
} catch {
    Write-Host "Error installing Docker: $_" -ForegroundColor Red
    exit
}

# Cleanup
Remove-Item $installerPath -Force

Write-Host "`nInstallation and configuration completed successfully!" -ForegroundColor Green
Write-Host "Please restart your computer to complete the Docker installation." -ForegroundColor Yellow

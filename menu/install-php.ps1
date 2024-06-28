# Set script to stop on any error
$ErrorActionPreference = "Stop"

function Add-ToPath {
    param (
        [string]$newPath
    )
    $envPath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    if ($envPath -notmatch [regex]::Escape($newPath)) {
        [System.Environment]::SetEnvironmentVariable('Path', "$newPath;$envPath", 'Machine')
        Write-Host "$newPath has been added to the system PATH. Please restart your terminal or log out and log back in for the changes to take effect."
    } else {
        Write-Host "$newPath already exists in the system PATH."
    }
    $env:Path = "$newPath;$env:Path"
}

function Remove-FromPath {
    param (
        [string]$oldPath
    )
    $envPath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    $envPath = $envPath -replace [regex]::Escape($oldPath + ";"), ""
    [System.Environment]::SetEnvironmentVariable('Path', $envPath, 'Machine')
    Write-Host "$oldPath has been removed from the system PATH."
    $env:Path = $env:Path -replace [regex]::Escape($oldPath + ";"), ""
}

function Get-CommandVersion {
    param (
        [string]$command,
        [string]$versionArg = "--version"
    )
    $cmd = Get-Command $command -ErrorAction SilentlyContinue
    if ($cmd) {
        return & $command $versionArg
    } else {
        return $null
    }
}

function Show-PHPVersions {
    Write-Host "Select PHP version to install:"
    $phpVersions.Keys | ForEach-Object { Write-Host "$($_)" }
    Write-Host "Back to main menu (type 'menu')"
}

$phpVersions = @{
    "7.4.33" = if ([Environment]::Is64BitOperatingSystem) { "https://windows.php.net/downloads/releases/php-7.4.33-Win32-vc15-x64.zip" } else { "https://windows.php.net/downloads/releases/php-7.4.33-Win32-vc15-x86.zip" }
    "8.3.8"  = if ([Environment]::Is64BitOperatingSystem) { "https://windows.php.net/downloads/releases/php-8.3.8-Win32-vs16-x64.zip" } else { "https://windows.php.net/downloads/releases/php-8.3.8-Win32-vs16-x86.zip" }
}

function Install-PHP {
    param (
        [string]$phpVersion,
        [string]$phpUrl
    )
    $currentVersion = Get-CommandVersion -command "php" -versionArg "-v"
    if ($currentVersion) {
        Write-Host "PHP is already installed: $currentVersion"
        $confirm = Read-Host "Do you really want to reinstall PHP? (y/n)"
        if ($confirm -ne 'y') {
            return
        }
        # Remove the current PHP path from PATH
        $phpPath = (Get-Command "php").Path | Split-Path
        Remove-FromPath -oldPath $phpPath
    }

    $installPath = "C:\Program Files\PHP\php-$phpVersion"
    if (-Not (Test-Path $installPath)) {
        New-Item -ItemType Directory -Force -Path $installPath | Out-Null
    }
    $zipPath = "$installPath\php.zip"
    Invoke-WebRequest -Uri $phpUrl -OutFile $zipPath
    try {
        Expand-Archive -Path $zipPath -DestinationPath $installPath -Force
        Remove-Item $zipPath
        Add-ToPath -newPath "$installPath"
        Copy-Item -Path "$installPath\php.ini-development" -Destination "$installPath\php.ini"
        Write-Host "PHP $phpVersion installation completed successfully!"
    } catch {
        Write-Host "Failed to extract PHP zip file. Error: $_"
    }

    # Check installation success
    $installedVersion = Get-CommandVersion -command "php" -versionArg "-v"
    if ($installedVersion -and $installedVersion -match $phpVersion) {
        Write-Host "PHP $phpVersion has been installed successfully."
        Enable-PHPExtensions -installPath $installPath
    } else {
        Write-Host "Failed to install PHP $phpVersion."
    }
}

function Enable-PHPExtensions {
    param (
        [string]$installPath
    )
    $iniPath = "$installPath\php.ini"
    if (-Not (Test-Path $iniPath)) {
        Write-Host "php.ini not found at $installPath. Aborting."
        return
    }

    # Set the extension directory
    $extensionDir = "$installPath\ext"
    $iniContent = Get-Content -Path $iniPath
    $iniContent = $iniContent -replace ";\s*extension_dir\s*=\s*\"ext\"", "extension_dir = `"$extensionDir`""

    $extensions = @(
        "extension=curl",
        "extension=gd",
        "extension=mbstring",
        "extension=mysqli",
        "extension=openssl",
        "extension=pdo_mysql",
        "extension=xml",
        "extension=zip"
    )

    foreach ($extension in $extensions) {
        $iniContent = $iniContent -replace ";\s*$extension", "$extension"
        if ($iniContent -notmatch [regex]::Escape($extension)) {
            $iniContent += "`n$extension"
        }
    }
    Set-Content -Path $iniPath -Value $iniContent
    Write-Host "Enabled common PHP extensions in php.ini."
}

function InstallPluginsOnly {
    $phpPath = Get-Command "php" | Select-Object -ExpandProperty Source
    if ($phpPath) {
        $phpPath = Split-Path $phpPath
        Write-Host "PHP installation found at: $phpPath"
        Enable-PHPExtensions -installPath $phpPath
    } else {
        Write-Host "PHP is not installed or not found in the system PATH."
    }
}

function ShowMainMenu {
    Write-Host "Select an option to install:"
    Write-Host "1. Install PHP"
    Write-Host "2. Install Composer"
    Write-Host "3. Install Node.js via nvm"
    Write-Host "4. Install npm"
    Write-Host "5. Install pnpm"
    Write-Host "6. Install Yarn"
    Write-Host "7. Install Git"
    Write-Host "8. Install Docker"
    Write-Host "9. Projekt Aufsetzen"
    Write-Host "10. Software Status"
    Write-Host "11. Install only plugins"
    Write-Host "12. Exit"
}

while ($true) {
    ShowMainMenu
    $choice = Read-Host "Enter your choice (1-12)"
    switch ($choice) {
        1 {
            Show-PHPVersions
            $phpChoice = Read-Host "Enter your choice or 'menu' to return to the main menu"
            if ($phpChoice -ne 'menu' -and $phpVersions.ContainsKey($phpChoice)) {
                Install-PHP -phpVersion $phpChoice -phpUrl $phpVersions[$phpChoice]
            }
        }
        11 {
            InstallPluginsOnly
        }
        12 { break }
        default { Write-Host "Invalid choice. Please try again." }
    }
}

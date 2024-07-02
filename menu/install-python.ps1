# Set script to stop on any error
$ErrorActionPreference = "Stop"

function Install-Python {
    param (
        [string]$version
    )

    $url = "https://www.python.org/ftp/python/$version/python-$version-amd64.exe"
    $installerPath = "$env:TEMP\python-$version-amd64.exe"
    
    Write-Host "Downloading Python $version..."
    Invoke-WebRequest -Uri $url -OutFile $installerPath
    
    Write-Host "Installing Python $version..."
    Start-Process -FilePath $installerPath -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
    
    if ($?) {
        Write-Host "Python $version has been installed successfully."
    } else {
        Write-Host "Failed to install Python $version."
    }
}

# Submenu for selecting Python version
function Show-PythonVersionMenu {
    cls
    Write-Host "Select a Python version to install:"
    Write-Host "1. Python 3.8.10"
    Write-Host "2. Python 3.9.13"
    Write-Host "3. Python 3.10.11"
    Write-Host "4. Python 3.11.4"
    Write-Host "Enter your choice (1-4)"
}

# Main logic for Python installation
while ($true) {
    Show-PythonVersionMenu
    $versionChoice = Read-Host
    switch ($versionChoice) {
        1 { Install-Python -version "3.8.10"; break }
        2 { Install-Python -version "3.9.13"; break }
        3 { Install-Python -version "3.10.11"; break }
        4 { Install-Python -version "3.11.4"; break }
        default { Write-Host "Invalid choice. Please try again."; Pause }
    }
}

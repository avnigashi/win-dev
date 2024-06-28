# Set script to stop on any error
$ErrorActionPreference = "Stop"

function Install-Nvm-Node {
    $nvmInstallScript = "https://github.com/coreybutler/nvm-windows/releases/download/1.1.10/nvm-setup.exe"
    $installerPath = "$env:TEMP\nvm-setup.exe"
    Invoke-WebRequest -Uri $nvmInstallScript -OutFile $installerPath
    Start-Process -FilePath $installerPath -Wait
    if ($?) {
        Write-Host "nvm has been installed successfully."
        Add-ToPath -newPath "$env:APPDATA\nvm"
    } else {
        Write-Host "Failed to install nvm."
    }
}

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

Install-Nvm-Node

# Set script to stop on any error
$ErrorActionPreference = "Stop"

function Show-LoadingAnimation {
    param (
        [string]$message,
        [int]$durationSeconds = 10
    )
    $animation = ("|", "/", "-", "\")
    $i = 0
    $end = [DateTime]::Now.AddSeconds($durationSeconds)
    while ([DateTime]::Now -lt $end) {
        Write-Host -NoNewline "`r$message $($animation[$i % $animation.Length])"
        Start-Sleep -Milliseconds 200
        $i++
    }
    Write-Host "`r$message done."
}

function Install-Nvm-Node {
    $nvmInstallScript = "https://github.com/coreybutler/nvm-windows/releases/download/1.1.10/nvm-setup.exe"
    $installerPath = "$env:TEMP\nvm-setup.exe"
    Invoke-WebRequest -Uri $nvmInstallScript -OutFile $installerPath
    Show-LoadingAnimation -message "Downloading nvm" -durationSeconds 5
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

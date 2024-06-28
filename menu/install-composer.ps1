# Set script to stop on any error
$ErrorActionPreference = "Stop"

function Show-ProgressBar {
    param (
        [string]$message,
        [int]$delaySeconds = 10
    )
    $progress = 0
    $increment = 100 / $delaySeconds
    Write-Host $message
    for ($i = 0; $i -lt $delaySeconds; $i++) {
        Write-Progress -Activity $message -PercentComplete $progress
        Start-Sleep -Seconds 1
        $progress += $increment
    }
    Write-Progress -Activity $message -Completed
}

function Install-Composer {
    $url = "https://getcomposer.org/Composer-Setup.exe"
    $installerPath = "$env:TEMP\Composer-Setup.exe"
    Invoke-WebRequest -Uri $url -OutFile $installerPath
    Show-ProgressBar -message "Downloading Composer" -delaySeconds 5
    Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT" -Wait
    if ($?) {
        Write-Host "Composer has been installed successfully."
        Add-ToPath -newPath "C:\ProgramData\ComposerSetup\bin"
    } else {
        Write-Host "Failed to install Composer."
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

Install-Composer

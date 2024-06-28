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

function Install-Git {
    $url = if ([Environment]::Is64BitOperatingSystem) { "https://github.com/git-for-windows/git/releases/download/v2.45.2.windows.1/Git-2.45.2-64-bit.exe" } else { "https://github.com/git-for-windows/git/releases/download/v2.45.2.windows.1/Git-2.45.2-32-bit.exe" }
    $installerPath = "$env:TEMP\GitInstaller.exe"
    Invoke-WebRequest -Uri $url -OutFile $installerPath
    Show-LoadingAnimation -message "Downloading Git" -durationSeconds 5
    Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT" -Wait
    if ($?) {
        Write-Host "Git has been installed successfully."
        Add-ToPath -newPath "C:\Program Files\Git\bin"
        git lfs install
        Write-Host "Git LFS has been installed and activated."
    } else {
        Write-Host "Failed to install Git."
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

Install-Git

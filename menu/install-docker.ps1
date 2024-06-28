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

function Open-DockerDownloadPage {
    $url = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
    Start-Process $url
    Write-Host "Docker download page has been opened in your browser."
}

Open-DockerDownloadPage

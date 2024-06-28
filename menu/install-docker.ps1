# Set script to stop on any error
$ErrorActionPreference = "Stop"

function Open-DockerDownloadPage {
    $url = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
    Start-Process $url
    Write-Host "Docker download page has been opened in your browser."
}

Open-DockerDownloadPage

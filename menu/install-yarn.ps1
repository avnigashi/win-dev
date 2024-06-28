# Set script to stop on any error
$ErrorActionPreference = "Stop"

function Install-Yarn {
    npm install -g yarn
    Write-Host "Yarn has been installed successfully."
}

Install-Yarn

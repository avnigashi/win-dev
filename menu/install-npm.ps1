# Set script to stop on any error
$ErrorActionPreference = "Stop"

function Install-Npm {
    npm install -g npm
    Write-Host "npm has been installed successfully."
}

Install-Npm

# Set script to stop on any error
$ErrorActionPreference = "Stop"

function Install-Pnpm {
    npm install -g pnpm
    Write-Host "pnpm has been installed successfully."
}

Install-Pnpm

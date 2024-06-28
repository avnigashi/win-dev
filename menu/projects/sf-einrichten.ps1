# Set script to stop on any error
$ErrorActionPreference = "Stop"

function SF-Einrichten {
    param (
        [string]$projectRoot
    )

    $backendPath = Join-Path -Path $projectRoot -ChildPath "apps/sf/backend"
    $frontendPath = Join-Path -Path $projectRoot -ChildPath "apps/sf/frontend"

    try {
        Copy-Item -Path (Join-Path -Path $backendPath -ChildPath ".env.template") -Destination (Join-Path -Path $backendPath -ChildPath ".env")
        Copy-Item -Path (Join-Path -Path $frontendPath -ChildPath ".env-template") -Destination (Join-Path -Path $frontendPath -ChildPath ".env")

        Set-Location -Path $backendPath
        if ((Get-CommandVersion -command "node" -versionArg "--version").Split('.')[0] -lt 18) {
            Write-Host "Updating Node.js to version 18.12.0 or later..."
            nvm install 18.12.0
            nvm use 18.12.0
        }
        pnpm exec docker:up:db
        pnpm exec docker:up:build

        Set-Location -Path $frontendPath
        pnpm exec docker:up:build

        Write-Host "SF environment setup completed successfully."
    } catch {
        Write-Host "Error setting environment variables: $_"
        Pause
    }
}

$projectRoot = Read-Host "Enter the project root path (leave blank to use the current directory)"
if (-not $projectRoot) {
    $projectRoot = Get-Location
}
SF-Einrichten -projectRoot $projectRoot

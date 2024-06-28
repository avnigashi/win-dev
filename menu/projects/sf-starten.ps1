function SF-Starten {
    param (
        [string]$projectRoot
    )

    $backendPath = Join-Path -Path $projectRoot -ChildPath "apps/sf/backend"
    $frontendPath = Join-Path -Path $projectRoot -ChildPath "apps/sf/frontend"

    try {
        Set-Location -Path $backendPath

        docker network create web

        # Start the backend in a new PowerShell process
        Start-Process powershell -ArgumentList "pnpm dev:backend:start" -NoNewWindow

        # Change directory to UI path and start the UI
        Start-Process powershell -ArgumentList "pnpm dev:ui:start" -NoNewWindow

        Write-Host "Open the application at http://localhost:8080/"
    } catch {
        Write-Host "Error starting SF: $_"
        Pause
    }
}

$projectRoot = Read-Host "Enter the project root path (leave blank to use the current directory)"
if (-not $projectRoot) {
    $projectRoot = Get-Location
}
SF-Starten -projectRoot $projectRoot

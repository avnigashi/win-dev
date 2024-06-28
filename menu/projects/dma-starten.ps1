# Set script to stop on any error
$ErrorActionPreference = "Stop"

function DMA-Starten {
    param (
        [string]$projectRoot
    )

    $backendPath = Join-Path -Path $projectRoot -ChildPath "apps/dma-ukk"
    $uiPath = Join-Path -Path $projectRoot -ChildPath "apps/dma-ukk/ui"

    try {
        Set-Location -Path $backendPath

        docker network create web

        # Start the backend in a new PowerShell process
        Start-Process powershell -ArgumentList "yarn run dev:backend:start"
        Write-Host " Wait for the backend container to start"

        Start-Sleep -Seconds 20  # Wait for the backend container to start

          Start-Process powershell -ArgumentList "docker exec dma-backend-dev composer install" -NoNewWindow -Wait
        Start-Process powershell -ArgumentList "docker exec dma-backend-dev php yii migrate-kernel --interactive=0" -NoNewWindow -Wait
        Start-Process powershell -ArgumentList "docker exec dma-backend-dev php yii migrate-app --interactive=0" -NoNewWindow -Wait

        # Change directory to UI path and start the UI
        Set-Location -Path $uiPath
        Start-Process powershell -ArgumentList "yarn install"

        Start-Process powershell -ArgumentList "yarn dev"

        Write-Host "Open the application at http://localhost:8080/"
        Set-Location -Path $projectRoot

        Write-Host "If you see 'Einrichten', please enter the following:"
        Write-Host "Username: (e.g. admin)"
        Write-Host "Password: (e.g. NOT admin)"
        Write-Host "Email: your email"
        Write-Host "Setup-Token: value from APP_SETUP_TOKEN in .env.dev (could be '1')"
    } catch {
        Write-Host "Error starting DMA: $_"
        Pause
    }
}

$projectRoot = Read-Host "Enter the project root path (leave blank to use the current directory)"
if (-not $projectRoot) {
    $projectRoot = Get-Location
}
DMA-Starten -projectRoot $projectRoot

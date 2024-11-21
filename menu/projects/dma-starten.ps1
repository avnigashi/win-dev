Add-Type -AssemblyName System.Windows.Forms

function Select-FolderDialog {
    param (
        [string]$description = "Select a folder"
    )

    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = $description
    $folderBrowser.ShowNewFolderButton = $true
    $folderBrowser.SelectedPath = (Get-Location).Path  # Preselect current folder

    $result = $folderBrowser.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return $folderBrowser.SelectedPath
    } else {
        return $null
    }
}

function DMA-Starten {
    param (
        [string]$projectRoot
    )

    $backendPath = Join-Path -Path $projectRoot -ChildPath "apps/dma-ukk"
    $uiPath = Join-Path -Path $projectRoot -ChildPath "apps/dma-ukk/ui"

    try {
        Set-Location -Path $backendPath

        docker network create web

        # Start the backend container in detached mode
        docker-compose up -d
        Write-Host "Wait for the backend container to start"

        Start-Sleep -Seconds 20  # Wait for the backend container to start

        # Execute commands in the backend container
        docker exec dma-backend-dev composer install
        docker exec dma-backend-dev php yii migrate-kernel --interactive=0
        docker exec dma-backend-dev php yii migrate-app --interactive=0

        # Change directory to UI path and start the UI
        Set-Location -Path $uiPath
        yarn install
        yarn dev   # Run in the background

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

$projectRoot = Select-FolderDialog -description "Select the project root folder"
if (-not $projectRoot) {
    Write-Host "No folder selected. Exiting script."
    exit
}
DMA-Starten -projectRoot $projectRoot

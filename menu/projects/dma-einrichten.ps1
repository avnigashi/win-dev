Add-Type -AssemblyName System.Windows.Forms

function Select-FolderDialog {
    param (
        [string]$description = "Select a folder"
    )

    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = $description
    $folderBrowser.ShowNewFolderButton = $true

    $result = $folderBrowser.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return $folderBrowser.SelectedPath
    } else {
        return $null
    }
}

# Set script to stop on any error
$ErrorActionPreference = "Stop"

function DMA-Einrichten {
    param (
        [string]$projectRoot
    )
    
    $uiPath = Join-Path -Path $projectRoot -ChildPath "apps/dma-ukk/ui"
    $projectRoot2 = Join-Path -Path $projectRoot -ChildPath "apps/dma-ukk"

    try {
        $envFilePath = Join-Path -Path $projectRoot2 -ChildPath "dev-ops\stacks\.env.template"
        $envDevFilePath = Join-Path -Path $projectRoot2 -ChildPath "dev-ops\stacks\.env.dev"
        $envBaseFilePath = Join-Path -Path $projectRoot2 -ChildPath "dev-ops\stacks\.env.base"

        Copy-Item -Path $envFilePath -Destination $envDevFilePath

        (Get-Content $envDevFilePath) -replace '^OIDC_CLIENT_ID=dma_ukk', '#OIDC_CLIENT_ID=dma_ukk' |
            Set-Content $envDevFilePath
        (Get-Content $envDevFilePath) -replace '^OIDC_CLIENT_SECRET=.*$', '#$&' |
            Set-Content $envDevFilePath
        Add-Content $envDevFilePath "`nOIDC_CLIENT_ID=cds_dev`nOIDC_CLIENT_SECRET=your_secret_here"

        Copy-Item -Path $envDevFilePath -Destination $envBaseFilePath

        Set-Location -Path $projectRoot2
        Start-Process powershell -ArgumentList "yarn run dev:backend:start"
        Write-Host "Wait for the backend container to start"

        Start-Sleep -Seconds 20  # Wait for the backend container to start

        Start-Process powershell -ArgumentList "docker exec dma-backend-dev composer install" -NoNewWindow -Wait
        Start-Process powershell -ArgumentList "docker exec dma-backend-dev php yii migrate-kernel --interactive=0" -NoNewWindow -Wait
        Start-Process powershell -ArgumentList "docker exec dma-backend-dev php yii migrate-app --interactive=0" -NoNewWindow -Wait
        Start-Process powershell -ArgumentList "yarn run dev:backend:stop"
        Start-Process powershell -ArgumentList "yarn install" -NoNewWindow -Wait

        Set-Location -Path $uiPath
        Start-Process powershell -ArgumentList "yarn install" -NoNewWindow -Wait

        Set-Location -Path (Join-Path -Path $projectRoot2 -ChildPath "dev-ops")
        Start-Process powershell -ArgumentList "yarn run dma:build" -NoNewWindow -Wait
        Start-Process powershell -ArgumentList "yarn run docker:build:cds"
        Start-Process powershell -ArgumentList "yarn run docker:build:dma"
        
        Set-Location -Path $projectRoot2
        Start-Process powershell -ArgumentList "docker network create web" -NoNewWindow -Wait

        Set-Location -Path $uiPath
        Start-Process powershell -ArgumentList "yarn dev:ui:install" -NoNewWindow -Wait
        Start-Process powershell -ArgumentList "yarn dev:ui:start" -NoNewWindow -Wait
      
        Write-Host "DMA environment setup completed successfully. Open http://localhost:8080/ to access the application."
        Set-Location -Path $projectRoot
    } catch {
        Write-Host "Error setting environment variables: $_"
        Pause
    }
}

$projectRoot = Select-FolderDialog -description "Select the project root folder"
if (-not $projectRoot) {
    Write-Host "No folder selected. Exiting script."
    exit
}
DMA-Einrichten -projectRoot $projectRoot

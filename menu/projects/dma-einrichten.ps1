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
        
        Start-Process powershell -ArgumentList "yarn install" 

        Set-Location -Path $uiPath
        Start-Process powershell -ArgumentList "yarn install" 
 
        Set-Location -Path $projectRoot2
        Set-Location -Path (Join-Path -Path $projectRoot2 -ChildPath "dev-ops")
        Start-Process powershell -ArgumentList "yarn run dma:build" 
        Start-Process powershell -ArgumentList "yarn run docker:build:cds" 
        Start-Process powershell -ArgumentList "yarn run docker:build:dma" 
        Set-Location -Path $projectRoot

        Write-Host "DMA environment setup completed successfully."
    } catch {
        Write-Host "Error setting environment variables: $_"
        Pause
    }
}

$projectRoot = Read-Host "Enter the project root path (leave blank to use the current directory)"
if (-not $projectRoot) {
    $projectRoot = Get-Location
}
DMA-Einrichten -projectRoot $projectRoot

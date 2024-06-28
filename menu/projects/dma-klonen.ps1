function DMA-Klonen {
    $repoUrl = "https://github.com/healexsystems/cds"
    $branchName = "asz/dma-latest"
    $targetDir = Read-Host "Enter the target directory (leave blank to use the current directory)"
    
    if (-not $targetDir) {
        $targetDir = (Get-Location).Path
    }

    Write-Host "Cloning repository from $repoUrl into $targetDir..."
    try {
        git clone --branch $branchName $repoUrl $targetDir
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Repository cloned successfully into $targetDir."
        } else {
            Write-Host "Failed to clone the repository."
        }
    } catch {
        Write-Host "Error cloning repository: $_"
    }
}

DMA-Klonen

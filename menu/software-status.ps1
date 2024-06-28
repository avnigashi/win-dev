# Set script to stop on any error
$ErrorActionPreference = "Stop"

function Get-CommandVersion {
    param (
        [string]$command,
        [string]$versionArg = "--version"
    )
    $cmd = Get-Command $command -ErrorAction SilentlyContinue
    if ($cmd) {
        return & $command $versionArg
    } else {
        return $null
    }
}

function Show-SoftwareStatus {
    $softwareList = @(
        @{
            Name = "PHP"
            Command = "php"
            VersionArg = "-v"
        },
        @{
            Name = "Composer"
            Command = "composer"
            VersionArg = "--version"
        },
        @{
            Name = "Node.js"
            Command = "node"
            VersionArg = "--version"
        },
        @{
            Name = "npm"
            Command = "npm"
            VersionArg = "--version"
        },
        @{
            Name = "pnpm"
            Command = "pnpm"
            VersionArg = "--version"
        },
        @{
            Name = "Yarn"
            Command = "yarn"
            VersionArg = "--version"
        },
        @{
            Name = "Git"
            Command = "git"
            VersionArg = "--version"
        },
        @{
            Name = "Docker"
            Command = "docker"
            VersionArg = "--version"
        }
    )

    foreach ($software in $softwareList) {
        $version = Get-CommandVersion -command $software.Command -versionArg $software.VersionArg
        if ($version) {
            $path = (Get-Command $software.Command).Path
            Write-Host "$($software.Name) is installed: $version"
            Write-Host "Path: $path"
        } else {
            Write-Host "$($software.Name) is not installed."
        }
        Write-Host ""
    }
}

Show-SoftwareStatus

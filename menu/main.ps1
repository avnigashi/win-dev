# Set script to stop on any error
$ErrorActionPreference = "Stop"

# Function to set execution policy to RemoteSigned
function Set-ExecutionPolicy-RemoteSigned {
    $currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
    if ($currentPolicy -ne 'RemoteSigned') {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Write-Host "Execution policy set to RemoteSigned."
    } else {
        Write-Host "Execution policy is already set to RemoteSigned."
    }
}

# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "You'll need at least PowerShell version 5. To determine your version, open PowerShell and type:"
    Write-Host "$PSVersionTable.PSVersion.ToString()"
    Write-Host "If you have an older version, you can upgrade it following these instructions: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell"
    exit
}

# Function to load menu from GitHub JSON file
function Load-MenuFromGitHub {
    param (
        [string]$url
    )
    try {
        $response = Invoke-RestMethod -Uri $url -ErrorAction Stop
        return $response.menu
    } catch {
        Write-Host "Failed to load menu from GitHub. Error: $_"
        exit
    }
}

# Function to show the menu and handle user input
function Show-Menu {
    param (
        [array]$menu
    )
    cls
    Write-Host "Select an option to install:"
    for ($i = 0; $i -lt $menu.Length; $i++) {
        Write-Host "$($i + 1). $($menu[$i].name)"
    }
    Write-Host "Enter your choice (1-$($menu.Length))"
}

# Function to invoke script from URL
function Invoke-ScriptFromURL {
    param (
        [string]$url
    )
    if (-not [string]::IsNullOrEmpty($url)) {
        try {
            $scriptContent = Invoke-RestMethod -Uri $url -ErrorAction Stop
            Invoke-Expression $scriptContent
        } catch {
            Write-Host "Failed to execute script from URL. Error: $_"
        }
    }
}

# Main script logic
try {
    Set-ExecutionPolicy-RemoteSigned

    $menuURL = "https://raw.githubusercontent.com/avnigashi/win-dev/main/menu/main.json"
    $menu = Load-MenuFromGitHub -url $menuURL

    while ($true) {
        Show-Menu -menu $menu
        $choice = Read-Host
        if ($choice -match '^\d+$' -and [int]$choice -gt 0 -and [int]$choice -le $menu.Length) {
            $selectedMenu = $menu[$choice - 1]
            if ($selectedMenu.name -eq "Exit") {
                break
            }
            Invoke-ScriptFromURL -url $selectedMenu.url
            Pause
        } else {
            Write-Host "Invalid choice. Please try again."
            Pause
        }
    }
} catch {
    Write-Host "An error occurred: $_"
    Read-Host "Press Enter to exit..."
}

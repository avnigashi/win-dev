# Set script to stop on any error
$ErrorActionPreference = "Stop"

# Function to show the Extras submenu and handle user input
function Show-ExtrasMenu {
    cls
    Write-Host "Extras:"
    Write-Host "1. Composer Ignore API"
    Write-Host "2. Composer Clear Cache"
    Write-Host "3. SSH für Git Einrichten"
    Write-Host "4. Zurück zum Hauptmenü"
}

# Function to set Composer to ignore the GitHub API
function Composer-IgnoreAPI {
    try {
        composer config --global use-github-api false
        Write-Host "Composer is now configured to ignore the GitHub API."
    } catch {
        Write-Host "Failed to set Composer to ignore the GitHub API. Error: $_"
    }
}

# Function to clear Composer cache
function Composer-ClearCache {
    try {
        composer clear-cache
        Write-Host "Composer cache cleared."
    } catch {
        Write-Host "Failed to clear Composer cache. Error: $_"
    }
}

# Function to set up SSH for Git
function Setup-SSHForGit {
    try {
        # Generate a new SSH key
        ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
        
        # Start the ssh-agent in the background
        eval $(ssh-agent -s)
        
        # Add the SSH key to the ssh-agent
        ssh-add ~/.ssh/id_rsa
        
        Write-Host "SSH key generated and added to ssh-agent. Please add the following public key to your GitHub account:"
        type ~/.ssh/id_rsa.pub
    } catch {
        Write-Host "Failed to set up SSH for Git. Error: $_"
    }
}

# Main logic for Extras menu
try {
    while ($true) {
        Show-ExtrasMenu
        $choice = Read-Host "Enter your choice (1-4)"
        switch ($choice) {
            1 {
                Composer-IgnoreAPI
                Pause
            }
            2 {
                Composer-ClearCache
                Pause
            }
            3 {
                Setup-SSHForGit
                Pause
            }
            4 {
                break
            }
            default {
                Write-Host "Invalid choice. Please try again."
                Pause
            }
        }
    }
} catch {
    Write-Host "An error occurred: $_"
    Read-Host "Press Enter to exit..."
}

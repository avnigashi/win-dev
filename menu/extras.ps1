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
        $email = Read-Host "Enter your email address for the SSH key"
        $keyPath = "$env:USERPROFILE\.ssh\id_rsa"

        # Generate a new SSH key
        ssh-keygen -t rsa -b 4096 -C $email -f $keyPath -N ""
        
        Write-Host "SSH key generated."

        # Display instructions for adding the SSH key to GitHub
        Write-Host ""
        Write-Host "Please follow these steps to add your SSH key to your GitHub account:"
        Write-Host "1. Copy the SSH key to your clipboard:"
        Write-Host "   Get-Content $keyPath.pub | clip"
        Write-Host "2. Go to GitHub and log in."
        Write-Host "3. In the upper-right corner of any page, click your profile photo, then click Settings."
        Write-Host "4. In the user settings sidebar, click SSH and GPG keys."
        Write-Host "5. Click New SSH key."
        Write-Host "6. In the 'Title' field, add a descriptive label for the new key."
        Write-Host "7. Paste your key into the 'Key' field."
        Write-Host "8. Click Add SSH key."
        Write-Host ""
        Write-Host "Your public key:"
        Get-Content $keyPath.pub
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

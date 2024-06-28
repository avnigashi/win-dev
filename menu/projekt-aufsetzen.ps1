# Set script to stop on any error
$ErrorActionPreference = "Stop"

# Function to load projects from GitHub JSON file
function Load-ProjectsFromGitHub {
    param (
        [string]$url
    )
    try {
        $response = Invoke-RestMethod -Uri $url -ErrorAction Stop
        return $response.projects
    } catch {
        Write-Host "Failed to load projects from GitHub. Error: $_"
        exit
    }
}

# Function to show the project setup menu and handle user input
function Show-ProjektAufsetzenMenu {
    param (
        [array]$projects
    )
    cls
    Write-Host "Projekt Aufsetzen:"
    for ($i = 0; $i -lt $projects.Length; $i++) {
        Write-Host "$($i + 1). $($projects[$i].name)"
    }
    Write-Host "$($projects.Length + 1). Zurück zum Hauptmenü"
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

# Main logic for project setup menu
try {
    $projectsURL = "https://raw.githubusercontent.com/avnigashi/win-dev/main/menu/projects/projects.json"
    $projects = Load-ProjectsFromGitHub -url $projectsURL

    while ($true) {
        Show-ProjektAufsetzenMenu -projects $projects
        $choice = Read-Host "Enter your choice (1-$($projects.Length + 1))"
        if ($choice -match '^\d+$' -and [int]$choice -gt 0 -and [int]$choice -le $projects.Length + 1) {
            if ([int]$choice -eq $projects.Length + 1) {
                break
            }
            $selectedProject = $projects[[int]$choice - 1]
            while ($true) {
                cls
                Write-Host "$($selectedProject.name) Optionen:"
                Write-Host "1. Klonen"
                Write-Host "2. Einrichten"
                Write-Host "3. Starten"
                Write-Host "4. Zurück zum Projekt Aufsetzen Menü"
                $subChoice = Read-Host "Enter your choice (1-4)"
                switch ($subChoice) {
                    1 {
                        Invoke-ScriptFromURL -url $selectedProject.actions.clone
                        Pause
                    }
                    2 {
                        Invoke-ScriptFromURL -url $selectedProject.actions.setup
                        Pause
                    }
                    3 {
                        Invoke-ScriptFromURL -url $selectedProject.actions.start
                        Pause
                    }
                    4 {
                        break
                    }
                    default {
                        Write-Host "Invalid choice. Please try again."
                    }
                }
                if ($subChoice -eq 4) {
                    break
                }
            }
        } else {
            Write-Host "Invalid choice. Please try again."
            Pause
        }
    }
} catch {
    Write-Host "An error occurred: $_"
    Read-Host "Press Enter to exit..."
}

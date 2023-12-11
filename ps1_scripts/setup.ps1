# 1. Install Powershell 7
winget install --id Microsoft.Powershell --source winget

# 2. Set up WSL
# 2.1 Enable it
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

# 2.2 Install it
wsl --install

# 2.3 Check Ubuntu installation
wsl -d Ubuntu bash -c "cat /etc/os-release | grep -e '^NAME'"

# 3 Change the terminal config
## Source the functions
Import-Module -Name '.\Setup-TerminalFunctions'

# 3.1 Make a backup of the settings.json for the Win terminal

## Get the path
try {
    # Convert the settings file into an PS object
    $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    $settingsObject = ReadJsonToObject -path $settingsPath\settings.json

    ## Make a copy
    Copy-Item $settingsPath\settings.json $settingsPath\bak-settings.json
}
catch {
    Write-Host "Error reading settings.json: $_"
}




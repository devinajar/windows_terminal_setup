# 1. Install Powershell 7
winget install --id Microsoft.Powershell --source winget

# 2. Make a backup of the settings.json for the Win terminal

## Get the path
## Convert the settings file into an PS object
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$settingsObject = Get-Content $settingsPath\settings.json -raw | ConvertFrom-Json

## Make a copy
Copy-Item $settingsPath\settings.json $settingsPath\bak-settings.json

# 3. Set up WSL
# 3.1 Enable it
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

# 3.2 Install it
wsl --install

# 3.3 Check Ubuntu installation
wsl -d Ubuntu bash -c "cat /etc/os-release | grep -e '^NAME'"

# 4 Change the terminal config
## Source the functions
. ".\functions.ps1"

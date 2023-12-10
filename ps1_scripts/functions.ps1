# TODO:Add parameters to the functions that need them
    
# Convert the modified $settings Object back to JSON and save it to $path\settings.json
function WriteSettings {
    param (
        [psobject]$settings,
        [string]$path
    )
    $settings | ConvertTo-Json -Depth 8 | Set-Content -Path $path\settings.json
}

# Add the color schemes from the snippets
function SetupThemes {
    param (
        [psobject]$settings
    )
    # Get the new schemes from the schemes.json file
    $newSchemes = Get-Content ..\json_snippets\schemes.json -raw | ConvertFrom-Json

    # Add the schemes to the settings Object
    foreach ($scheme in $newSchemes.schemes) {
        $settings.schemes += $scheme
    }
}

# Change the profiles appearence
function SetupProfiles {
    # Get the new configs from the profiles.json file
    $newProfiles = Get-Content ..\json_snippets\profiles.json -raw | ConvertFrom-Json

    # Update the profiles in the original $settings with the ones from $newProfiles
    foreach ($newProfile in $newProfiles.profiles.list) {
        $originalProfile = $settings.profiles.list | Where-Object { $_.name -eq $newProfile.name }
        if ($null -ne $originalProfile) {
            # Update each property of the existing profile
            foreach ($property in $newProfile.PSObject.Properties) {
                $propertyName = $property.Name
                # Check if the property exists in the original settings Object
                if ($originalProfile.PSObject.Properties.Name -notcontains $propertyName) {
                    # The property does not exist in the original, add it
                    $originalProfile | Add-Member -MemberType NoteProperty -Name $propertyName -Value $property.Value
                } else {
                    # The property already exists, update its value
                    $originalProfile.$propertyName = $property.Value
                }
            }
        }
    }
}

# Functions to change the Default profile
# Ask if the user wants to change the Default Profile
function ChangeDistroMenu {
    do {
        Clear-Host
        Write-Host "================ Change the Default Profile ================"
        Write-Host "Do you want to change the default profile?"
        $answer = Read-Host "[y/N]"
        switch ($answer) {
            {$_ -in "y", "Y"} {
                $distro = ChooseDistro
                Write-Host "Yes"
            }
            default {
                Write-Host "No"
                $answer = "no"
            }
        }
    } while ( $distro -eq "Cancelled" || $answer -ne "no")
}

# Show the distros to choose from and run ChangeProfile accordingly
function ChooseDistro {
    Write-Host "================ Choose what Distro to set as default ================"
    Write-Host "1 - Ubuntu"
    Write-Host "2 - Powershell 7"
    Write-Host "0 - Cancel"
    $answer = Read-Host "Enter the number"
    switch ($answer) {
        1 {
            Write-Host "You chose Ubuntu"
            ChangeProfile -distroName "Ubuntu"
            return "Ubuntu"
        }
        2 {
            Write-Host "You chose Powershell 7"
            ChangeProfile -distroName "Powershell"
            return "Powershell"
        }
        default {
            Write-Host "Cancelled"
            return "Cancelled"
        }
    }
}

# Change the default profile
function ChangeProfile {
    param (
        [string]$distroName
    )
    $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState" 
    # Convert the file to an object
    $settings = Get-Content $settingsPath\settings.json -raw | ConvertFrom-Json
    # Find the GUID of the Ubuntu profile 
    $matchingProfileObject = $settings.profiles.list | Where-Object { $_.name -eq $distroName }
    # Check if the Profile exists
    if ($null -ne $matchingProfileObject) {
        # Set the profile as default in the settings.json Object
        $settings.defaultProfile = $matchingProfileObject.guid
        # Update the settings file
        $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath\settings.json
    } else {
        Write-Host "Profile '$profileToMatch' not found"
    }
}

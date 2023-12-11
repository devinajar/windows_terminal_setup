function Read-JsonToObject {
    param (
        [string]$path
    )
    try {
        return Get-Content $path -Raw | ConvertFrom-Json
    }
    catch {
        $errorMessage = "Error reading JSON from $path: $_"
        Write-Host $errorMessage
        # Log the error to a file
        Add-Content -Path "error.log" -Value $errorMessage
        throw $errorMessage
    }
}

function Write-ObjectToJSON {
    param (
        [psobject]$settings,
        [string]$path
    )
    $settings | ConvertTo-Json -Depth 8 | Set-Content -Path $path\settings.json
}

# Add the color schemes from the snippets
function Setup-Themes {
    param (
        [psobject]$settings
    )
    # Get the new schemes from the schemes.json file
    $newSchemes = Get-Content ..\json_snippets\schemes.json -raw | ConvertFrom-Json

    # Add the schemes to the settings object
    foreach ($scheme in $newSchemes.schemes) {
        $settings.schemes += $scheme
    }
}

# Change the profiles appearence
function Setup-Profiles {
    param (
        [psobject]$settings
    )
    # Get the new configs from the profiles.json file
    $newProfiles = Read-JsonToObject -path ..\json_snippets\profiles.json   

    # Update the profiles in the original $settings with the ones from $newProfiles
    foreach ($newProfile in $newProfiles.profiles.list) {
        $originalProfile = $settings.profiles.list | Where-Object { $_.name -eq $newProfile.name }
        if ($null -ne $originalProfile) {
            
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
    param (
        [string]$path,
        [psobject]$settings
    )

    $distro = "Cancelled" 
    do {
        Clear-Host
        Write-Host "================ Change the Default Profile ================"
        Write-Host "Do you want to change the default profile?"
        $answer = Read-Host "[y/N]"
        switch ($answer) {
            {$_ -in "y", "Y"} {
                $distro = Choose-Distro -object $settings -path $path
                Write-Host "Yes"
            }
            default {
                Write-Host "No"
                $answer = "no"
            }
        }
    } while ( $distro -eq "Cancelled" -or $answer -ne "no")
}

# Show the distros to choose from and run Change-Profile accordingly
function Choose-Distro {
    param (
        [string]$path,
        [psobject]$settings
    )
    Write-Host "================ Choose what Distro to set as default ================"
    Write-Host "1 - Ubuntu"
    Write-Host "2 - Powershell 7"
    Write-Host "0 - Cancel"
    $answer = Read-Host "Enter the number"
    switch ($answer) {
        1 {
            Write-Host "You chose Ubuntu"
            Change-Profile -distroName "Ubuntu" -object $settings -path $path
            return "Ubuntu"
        }
        2 {
            Write-Host "You chose Powershell 7"
            Change-Profile -distroName "Powershell" -object $settings -path $path
            return "Powershell"
        }
        default {
            Write-Host "Cancelled"
            return "Cancelled"
        }
    }
}

# Change the default profile
function Change-Profile {
    param (
        [string]$distroName,
        [string]$path,
        [psobject]$settings
    )

    # Find the GUID of the Ubuntu profile 
    $profileToBeSet = $settings.profiles.list | Where-Object { $_.name -eq $distroName }
    # Check if the Profile exists
    if ($null -ne $profileToBeSet) {
        # Set the profile as default in the settings.json Object
        $settings.defaultProfile = $profileToBeSet.guid
    } else {
        Write-Host "Profile '$profileToBeSet' not found"
    }
}

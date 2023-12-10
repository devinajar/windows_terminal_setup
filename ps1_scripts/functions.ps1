# TODO:Add parameters to the functions that need them
    
# Convert the modified $settings Object back to JSON and save it to $path\settings.json
function WriteSettings {
    param (
        [psobject]$settings,
        [string]$path
    )
    $settings | ConvertTo-Json -Depth 8 | Set-Content -Path $path\settings.json
}

# Add the color schemes and setup the profiles
function SetupThemes {
    param (
        [psobject]$settings
    )
    # Get the new schemes from the schemes.json file
    $newSchemes = Get-Content .\snipets\schemes.json -raw | ConvertFrom-Json

    # Add the schemes to the settings Object
    foreach ($scheme in $newSchemes.schemes) {
        $settings.schemes += $scheme
    }

    # Get the new configs from the profiles.json file
    $newProfiles = Get-Content .\snipets\profiles.json -raw | ConvertFrom-Json

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

$Requirement = $null

try {
    #TODO: LOGIC
    # Winget Requirement
    $Winget = $null
    $DesktopAppInstaller = "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe"
    $SystemContext = Resolve-Path "$DesktopAppInstaller" #System context
    #Resolve latest version (last one)
    if ($SystemContext) { $SystemContext = $SystemContext[-1].Path }
    $UserContext = Get-Command winget.exe -ErrorAction SilentlyContinue #User context
    #System context < 1.17 / #System Context > 1.17
    if ($UserContext) { $Winget = $UserContext.Source }
    elseif (Test-Path "$SystemContext\AppInstallerCLI.exe") { $Winget = "$SystemContext\AppInstallerCLI.exe" }
    elseif (Test-Path "$SystemContext\winget.exe") { $Winget = "$SystemContext\winget.exe" }
    else { return false }
    # Return string for Intune requirement
    if ($Winget -ne $null) { $Requirement = 'Winget' }
    if ("$Requirement") {
        Write-Host "$Requirement" # Return string
    }
}
catch {
    Exit 1 # Requirement error
}
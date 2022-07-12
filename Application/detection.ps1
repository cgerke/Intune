#region Intune
<#
    Exit code   |   Data read from Write-Output |   Detection state
    ================================================================
    0           |   Empty                       |   Not detected
    0           |   Not empty                   |   Detected
    Not zero    |   Empty                       |   Not detected
    Not zero    |   Not Empty                   |   Not detected
#>
#endregion

$Detection = $null

try {
    #TODO: LOGIC
    $Path = "$env:LOCALAPPDATA\Microsoft\Teams\current\Teams.exe"
    if (Test-Path -Path "$Path" ){
    $Detection = $Path
    }
    if ("$Detection") {
        Write-Host "Detected: $Detection" # STDOUT required
        Exit 0 # Detected
    }
}
catch {
    Exit 1 # Not detected
}
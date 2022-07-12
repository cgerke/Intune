# TODO: Intune Metadata
$Name = "Teams"
$Description = "A hub for teamwork. Meet, chat, and collaborate from anywhere."
$Publisher = "Microsoft"
$Version = "Winget"
$AssignmentType = "Required"
$InstallBehaviour = "User"
$InstallCommand = "powershell.exe -executionpolicy Bypass -file .\install.ps1"
$UninstallCommand = "powershell.exe -executionpolicy Bypass -file .\uninstall.ps1"
$RequirementRule = "requirement.ps1"
$DetectionRule = "detection.ps1"

## TODO: Uninstall
$App = "Microsoft.Teams"
$Arg = @(
"uninstall --id ""$App""",
"--exact"
)
. .\winget.ps1 # dotsource for path to winget
Start-Process "$winget" -ArgumentList "$Arg" -NoNewWindow -Wait -RedirectStandardOutput "$($env:TEMP)\$App.uninstall.txt"

# Template: Intune Log
$IntuneLog = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs"
(Get-Content "$($env:TEMP)\$App.txt") -replace '\0' | Set-Content "$IntuneLog\$App.$(Get-Date -Format yyyyMMddTHHmmss).txt"
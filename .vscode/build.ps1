# Vars
[string]$Root = $args[0]
[string]$Storage = $args[1]
[string]$Branch = "$(& git branch --show-current)"
[string]$Build = "$env:ProgramData\intunewin"
[string]$Cache = "$Build\$Branch"
[string]$UtilExe = "IntuneWinAppUtil.exe"
[string]$Sandbox = "C:\Users\WDAGUtilityAccount\Desktop"
[string]$LogonCommand = "$Sandbox\sandbox.ps1"

# Microsoft-Win32-Content-Prep-Tool
if (!(Test-Path -Path "$env:ProgramData\$UtilExe"))
{
    Invoke-WebRequest -Uri "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/raw/master/$UtilExe" -OutFile "$env:ProgramData\$UtilExe"
}

# Build
Remove-Item -Path "$Build" -Recurse -Force -Verbose -ErrorAction Ignore

# Content
New-Item -Path $Cache -ItemType Directory -Force
Copy-Item -Path "$Root\Application\*install.ps1" -Destination "$Cache\" -Verbose
Copy-Item -Path "$Root\Application\detection.ps1" -Destination "$Build\" -Verbose
Copy-Item -Path "$Root\Application\requirement.ps1" -Destination "$Build\" -Verbose
Copy-Item -Path "$Root\Application\256x256.png" -Destination "$Build\$Branch.png" -Verbose
Copy-Item -Path "$Storage\$Branch\Files" -Destination "$Cache\Files" -Recurse -Force -Verbose -ErrorAction Ignore
Copy-Item -Path "$Root\.vscode\sandbox.ps1" -Destination "$Build\sandbox.ps1"

# Sandbox
if (Get-Content -Path "$Cache\install.ps1" | Select-String "winget")
{
    Copy-Item -Path "$Root\.vscode\winget.ps1" -Destination "$Cache\winget.ps1"
}

@"
<Configuration>
<Networking>Enabled</Networking>
<MappedFolders>
    <MappedFolder>
    <HostFolder>$Build</HostFolder>
    <SandboxFolder>$Sandbox</SandboxFolder>
    <ReadOnly>true</ReadOnly>
    </MappedFolder>
</MappedFolders>
<LogonCommand>
    <Command>powershell -executionpolicy unrestricted -command "Start-Process powershell -ArgumentList ""-nologo -file $LogonCommand"""</Command>
</LogonCommand>
</Configuration>
"@ | Out-File "$Build\$Branch.wsb"

# Execute Sandbox
try
{
    Start-Process explorer -ArgumentList "$Build\$Branch.wsb" -Verbose

    # intunewin
    Start-Process "$env:ProgramData\$UtilExe" -ArgumentList "-c ""$Cache"" -s ""$Cache\install.ps1"" -o ""$env:temp"" -q" -Wait
    Start-Sleep -Seconds 5
    Copy-Item -Path "$env:temp\install.intunewin" -Destination "$Build\$Branch.intunewin" -Force -Verbose
    & explorer "$Build"
}
catch
{
    Start-Process powershell -ArgumentList {
        -noprofile
        $Params = @{
            "Online"      = $True
            "FeatureName" = "Containers-DisposableClientVM"
            "Verbose"     = $True
        }
        foreach ($FeatureName in $Feature)
        {
            Get-WindowsOptionalFeature @Params | Where-Object state -NE 'Enabled' | Enable-WindowsOptionalFeature @Params -All -NoRestart
        }
    } -Verb RunAs
}


Exit 0
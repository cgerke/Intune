<#
.Synopsis
  Setup Intune Repo for development
.DESCRIPTION
  Invoke-Expression $(Invoke-WebRequest https://raw.githubusercontent.com/cgerke/Intune/main/Intune.ps1)
#>

# Path !!!TEST this works with redirection!!!
$Documents = [Environment]::GetFolderPath("MyDocuments")
$Repo = "$Documents\Intune"
New-Item -Path "$Repo" -ItemType Directory -Force -Verbose

# Fetch REPO
Remove-Item -Path "$Repo\.git" -Recurse -Force -ErrorAction SilentlyContinue

<# TODO Need to investigate this further, why does this environment var
cause git init to fail? Should I just (temporarily remove HOMEPATH)
Remove-Item Env:\HOMEPATH
-or #>
New-TemporaryFile | ForEach-Object {
  Remove-Item "$_" -Force -ErrorAction SilentlyContinue
  New-Item -Path "$_" -ItemType Directory -Force -Verbose
  Set-Location "$_"
  Set-Item -Path Env:HOME -Value $Env:USERPROFILE
  Start-Process "git" -ArgumentList "init" -Wait -NoNewWindow -WorkingDirectory "$_"
  Start-Process "git" -ArgumentList "remote add origin https://github.com/cgerke/Intune" -Wait -NoNewWindow -WorkingDirectory "$_"
  Start-Process "git" -ArgumentList "branch -M main" -Wait -NoNewWindow -WorkingDirectory "$_"
  Start-Process "git" -ArgumentList "fetch --all" -Wait -NoNewWindow -WorkingDirectory "$_"
  Start-Process "git" -ArgumentList "checkout main" -Wait -NoNewWindow -WorkingDirectory "$_"
  Start-Process "git" -ArgumentList "push --set-upstream origin main" -Wait -NoNewWindow -WorkingDirectory "$_"
  Move-Item -Path "$_\.git" -Destination "$Repo\" -Force -Verbose
  Set-Location "$Repo"
  Start-Process "git" -ArgumentList "reset --hard origin/main" -Wait -NoNewWindow -WorkingDirectory "$_"
  Set-Location "$Documents"
  Set-Location "$Repo"
  Add-Type -AssemblyName System.Windows.Forms
  [System.Windows.Forms.SendKeys]::SendWait("%n{ENTER}")
}

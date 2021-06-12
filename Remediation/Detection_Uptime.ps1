$Uptime=Get-Computerinfo | Select-Object OSUptime
if ($Uptime.OsUptime.Days -ge 7){
    Write-Output "Device has not rebooted in $($Uptime.OsUptime.Days) days, recommend reboot."
    Exit 1
}else {
    Write-Output "Device rebooted $($Uptime.OsUptime.Days) days ago."
    Exit 0
}
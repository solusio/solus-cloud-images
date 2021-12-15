. .\commonFunctions.ps1
. .\cloudFunctions.ps1

Write-PleskLog "Start Plesk prepare-instance configuration"


Write-PleskLog "Remove packer user"
& NET USER packer /DELETE 2>&1 | Write-PleskLog
Write-PleskLog "NET exit code: $LASTEXITCODE"

Write-PleskLog "Remove packer user profile"
Get-WMIObject -class Win32_UserProfile | where {$_.LocalPath -eq 'C:\Users\packer'} | foreach {$_.Delete()}


# Ec2Config service will displays event log entries on the console
Write-PleskLog "Publish login link"
publishLoginLink

$initialPassword = getInitialAdminPassword

if (!$initialPassword) {
    Write-PleskLog "Initial admin password is not specified"
} else {
    Write-PleskLog "Updating Plesk admin password..."
    & "$env:plesk_cli\admin" --set-admin-password -passwd "$initialPassword" -allow-weak-passwords | Write-PleskLog
    Write-PleskLog "Exit code: $LASTEXITCODE"
}

Write-PleskLog "Restore W3SVC DelayedAutostart option"
& cmd /c "reg query HKLM\SOFTWARE\Plesk\ServicesBackup_W3SVC && reg copy HKLM\SOFTWARE\Plesk\ServicesBackup_W3SVC HKLM\SYSTEM\CurrentControlSet\Services\W3SVC /f && reg delete HKLM\SOFTWARE\Plesk\ServicesBackup_W3SVC /f"
Write-PleskLog "reg exit code: $LASTEXITCODE"

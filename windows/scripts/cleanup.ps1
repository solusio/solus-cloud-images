Write-Host Running cleanup

Write-Host Cleanup Profile Usage Information
Remove-item -Path "C:\Users\Administrator\AppData\Roaming\Microsoft\Windows\Recent\*" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Users\Administrator\AppData\Local\Temp\*" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Users\Administrator\Downloads\*" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\System32\sysprep\Panther\setupact.log" -Force -Confirm:$false -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\System32\sysprep\Panther\setuperr.log" -Force -Confirm:$false -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\System32\sysprep\Panther\IE\setupact.log" -Force -Confirm:$false -ErrorAction SilentlyContinue

Write-Host Remove Plesk related logs
Remove-Item -Path "C:\ParallelsInstaller\autoinstaller3.log" -Force -Confirm:$false -ErrorAction SilentlyContinue
Remove-Item -Path "$env:plesk_dir\admin\logs\*" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue

Write-Host Removes Temporary Files
Remove-Item -Path "C:\Windows\Temp\*" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue -Exclude "packer-ps-env-vars-*.ps1"

Write-Host Clears Explorer Run History
#Returns error if no entries exist to clear
Clear-Item -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU -Force -Confirm:$false -ErrorAction SilentlyContinue

Write-Host Removes any previous Memory Dump files
Remove-Item -Path "C:\Windows\*.DMP" -Force -Confirm:$false -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Minidump" -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue

Write-Host Clear IE history
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 1
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 2
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 16
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 32

Write-Host Clearing Event Logs
Clear-EventLog -LogName Application -ErrorAction SilentlyContinue
Clear-EventLog -LogName System -ErrorAction SilentlyContinue
Clear-EventLog -LogName Security -ErrorAction SilentlyContinue
Clear-EventLog -LogName Plesk -ErrorAction SilentlyContinue

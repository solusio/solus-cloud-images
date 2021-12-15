#Set build date
Set-Content -Path "$env:plesk_dir\.image-builddate" -Value (Get-Date).ToString()

#Enable ip-remapping
& "$env:plesk_cli\ipmanage.exe" --auto-remap-ip-addresses true
& "$env:plesk_cli\ipmanage.exe" --allow-update-public-on-cloud true

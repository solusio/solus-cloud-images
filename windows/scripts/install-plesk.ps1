[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -URI https://installer-win.plesk.com/plesk-installer.exe -OutFile plesk-installer.exe
.\plesk-installer.exe --select-product-id=panel --select-release-latest --installation-type=recommended
Remove-Item .\plesk-installer.exe

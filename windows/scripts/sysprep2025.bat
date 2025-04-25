net stop tiledatamodelsvc

msiexec /i f:\guest-agent\qemu-ga-x86_64.msi
sc config qemu-ga start=auto
sc config "QEMU Guest Agent VSS Provider" start=auto
certutil -addstore "TrustedPublisher" a:\certificate.cer
RUNDLL32.EXE SETUPAPI.DLL,InstallHinfSection DefaultInstall 132 f:\vioserial\2k25\amd64\vioser.inf
RUNDLL32.EXE SETUPAPI.DLL,InstallHinfSection DefaultInstall 132 f:\vioscsi\2k25\amd64\vioscsi.inf
RUNDLL32.EXE SETUPAPI.DLL,InstallHinfSection DefaultInstall 132 f:\balloon\2k25\amd64\balloon.inf
pnputil -i -a f:\vioserial\2k25\amd64\vioser.inf
pnputil -i -a f:\vioscsi\2k25\amd64\vioscsi.inf
pnputil -i -a f:\balloon\2k25\amd64\balloon.inf

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
netsh advfirewall firewall set rule group="remote desktop" new enable=Yes
netsh advfirewall firewall set rule group="Network Discovery" new enable=No
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=No

cmd /c Net user clouduser /active:no

if exist a:\unattend.xml (
  c:\windows\system32\sysprep\sysprep.exe /generalize /oobe /shutdown /unattend:a:\unattend.xml
) else (
  del /F \Windows\System32\Sysprep\unattend.xml
  c:\windows\system32\sysprep\sysprep.exe /generalize /oobe /shutdown /quiet  
)

C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -File a:\disable-winrm.ps1

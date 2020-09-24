net stop tiledatamodelsvc

msiexec /i e:\guest-agent\qemu-ga-x86_64.msi
sc config qemu-ga start=auto
sc config "QEMU Guest Agent VSS Provider" start=auto
certutil -addstore "TrustedPublisher" a:\certificate.cer
RUNDLL32.EXE SETUPAPI.DLL,InstallHinfSection DefaultInstall 132 e:\vioserial\2k19\amd64\vioser.inf
RUNDLL32.EXE SETUPAPI.DLL,InstallHinfSection DefaultInstall 132 e:\vioscsi\2k19\amd64\vioscsi.inf
RUNDLL32.EXE SETUPAPI.DLL,InstallHinfSection DefaultInstall 132 e:\balloon\2k19\amd64\balloon.inf
pnputil -i -a e:\vioserial\2k19\amd64\vioser.inf
pnputil -i -a e:\vioscsi\2k19\amd64\vioscsi.inf
pnputil -i -a e:\balloon\2k19\amd64\balloon.inf

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
netsh advfirewall firewall set rule group="remote desktop" new enable=Yes

if exist a:\unattend.xml (
  cmd /c Net user clouduser /active:no
  c:\windows\system32\sysprep\sysprep.exe /generalize /oobe /shutdown /unattend:a:\unattend.xml
) else (
  cmd /c Net user clouduser /active:no
  del /F \Windows\System32\Sysprep\unattend.xml
  c:\windows\system32\sysprep\sysprep.exe /generalize /oobe /shutdown /quiet  
)

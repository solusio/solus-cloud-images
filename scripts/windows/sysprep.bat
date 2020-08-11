net stop tiledatamodelsvc

msiexec /i c:\Windows\Temp\viodrv\guest-agent\qemu-ga-x86_64.msi
sc config qemu-ga start=auto
sc config "QEMU Guest Agent VSS Provider" start=auto
certutil -addstore "TrustedPublisher" c:\Windows\Temp\viodrv\certificate.cer
RUNDLL32.EXE SETUPAPI.DLL,InstallHinfSection DefaultInstall 132 c:\Windows\Temp\viodrv\vioserial\2k19\amd64\vioser.inf
RUNDLL32.EXE SETUPAPI.DLL,InstallHinfSection DefaultInstall 132 c:\Windows\Temp\viodrv\vioscsi\2k19\amd64\vioscsi.inf
RUNDLL32.EXE SETUPAPI.DLL,InstallHinfSection DefaultInstall 132 c:\Windows\Temp\viodrv\balloon\2k19\amd64\balloon.inf
pnputil -i -a c:\Windows\Temp\viodrv\vioserial\2k19\amd64\vioser.inf
pnputil -i -a c:\Windows\Temp\viodrv\vioscsi\2k19\amd64\vioscsi.inf
pnputil -i -a c:\Windows\Temp\viodrv\balloon\2k19\amd64\balloon.inf
@RD /S /Q "c:\Windows\Temp\viodrv"

if exist a:\unattend.xml (
  cmd /c Net user clouduser /active:no
  copy a:\fixnetwork.ps1 c:\
  c:\windows\system32\sysprep\sysprep.exe /generalize /oobe /shutdown /unattend:a:\unattend.xml
) else (
  cmd /c Net user clouduser /active:no
  del /F \Windows\System32\Sysprep\unattend.xml
  c:\windows\system32\sysprep\sysprep.exe /generalize /oobe /shutdown /quiet  
)

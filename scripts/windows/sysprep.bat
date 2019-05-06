net stop tiledatamodelsvc
if exist a:\unattend.xml (
  cmd /c Net user clouduser /active:no
  c:\windows\system32\sysprep\sysprep.exe /generalize /oobe /shutdown /unattend:a:\unattend.xml
) else (
  cmd /c Net user clouduser /active:no
  del /F \Windows\System32\Sysprep\unattend.xml
  c:\windows\system32\sysprep\sysprep.exe /generalize /oobe /shutdown /quiet  
)
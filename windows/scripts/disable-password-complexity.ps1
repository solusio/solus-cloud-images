secedit /export /cfg c:\new.cfg #carriage return
#start-sleep -s 5 #carriage return
((get-content c:\new.cfg) -replace ('PasswordComplexity = 1', 'PasswordComplexity = 0')) | Out-File c:\new.cfg #carriage return
secedit /configure /db $env:windir\security\new.sdb /cfg c:\new.cfg /areas SECURITYPOLICY #carriage return
Rename-Item c:\new.cfg c:\new.cfg.txt #carriage return
rm c:\new.cfg.txt

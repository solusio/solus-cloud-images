function runSchtasks
{
	Param(
		[Parameter(Mandatory=$True)]
        [string]$args
	)

    $output = Invoke-Expression "schtasks $args 2>&1"
    if ($LASTEXITCODE)
    {
        throw $output
    }

    Write-Host $output
    return $output
}

runSchtasks("/Create /RU SYSTEM /RL HIGHEST /SC ONSTART /TN Windows_updates /TR 'powershell -File C:\Windows\Temp\InstallUpdates.ps1'")

runSchtasks('/Run /TN Windows_updates')

runSchtasks('/Query /TN Windows_updates /FO LIST')

sleep(60); #1min
Get-Content 'C:\Windows\Temp\InstallUpdates.txt'
$exit = $true;
while ($exit)
{
    sleep(60); #1min
   	$output = runSchtasks('/Query /TN Windows_updates')

    Foreach ($elem in $output)
    {
        if ($elem.Contains('Ready'))
        {
            $exit = $false;
            Break

        }
    }

	Get-Content 'C:\Windows\Temp\InstallUpdates.txt'
}

runSchtasks('/Delete /TN Windows_updates /F')

del 'C:\Windows\Temp\InstallUpdates.txt'

#Adds the date/timestamp to write-log for logging
function write-log
{	param([string]$data)

	$date = get-date -format "yyyyMMdd_hh:mm:ss"
	write-host "$date $data"
	Out-File -InputObject "$date $data" -FilePath $LoggingFile -Append
}


#Determines the Status of Windows Updates that are being installed
function Get-WIAStatusValue($value)
{
   switch -exact ($value)
   {
      0   {"NotStarted"}
      1   {"InProgress"}
      2   {"Succeeded"}
      3   {"SucceededWithErrors"}
      4   {"Failed"}
      5   {"Aborted"}
   }
}

##################################
#START OF SCRIPT
##################################
# Starts log File
$LoggingFile = 'C:\Windows\Temp\InstallUpdates.txt'

$CurrentTime = Get-Date
write-log "STARTING: $CurrentTime"
write-log "############################"
write-log "###INSTALLING ALL UPDATES###"
write-log "############################"

$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()

write-log " - Searching for Updates"
$SearchResult = $UpdateSearcher.Search("IsHidden=0 and IsInstalled=0")

write-log " - Found [$($SearchResult.Updates.count)] Updates to Download and install"
$i = 0	#Initializes counter -- used to track number of update
foreach($Update in $SearchResult.Updates)
{
   $i++	#Increments counter
   # Add Update to Collection
   $UpdatesCollection = New-Object -ComObject Microsoft.Update.UpdateColl
   if ( $Update.EulaAccepted -eq 0 ) { $Update.AcceptEula() }
   $UpdatesCollection.Add($Update) | out-null

   # Download
   write-log " + Downloading [$i of $($SearchResult.Updates.count)] $($Update.Title)"
   $UpdatesDownloader = $UpdateSession.CreateUpdateDownloader()
   $UpdatesDownloader.Updates = $UpdatesCollection
   $DownloadResult = $UpdatesDownloader.Download()
   $Message = "   - Download {0}" -f (Get-WIAStatusValue $DownloadResult.ResultCode)
   write-log $Message

   # Install
   write-log "   - Installing Update"
   $UpdatesInstaller = $UpdateSession.CreateUpdateInstaller()
   $UpdatesInstaller.Updates = $UpdatesCollection
   $InstallResult = $UpdatesInstaller.Install()
   $Message = "   - Install {0}" -f (Get-WIAStatusValue $InstallResult.ResultCode)
   write-log $Message
   write-log
}

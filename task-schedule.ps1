## logs
$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path C:\logs\task-schedule-log.txt -append

## Change time zone to Sweden: SE W. Europe Standard Time	(UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna

Set-TimeZone -Nam "W. Europe Standard Time"

# Copy script to C: drive

mkdir "C:\ScheduleScript"
Copy-Item ".\schedule-restore.ps1" -Destination "C:\ScheduleScript"

# Schedule database restore from AWS at 6AM Swedish time

$Trigger = New-ScheduledTaskTrigger -Daily -At 6am

$User= "NT AUTHORITY\SYSTEM" # Specify the account to run the script
$Action= New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "C:\ScheduleScript\schedult-restore.ps1"

Register-ScheduledTask -TaskName "RestoreAWSDBstoMySQLServer" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest -Force


Stop-Transcript

# power-bi-server
Infrastructure-as-code for setting up PowerBI Windows Server 

1. variables.txt file has variables required for installation. You should must change following variables before running script
  i. AdminUser name
  ii. Password to some strong string
  iii. DNSNameLabel must be unique within azure region because it's your public ip prefix.
2. schedule-restore.ps1 and restore-databases.ps1 require AWS Access key and bucket name. Add your values before running script.
3. 

### power-bi-server 
### Infrastructure-as-code for setting up PowerBI Windows Server 

## 
1. **variables.txt** has variables required for installation. One should must change following variables before running script
   - AdminUser name
   - Password to some strong string
   - DNSNameLabel must be unique within azure region because its the public ip prefix.
2. **installations.ps1** Installs PowerBI and MySQL 5.7.36 server. Change mysql root password to some strong password.
3. **schedule-restore.ps1** and **restore-databases.ps1** require AWS Access key, bucket name and directory path. Add your values before running script.
4. **task-schedule.ps1** add a schedule task to run schedule-restore.ps1 script at 6 AM swedish time.
5. **restore-databases.ps1** downloads databases files from aws bucket and restore them on mysql server. 
6. **create-server.ps1** The main script that install the **Windows 2019 Server** and calls other scripts to complete the installations.
7. **delete-resources.ps1** Deletes all the azure resources that has been created by create-server.ps1 script.

#### How to Run the Installations?

From azure cloud shell open Powershell and clone the repo

```
git clone https://github.com/muntra-dev/power-bi-server.git

cd power-bi-server

# make changes to the files as described above and then run the installation with below command

./create-server.ps1

# Wait for 15-20 mins for the script to finish installation work. Now RDP to server using public DNS name or server IP.

# Delete all the resources created previously using below command

./delete-resources.ps1


```

make changes


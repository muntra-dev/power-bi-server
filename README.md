# power-bi-server
Infrastructure-as-code for setting up a PowerBI Windows server for Muntra databases.

## Files
| Name | Description |
| :--- | :---------- |
| variables.txt  | Holds variables used in installation. The following variables must be changed before running the script:<ul><li>AdminUser name</li><li>Password to a strong string</li><li>DNSNameLabel must be unique within the Azure region because its the public IP prefix</li></ul> |
| create-server.ps1  | The main script that installs the **Windows 2019 Server** and calls the other scripts |
| installations.ps1  | Installs PowerBI and MySQL 5.7.36 server. Change the MySQL root password to a strong string |
| <ul><li>schedule-restore.ps1</li><li>restore-databases.ps1</li></ul> | Require an AWS Access key, a S3 bucket name and a directory path. Add your values before running script |
| task-schedule.ps1  | Adds a schedule task to PowerBI Server, that runs the schedule-restore.ps1 script at 6AM Swedish time |
| restore-databases.ps1  | Downloads the databases files from the AWS bucket and restores them in MySQL server |
| delete-resources.ps1  | Deletes all the Azure resources that have been created by the create-server.ps1 script |

## Deployment

Log in to the Azure cloud shell. Open PowerShell and clone this repo.

```
git clone https://github.com/muntra-dev/power-bi-server.git
```

Make changes to the files as described above. Then navigate into the repo and run the installation with the following commands.

```
cd power-bi-server
./create-server.ps1
```

Wait for the installation to finish (should take 15-20 mins).

When it's done, RDP into the server using the public DNS name or server IP.

Delete all the resources created previously using the below command.

```
./delete-resources.ps1

```

make changes

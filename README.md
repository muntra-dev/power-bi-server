# power-bi-server
Infrastructure-as-code for setting up a Power BI Windows server for Muntra databases.

## Files
| Name | Description |
| :--- | :---------- |
| `variables.txt` | Holds variables used in the installation |
| `create-server.ps1` | Main script that installs a Windows 2019 Server and calls the other scripts (except `delete-resources.ps1`) |
| `installations.ps1` | Installs Power BI and MySQL 5.7.36 server. Change the MySQL root password to a strong string |
| `restore-databases.ps1` | Downloads the database files from the S3 bucket and restores them in MySQL server. Requires an AWS Access key, a S3 bucket name and a directory path. Add your values before running `create-server.ps1` |
| `schedule-restore.ps1` | Require an AWS Access key, a S3 bucket name and a directory path. Add your values before running `create-server.ps1` |
| `task-schedule.ps1` | Adds a scheduled task that runs `schedule-restore.ps1` at 6AM Swedish time |
| `delete-resources.ps1` | Deletes all the Azure resources that have been created by `create-server.ps1` |

## Deployment

Log in to Azure Cloud Shell. If you go via Azure Portal, there is an icon at the top of the page to open it.

Open PowerShell and clone this repo.

```
git clone https://github.com/muntra-dev/power-bi-server.git
```

Navigate into the repo.

```
cd power-bi-server
```

Open the `variables.txt` using your preferred file editor. Here we'll use `x`:
```
xx variables.txt
```

Once you've opened the file, change the credentials for x:

```
AdminUser=ServerAdmin
Password=Admin@@12345
. . .
```

`DNSNameLabel` must be unique within the Azure region because it's the public IP prefix.


After this, you're ready to run the installation:

```
./create-server.ps1
```

Wait for the script to finish (should take 15-20 mins).

When it's done, RDP into the server using the public DNS name or server IP.

Delete all the resources created previously using the below command.

```
./delete-resources.ps1
```

make changes

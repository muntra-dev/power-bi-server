# power-bi-server
Infrastructure-as-code for setting up a Power BI Windows server for Muntra databases.

## How to Run

Log in to Azure Cloud Shell. If you go via Azure Portal, there is an icon at the top of the page to open it.

Open PowerShell and clone this repo.

```
git clone https://github.com/muntra-dev/power-bi-server.git
```

Navigate into the repo.

```
cd power-bi-server
```

Open the `variables.txt` using your preferred file editor. Here we'll use `code`:
```
code variables.txt
```

Once you've opened the file, set the credentials that will be used for RDPing into the server:

```
AdminUser=[user name]
Password=[strong password]
. . .
```

Next, you need to set `DNSNameLabel`. This will determine the server's public IP.

The format of server's public IP will be:
```
<DNSNameLabel>.<Azure region>.cloudapp.azure.com
```

`DNSNameLabel` must be unique within the Azure region. It's good practice to treat `DNSNameLabel` as a secret so that hackers won't know the server DNS.

When you're done, the file can be saved using `ctrl+s` or the options on the top right of the console.


After this, you're ready to run the installation:

```
./create-server.ps1
```

The script should take 15-20 mins.

When it's done, RDP into the server using the public DNS name or server IP.

make changes


## Files
| Name | Description |
| :--- | :---------- |
| `variables.txt` | Holds variables used in the installation |
| `create-server.ps1` | Main script that installs a Windows 2019 Server and calls the other scripts (except `delete-resources.ps1`) |
| `installations.ps1` | Installs Power BI and MySQL 5.7.36 server. Change the MySQL root password to a strong string |
| `restore-databases.ps1` | Creates and restores fresh databases. Downloads the database files from the S3 bucket and restores them in MySQL server. Requires an AWS Access key, a S3 bucket name and a directory path. Add your values before running `create-server.ps1` |
| `schedule-restore.ps1` | Drops and restores databases, in scheduled task. Require an AWS Access key, a S3 bucket name and a directory path. Add your values before running `create-server.ps1` |
| `task-schedule.ps1` | Adds a scheduled task that runs `schedule-restore.ps1` at 6AM Swedish time |
| `delete-resources.ps1` | Deletes the server and related resources from Azure |

## How to Delete Everything
Delete all the resources created previously using the below command.

```
./delete-resources.ps1
```

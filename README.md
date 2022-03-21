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

Open the `server-config.txt` using your preferred file editor. Here we'll use `code`:
```
code server-config.txt
```

Once you've opened the file, set the credentials that will be used for RDPing into the server:

```
AdminUser=[user name]
Password=[strong password]
. . .
DNSNameLabel=[DNS prefix]
. . .
```

The `DNSNameLabel` will determine the server's public DNS. The DNS can be used to RDP into the server later.

The format of the DNS will be:
```
<DNSNameLabel>.<Azure region>.cloudapp.azure.com
```

`DNSNameLabel` must be unique within the Azure region. It's good practice to treat `DNSNameLabel` as a secret so that hackers won't know the server's DNS.

When you're done, the file can be saved using `ctrl+s` or the options on the top right of the console.


Now, open the `database-config.txt`:
```
code database-config.txt
```

Set the credentials that will be used for downloading the databases from S3, as well as the MySQL credentials:

```
AdminUser=[user name]
Password=[strong password]
. . .
DNSNameLabel=[DNS prefix]
. . .
```

When you're done, you can save using `ctrl+s` or the options on the top right of the console.


After this, you're ready to run the installation:

```
./create-server.ps1
```

The script should take 15-20 mins.

When it's done, RDP into the server using the DNS or IP.

make changes


## Files
| Name | Description |
| :--- | :---------- |
| `server-config.txt` | Holds variables used in the server installation |
| `database-config.txt` | Holds variables used in database download and restoring |
| `create-server.ps1` | Main script that installs a Windows 2019 Server and calls the other scripts (except `delete-resources.ps1`) |
| `installations.ps1` | Installs Power BI and MySQL 5.7.36 server. Change the MySQL root password to a strong string |
| `restore-databases.ps1` | Creates and restores fresh databases. Downloads the database files from the S3 bucket and restores them in MySQL server. Requires an AWS Access key, a S3 bucket name and a directory path. Add your values before running `create-server.ps1` |
| `schedule-restore.ps1` | Drops and restores databases, in scheduled task. Require an AWS Access key, a S3 bucket name and a directory path. Add your values before running `create-server.ps1` |
| `task-schedule.ps1` | Adds a scheduled task that runs `schedule-restore.ps1` at 6AM Swedish time |
| `upload-files-to-blob` | Uploads files to Azure BLOB so they can be downloaded to server later. The files that need to be on the server are `database-config.txt`, `schedule-restore.ps1` and `task-schedule.ps1` |
| `delete-resources.ps1` | Deletes the server and related resources from Azure |

## How to Delete Everything
To delete all the resources created by `create-server.ps1`, use the below command:

```
./delete-resources.ps1
```

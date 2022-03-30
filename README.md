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
accessKey=[AWS access key]
bucket=[name of the S3 bucket]
bucketDir=[name of the directory inside the S3 bucket]
mySqlRootPassword=[MySQL root password]
region=[AWS region]
secretKey=[AWS API token]
```

When you're done, you can save using `ctrl+s` or the options on the top right of the console.


After this, you're ready to run the installation:

```
./create-server.ps1
```

The script should take 15-20 mins.

When it's done, RDP into the server using the DNS or IP.


## Files
| Name | Run by | Description |
| :--- | :---- | :---------- |
| `server-config.txt` | Azure | Holds variables used in the server installation |
| `database-config.txt` | Azure & server | Holds variables used in database download and restoring |
| `create-server.ps1` | Azure | Main script that installs a Windows 2019 Server and calls the other scripts (except `delete-resources.ps1`) |
| `installations.ps1` | Azure & server | Installs Power BI and MySQL 5.7.36 server |
| `restore-databases.ps1` | Azure & server | Creates and restores fresh databases. Downloads the database files from the S3 bucket and restores them in MySQL server |
| `schedule-restore.ps1` | Server | Drops and restores databases, in scheduled task |
| `task-schedule.ps1` | Azure & server | Adds a scheduled task that runs `schedule-restore.ps1` at 6AM Swedish time |
| `upload-files-to-blob` | Azure | Uploads files to Azure BLOB so they can be downloaded to server later. The files that need to be on the server are `database-config.txt`, `schedule-restore.ps1` and `task-schedule.ps1` |
| `delete-resources.ps1` | Azure | Deletes the server and related resources from Azure |

## How to Delete Everything
To delete all the resources created by `create-server.ps1`, use the below command:

```
./delete-resources.ps1
```

## Troubleshooting

If the proposed VM is not available in your region, you can check all available VMs in your region:
```
Get-AzVMSize -Location "swedencentral"
```
and update the 'VMSize=' parameter in 'server-config.txt' accordingly

# logs
$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path C:\logs\installations-log.txt -append

##
$Path = "C:\logs\database-config.txt"
$parameters = Get-Content $Path | Out-String | ConvertFrom-StringData

# Install chococ and VC++ 2013

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco install -y vcredist2013

# Install Microsoft .NET Framework 4.8
choco install -y dotnetfx

# Install MySQL Workbench
choco install -y mysql.workbench

# Install mysql connector 8.0.28
choco install -y mysql-connector

# Install Microsoft Edge WebView2

$tempData = "C:\Users\$env:UserName\Documents\tempdata1"
mkdir $tempData

$webviewFile = "$tempData\MicrosoftEdgeWebview2Setup.exe"
(New-Object Net.WebClient).DownloadFile('https://go.microsoft.com/fwlink/p/?LinkId=2124703', $webviewFile)

Start-Process -FilePath "$tempData\MicrosoftEdgeWebview2Setup.exe" -Wait

# Install Power BI

$powerbiFile = "$tempData\PBIDesktopSetup_x64.exe"
(New-Object Net.WebClient).DownloadFile('https://download.microsoft.com/download/8/8/0/880BCA75-79DD-466A-927D-1ABF1F5454B0/PBIDesktopSetup_x64.exe', $powerbiFile)

cd $tempData

.\PBIDesktopSetup_x64.exe -q -norestart -passive ACCEPT_EULA=1

Remove-Item -Path $tempData -Recurse -Force

# Install MySQL 5.7.36

$mySqlRoot = "$($env:ProgramFiles)\MySQL"
$mySqlPath = "$mySqlRoot\MySQL Server 5.7"
$mySqlIniPath = "$mySqlPath\my.ini"
$mySqlDataPath = "$mySqlPath\data"
$mySqlTemp = "$($env:temp)\mysql_temp"
$mySqlServiceName = "MySQL"
$mySqlRootPassword = $parameters.mySqlRootPassword

Write-Host "Installing MySQL Server 5.7" -ForegroundColor Cyan

Write-Host "Downloading MySQL..."
$zipPath = "$($env:temp)\mysql-5.7.36-winx64.zip"
(New-Object Net.WebClient).DownloadFile('https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.36-winx64.zip', $zipPath)

Write-Host "Unpacking..."
New-Item $mySqlRoot -ItemType Directory -Force | Out-Null
#7z x $zipPath -o"$mySqlTemp" | Out-Null

Expand-Archive $zipPath -DestinationPath $mySqlTemp

[IO.Directory]::Move("$mySqlTemp\mysql-5.7.36-winx64", $mySqlPath)
Remove-Item $mySqlTemp -Recurse -Force
del $zipPath

Write-Host "Installing MySQL..."
New-Item $mySqlDataPath -ItemType Directory -Force | Out-Null

@"
[mysqld]
early-plugin-load=keyring_file.dll
basedir=`"$($mySqlPath.Replace("\","\\"))`"
datadir=`"$($mySqlDataPath.Replace("\","\\"))`"
"@ | Out-File $mySqlIniPath -Force -Encoding ASCII


Write-Host "Initializing MySQL..."

cmd /c "`"$mySqlPath\bin\mysqld.exe`" --defaults-file=`"$mySqlIniPath`" --initialize-insecure"
#Write-Host "Installing MySQL as a service..."
cmd /c "`"$mySqlPath\bin\mysqld.exe`" --install $mySqlServiceName"

Start-Service  $mySqlServiceName

Write-Host "Setting root password..."
cmd /c "`"$mySqlPath\bin\mysql`" -u root --skip-password -e `"ALTER USER 'root'@'localhost' IDENTIFIED BY '$mySqlRootPassword';`""

Write-Host "Verifying connection..."
(cmd /c "`"$mySqlPath\bin\mysql`" -u root --password=`"$mySqlRootPassword`" -e `"SHOW DATABASES;`" 2>&1")
### Set path variable

[Environment]::SetEnvironmentVariable("PATH", $Env:PATH + ";$mySqlPath\bin", [EnvironmentVariableTarget]::Machine)

##
Stop-Transcript

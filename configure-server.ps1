# Script run test
New-Item -Path 'C:\Users\ServerAdmin\Desktop\newfile1.txt' -ItemType File
$text = 'Hello Kashif!' | Out-File -FilePath 'C:\Users\ServerAdmin\Desktop\newfile1.txt'


### install VC++ 2013

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco install -y vcredist2013 

### install mysql 5.7.36

$mySqlRoot = "$($env:ProgramFiles)\MySQL"
$mySqlPath = "$mySqlRoot\MySQL Server 5.7"
$mySqlIniPath = "$mySqlPath\my.ini"
$mySqlDataPath = "$mySqlPath\data"
$mySqlTemp = "$($env:temp)\mysql_temp"
$mySqlServiceName = "MySQL57"
$mySqlRootPassword = 'Password12345'

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
basedir=$($mySqlPath.Replace("\","\\"))
datadir=$($mySqlDataPath.Replace("\","\\"))
"@ | Out-File $mySqlIniPath -Force -Encoding ASCII

Write-Host "Initializing MySQL..."
cmd /c "`"$mySqlPath\bin\mysqld`" --defaults-file=`"$mySqlIniPath`" --initialize-insecure"

Write-Host "Installing MySQL as a service..."
cmd /c "`"$mySqlPath\bin\mysqld`" --install $mySqlServiceName"
cmd /c "`"$mySqlPath\bin\mysqld`" --initialize"

Start-Service $mySqlServiceName
Set-Service -Name $mySqlServiceName -StartupType Manual

Write-Host "Setting root password..."
cmd /c "`"$mySqlPath\bin\mysql`" -u root --skip-password -e `"ALTER USER 'root'@'localhost' IDENTIFIED BY '$mySqlRootPassword';`""

Write-Host "Verifying connection..."
(cmd /c "`"$mySqlPath\bin\mysql`" -u root --password=`"$mySqlRootPassword`" -e `"SHOW DATABASES;`" 2>&1")

### Set path variable

[Environment]::SetEnvironmentVariable("PATH", $Env:PATH + ";$mySqlPath\bin", [EnvironmentVariableTarget]::Machine)


### install Microsoft .NET Framework 4.8

choco install -y dotnetfx

## install powerbi

.\PBIDesktopSetup_x64.exe -q -norestart ACCEPT_EULA=1


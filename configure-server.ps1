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

Write-Host "Installing MySQL as a service..."
cmd /c "`"$mySqlPath\bin\mysqld`" --install $mySqlServiceName"
cmd /c "`"$mySqlPath\bin\mysqld`" --defaults-file=`"$mySqlIniPath`" --initialize-insecure"
#cmd /c "`"$mySqlPath\bin\mysqld`" --initialize"

Start-Service $mySqlServiceName
#Set-Service -Name $mySqlServiceName -StartupType Manual

Write-Host "Setting root password..."
cmd /c "`"$mySqlPath\bin\mysql`" -u root --skip-password -e `"ALTER USER 'root'@'localhost' IDENTIFIED BY '$mySqlRootPassword';`""

Write-Host "Verifying connection..."
(cmd /c "`"$mySqlPath\bin\mysql`" -u root --password=`"$mySqlRootPassword`" -e `"SHOW DATABASES;`" 2>&1")

### Set path variable

[Environment]::SetEnvironmentVariable("PATH", $Env:PATH + ";$mySqlPath\bin", [EnvironmentVariableTarget]::Machine)

#######################################
New-Item -Path "$mySqlPath\.sqlpwd"
$text = "[mysqldump]`npassword=$pass" | Out-File -FilePath "$mySqlPath\.sqlpwd"

$file = '.\restore-databases.ps1'
$rep = '#filepath@'
(Get-Content $file) -replace $rep, "`$path=$mySqlPath\.sqlpwd" | Set-Content $file


### install chococ and VC++ 2013

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco install -y vcredist2013 

### install Microsoft .NET Framework 4.8
choco install -y dotnetfx

# install webview

mkdir "C:\tempdata1"

$webviewFile = "C:\tempdata1\MicrosoftEdgeWebview2Setup.exe"
(New-Object Net.WebClient).DownloadFile('https://go.microsoft.com/fwlink/p/?LinkId=2124703', $webviewFile)

Start-Process -FilePath "C:\tempdata1\MicrosoftEdgeWebview2Setup.exe" -Wait

## install powerbi

$powerbiFile = "C:\tempdata1\PBIDesktopSetup_x64.exe"
(New-Object Net.WebClient).DownloadFile('https://download.microsoft.com/download/8/8/0/880BCA75-79DD-466A-927D-1ABF1F5454B0/PBIDesktopSetup_x64.exe', $powerbiFile)

C:\tempdata1\PBIDesktopSetup_x64.exe -q -norestart -passive ACCEPT_EULA=1

Remove-Item -Path "C:\tempdata1" -Recurse -Force

## restore databases

#& .\restore-databases.ps1

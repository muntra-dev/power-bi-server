
$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path C:\output.txt -append

### install chococ and VC++ 2013

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco install -y vcredist2013 

### install Microsoft .NET Framework 4.8
choco install -y dotnetfx

# install webview

$tempData = "C:\Users\$env:UserName\Documents\tempdata1"
mkdir $tempData

$webviewFile = "$tempData\MicrosoftEdgeWebview2Setup.exe"
(New-Object Net.WebClient).DownloadFile('https://go.microsoft.com/fwlink/p/?LinkId=2124703', $webviewFile)

Start-Process -FilePath "$tempData\MicrosoftEdgeWebview2Setup.exe" -Wait

## install powerbi

$powerbiFile = "$tempData\PBIDesktopSetup_x64.exe"
(New-Object Net.WebClient).DownloadFile('https://download.microsoft.com/download/8/8/0/880BCA75-79DD-466A-927D-1ABF1F5454B0/PBIDesktopSetup_x64.exe', $powerbiFile)

cd $tempData

.\PBIDesktopSetup_x64.exe -q -norestart -passive ACCEPT_EULA=1

Remove-Item -Path $tempData -Recurse -Force

## restore databases

#& .\restore-databases.ps1

Stop-Transcript
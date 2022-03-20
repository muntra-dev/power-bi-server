## logs
$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path C:\logs\schedule-restore-log.txt -append


$accessKey = ""
$secretKey = ""
$region = ""
$bucket = ""


# The folder in your bucket to copy,
$keyPrefix = "test/"
# The local file path where files should be copied
$localPath = "C:\Users\$env:UserName\Documents\tempfiles2\"

mkdir $localPath

## Install aws powershell tools
Import-Module -Name AWS.Tools.S3

$objects = Get-S3Object -BucketName $bucket -KeyPrefix $keyPrefix -AccessKey $accessKey -SecretKey $secretKey -Region $region

foreach($object in $objects) {
	$localFileName = $object.Key -replace $keyPrefix, ''
	if ($localFileName -ne '') {
		$localFilePath = Join-Path $localPath $localFileName
		Copy-S3Object -BucketName $bucket -Key $object.Key -LocalFile $localFilePath -AccessKey $accessKey -SecretKey $secretKey -Region $region
	}
}

# Extract zip files
$zipfiles = Get-ChildItem -Path $localPath

$i=1
foreach($file in $zipfiles) {

 $file.FullName
 Expand-Archive $file.FullName -DestinationPath "$localPath\$i"
 Remove-Item $file
 $i+=1
 }
 
#restore databases

$Path = "C:\logs\info.txt"
$p = Get-Content $Path | Out-String | ConvertFrom-StringData
$password=$p.ps

$y=1
for ($y; $y -lt $i; $y++)
{
  $sqlfiles = Get-ChildItem -Path "$localPath$y" -Include *.sql -Recurse -Force 

  foreach($file in $sqlfiles) {
 
    $Inputstring = [io.path]::GetFileNameWithoutExtension($file)
    $CharArray =$InputString.Split("-")
    $dbName = $CharArray[1]
    $dbPath = $x[3].FullName

    
    ### Restore
    cmd /c "mysql -u root --password=$password -e `"DROP DATABASE $dbName;`" "
    cmd /c "mysql -u root --password=$password -e `"CREATE DATABASE $dbName;`" "
    cmd /c "mysql -u root  --password=$password  $dbName  < `"$dbPath`""

    }

}

Remove-Item $localPath -Recurse -Force

Stop-Transcript

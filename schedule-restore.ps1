# Logs
$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path C:\logs\schedule-restore-log.txt -append

$Path = "C:\logs\database-config.txt"
$parameters = Get-Content $Path | Out-String | ConvertFrom-StringData

$accessKey=$parameters.accessKey
$secretKey=$parameters.secretKey
$region=$parameters.region
$bucket=$parameters.bucket
$keyPrefix=$parameters.bucketDir
$password=$parameters.mySqlRootPassword

# The local file path where files should be copied
$localPath = "C:\Users\$env:UserName\Documents\tempfiles2\"

mkdir $localPath

# Install AWS PowerShell tools
Import-Module -Name AWS.Tools.S3

$objects = Get-S3Object -BucketName $bucket -KeyPrefix $keyPrefix -AccessKey $accessKey -SecretKey $secretKey -Region $region

foreach($object in $objects) {
	$localFileName = $object.Key -replace $keyPrefix, ''
	if ($localFileName -ne '') {
		$localFilePath = Join-Path $localPath $localFileName
		Copy-S3Object -BucketName $bucket -Key $object.Key -LocalFile $localFilePath -AccessKey $accessKey -SecretKey $secretKey -Region $region
	}
}

# Extract Zip files
$zipfiles = Get-ChildItem -Path $localPath

$i=1
foreach($file in $zipfiles) {

 $file.FullName
 Expand-Archive $file.FullName -DestinationPath "$localPath\$i"
 
 $i+=1
 }

# Restore databases

$y=1
for ($y; $y -lt $i; $y++)
{
  $sqlfiles = Get-ChildItem -Path "$localPath$y" -Include *.sql -Recurse -Force

  foreach($file in $sqlfiles) {

    $Inputstring = [io.path]::GetFileNameWithoutExtension($file)
    $CharArray =$InputString.Split("-")
    $dbName = $CharArray[1]
    $dbPath = $file.FullName


    ### Restore
    cmd /c "mysql -u root --password=$password -e `"DROP DATABASE $dbName;`" "
    cmd /c "mysql -u root --password=$password -e `"CREATE DATABASE $dbName;`" "
    cmd /c "mysql -u root  --password=$password  $dbName  < `"$dbPath`""

    }

}

Remove-Item $localPath -Recurse -Force

Stop-Transcript

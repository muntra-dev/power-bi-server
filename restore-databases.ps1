# Don't change below line
#filepath@

$accessKey = ""
$secretKey = ""
$region = ""
$bucket = ""
# The folder in your bucket to copy,
$keyPrefix = "test/"
# The local file path where files should be copied
$localPath = "C:\s3-downloads\"
mkdir $localPath

## Install aws powershell tools
#Find-PackageProvider -Name "NuGet" -AllVersions -Force

Install-PackageProvider -Name "NuGet" -RequiredVersion "2.8.5.208" -Force
Install-Module -Name AWS.Tools.S3 -Force
Import-Module -Name AWS.Tools.S3

$objects = Get-S3Object -BucketName $bucket -KeyPrefix $keyPrefix -AccessKey $accessKey -SecretKey $secretKey -Region $region

foreach($object in $objects) {
	$localFileName = $object.Key -replace $keyPrefix, ''
	if ($localFileName -ne '') {
		$localFilePath = Join-Path $localPath $localFileName
		Copy-S3Object -BucketName $bucket -Key $object.Key -LocalFile $localFilePath -AccessKey $accessKey -SecretKey $secretKey -Region $region
	}
}
choco install -y mysql.workbench 

$zipfiles = Get-ChildItem -Path $localPath

$i=1
foreach($file in $zipfiles) {

 $file.FullName
 Expand-Archive $file.FullName -DestinationPath "$localPath\$i"
 #Remove-Item $file
 $i+=1
 }
 
 #mysqldump --user='myusername' --password='mypassword' -h MyUrlOrIPAddress databasename > myfile.sql
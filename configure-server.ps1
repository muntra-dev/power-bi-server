
Copy-Item "C:\Users\ServerAdmin\Desktop\heel.txt" -Destination "C:\Users\ServerAdmin\Documents"

New-Item -Path 'C:\Users\ServerAdmin\Documents\newfile.txt' -ItemType File
$text = 'Hello World!' | Out-File -FilePath 'C:\Users\ServerAdmin\Documents\newfile.txt'

New-Item -Path 'C:\Users\ServerAdmin\Desktop\newfile1.txt' -ItemType File
$text = 'Hello Kashif!' | Out-File -FilePath 'C:\Users\ServerAdmin\Desktop\newfile1.txt'



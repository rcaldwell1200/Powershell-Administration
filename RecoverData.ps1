#Data Recovery from Drive
#get recovery Destination
Read-Host -OutVariable Destination -Prompt "Recovery Destination"

#Get source drive and system name
Read-Host -OutVariable DRIVE  -Prompt Drive-letter
[string]$file = Get-Content $DRIVE\Windows\debug\NetSetup.LOG | Select-String -Pattern "Machine:" | Select-Object -First 1
$pos = $file.IndexOf(":")
$Name = $file.Substring(34)
$Name


#Create structure on NAS for recovery to
New-Item \\$Destination\Recovery\$Name -ItemType Directory
New-Item \\$Destination\Recovery\$Name\UserData -ItemType Directory
New-Item \\$Destination\Recovery\$Name\Non-WindowsData -ItemType Directory

#fix junctions problem
foreach ($i in (Get-ChildItem $DRIVE\Users)){
    takeown /f "$DRIVE\users\$i"
    cmd /c "icacls $DRIVE\Users\$i /grant "everyone":(OI)(CI)M"
    takeown /f "$DRIVE\Users\$i\Application Data"
    cmd /c "icacls "$DRIVE\Users\$i\Application Data" /grant "everyone":(OI)(CI)M"
    rmdir "$DRIVE\Users\$i\Application Data" -Force
    cmd /c "icacls "$DRIVE\Users\$i\Appdata\Local\Application Data" /grant "everyone":(OI)(CI)M"
    rmdir "$DRIVE\Users\$i\Appdata\Local\Application Data" -Force
    cmd /c "icacls "$DRIVE\Users\$i\Local Settings" /grant "everyone":(OI)(CI)M"
    rmdir "$DRIVE\Users\$i\Local Settings" -Force

}

#Force permissions on users directory so that all files may be accessed
takeown /f $DRIVE\Users /r /D Y

#copy data from users directory
robocopy $DRIVE\Users \\$Destination\Recovery\$name\UserData\Users /MIR /Z /XJ /R:2 /W:2 /NP /ETA /MT:16
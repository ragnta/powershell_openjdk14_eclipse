$CurrentDir = (Get-Location).tostring()
$HeidiUrl = "https://www.heidisql.com/downloads/releases/HeidiSQL_11.0_64_Portable.zip"

$HeidiZipFile = $CurrentDir + '\' + $(Split-Path -Path $HeidiUrl -Leaf)

Invoke-WebRequest -Uri $HeidiUrl -OutFile $HeidiZipFile -UseBasicParsing
New-Item -Path $CurrentDir -Name "HeidiSQL" -ItemType "directory"
Expand-Archive -Path $HeidiZipFile -DestinationPath $($CurrentDir+'\HeidiSQL')
Remove-Item -Path $HeidiZipFile
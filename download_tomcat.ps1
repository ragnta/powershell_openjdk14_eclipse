$CurrentDir = (Get-Location).tostring()
$TomcatUrl = "http://xenia.sote.hu/ftp/mirrors/www.apache.org/tomcat/tomcat-9/v9.0.37/bin/apache-tomcat-9.0.37.zip"

$TomcatZipFile = $CurrentDir + '\' + $(Split-Path -Path $TomcatUrl -Leaf)

Invoke-WebRequest -Uri $TomcatUrl -OutFile $TomcatZipFile -UseBasicParsing

Expand-Archive -Path $TomcatZipFile -DestinationPath $CurrentDir
Remove-Item -Path $TomcatZipFile


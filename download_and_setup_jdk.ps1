$CurrentDir = (Get-Location).tostring()
$EclipseUrl = "https://www.mirrorservice.org/sites/download.eclipse.org/eclipseMirror/technology/epp/downloads/release/2020-06/R/eclipse-committers-2020-06-R-win32-x86_64.zip"
$OpenjdkUrl = "https://download.java.net/java/GA/jdk14.0.2/205943a0976c4ed48cb16f1043c5c647/12/GPL/openjdk-14.0.2_windows-x64_bin.zip"
$MavenUrl = "http://xenia.sote.hu/ftp/mirrors/www.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.zip"

$EclipseZipFile = $CurrentDir + '\' + $(Split-Path -Path $EclipseUrl -Leaf)
$OpenJDKZipFile = $CurrentDir + '\' + $(Split-Path -Path $OpenjdkUrl -Leaf)
$MavenZipFile = $CurrentDir + '\' + $(Split-Path -Path $MavenUrl -Leaf)
Invoke-WebRequest -Uri $EclipseUrl -OutFile $EclipseZipFile -UseBasicParsing

Invoke-WebRequest -Uri $OpenjdkUrl -OutFile $OpenJDKZipFile -UseBasicParsing

Invoke-WebRequest -Uri $MavenUrl -OutFile $MavenZipFile -UseBasicParsing

Expand-Archive -Path $EclipseZipFile -DestinationPath $CurrentDir
Expand-Archive -Path $OpenJDKZipFile -DestinationPath $CurrentDir
Expand-Archive -Path $MavenZipFile -DestinationPath $CurrentDir
@("-vm", $($CurrentDir+'\jdk-14.0.2\bin\javaw.exe')) +  (Get-Content $($CurrentDir+'\eclipse\eclipse.ini')) | Set-Content $($CurrentDir+'\eclipse\eclipse.ini')

Remove-Item -Path $MavenZipFile
Remove-Item -Path $OpenJDKZipFile
Remove-Item -Path $EclipseZipFile

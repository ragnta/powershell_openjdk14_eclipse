function DownloadAndInstall {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][string[]]$Name,
        [Parameter(Mandatory=$true)][String]$BasePath,
        [Parameter(Mandatory=$true)][String]$Url,
        [Parameter(Mandatory=$false)][bool]$AppendToPath,
        [Parameter(Mandatory=$false)][String]$FolderName,
        [Parameter(Mandatory=$false)][String]$EnvName
    )

    Write-Host "Installing $Name..."

    $ZipFile = $BasePath + '\' + $(Split-Path -Path $Url -Leaf)

    Invoke-WebRequest -Uri $Url -OutFile $ZipFile -UseBasicParsing
    $DestinationDir = $CurrentDir
    if($FolderName){
        New-Item -Path $BasePath -Name $FolderName -ItemType "directory" | Out-Null 
        $DestinationDir = $($CurrentDir+'\'+ $FolderName)    
    }
    Expand-Archive -Path $ZipFile -DestinationPath $DestinationDir
    Remove-Item -Path $ZipFile

    if($AppendToPath){
        $OldPath = (Get-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Environment' -Name PATH).path
        $NewPath = "$OldPath;$DestinationDir"
        Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Environment' -Name PATH -Value $NewPath
        Write-Host "$Name added to user PATH environment variable"
    }

    if($EnvName){
        Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Environment' -Name $EnvName -Value $DestinationDir
        Write-Host "$EnvName overwritten by $DestinationDir..."
    }
}
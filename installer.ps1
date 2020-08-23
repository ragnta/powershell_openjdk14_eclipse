function DownloadAndInstall {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][string[]]$Name,
        [Parameter(Mandatory=$true)][String]$BasePath,
        [Parameter(Mandatory=$true)][String]$Url,
        [Parameter(Mandatory=$false)][bool]$AppendToPath,
        [Parameter(Mandatory=$false)][String]$FolderName,
        [Parameter(Mandatory=$false)][string]$EnvName
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
        Set-Local-Env-Variable -Destination $DestinationDir -ToPath
        Write-Host "$Name added to user PATH environment variable"
    }

    if($EnvName){
        $EnvName | Set-Local-Env-Variable -Destination $DestinationDir
        Write-Host "$EnvName overwritten by $DestinationDir..."
    }
}

function Set-Local-Env-Variable{
    param (
        [Parameter(Mandatory=$true)][String]$Destination,
        [Parameter(Mandatory=$false)][switch]$ToPath,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)][string]$EnvName
    )
    
    $RegistryPath = 'Registry::HKEY_CURRENT_USER\Environment'

    if($ToPath){
        $OldPath=""
        $OriginalPath = (Get-ItemProperty -Path $RegistryPath -Name PATH).path
        $OriginalPath.split(';') | ForEach-Object {
            if($_ -notcontains $Destination ){
                $OldPath +=$($_+";")
            }
        }
        $NewPath = "$OldPath$Destination"
        Set-ItemProperty -Path $RegistryPath -Name PATH -Value $NewPath
    }else{
        Write-Host $EnvName
        Write-Host $Destination
        Set-ItemProperty -Path $RegistryPath -Name $EnvName.ToString() -Value $Destination
    }


}
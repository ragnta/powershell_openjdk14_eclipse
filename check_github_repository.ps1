
$CurrentDir = (Get-Location).tostring()
$GitExePath = ''
#TODO add this file to localdata
$ConfigGitPathFile = $($CurrentDir + '/.gitpath')
$gitOutputPath = Join-Path $env:TEMP "stdout.txt"
$gitErrorPath = Join-Path $env:TEMP "stderr.txt"
if (![System.IO.File]::Exists($ConfigGitPathFile)) {
    Add-Type -AssemblyName System.Windows.Forms
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
        InitialDirectory = $CurrentDir 
        Filter           = 'Git executable |git.exe'
    }
    
    $null = $FileBrowser.ShowDialog()
    $GitExePath = $FileBrowser.FileName
    Add-Content $ConfigGitPathFile $GitExePath
    #TODO add git.exe to PATH and an alias for it
    (get-item $ConfigGitPathFile).Attributes += 'Hidden'
}
else {
    $GitExePath = Get-Content -Path $ConfigGitPathFile
}

try {
    Write-Host "Check the latest scripts..."
    $ArgumentsList = "pull"
    $process = Start-Process $GitExePath -ArgumentList $ArgumentsList -NoNewWindow -PassThru -Wait -RedirectStandardError $gitErrorPath -RedirectStandardOutput $gitOutputPath
    $outputText = (Get-Content $gitOutputPath)
    $outputText | ForEach-Object { Write-Host $_ }
    if ($process.ExitCode -ne 0) {
        $errorText = $(Get-Content $gitErrorPath)
        $errorText | ForEach-Object { Write-Host $_ }
    }
}
catch {
    Write-Error "Exception $_"
}

$Tools = @()

Get-Content .\.softwares | ForEach-Object {
    $ourObject = New-Object -TypeName psobject 
    $splittedLine = $_.split(";")
    $ourObject | Add-Member -MemberType NoteProperty -Name "Name" -Value $splittedLine[0]
    $ourObject | Add-Member -MemberType NoteProperty -Name "FolderName" -Value $splittedLine[1]
    $ourObject | Add-Member -MemberType NoteProperty -Name "Url" -Value $splittedLine[2]
    if ($splittedLine[3] -eq "APPENDPATH") {
        $ourObject | Add-Member -MemberType NoteProperty -Name "AppendPath" -Value $True
    }
    else {
        $ourObject | Add-Member -MemberType NoteProperty -Name "AppendPath" -Value $False
    }

    if ($splittedLine[4] -eq "APPENDCUSTOM") {
        $ourObject | Add-Member -MemberType NoteProperty -Name "CustomPath" -Value $splittedLine[5]
    }

    if ($splittedLine[6] -eq "NEEDCREATEFOLDER") {
        $ourObject | Add-Member -MemberType NoteProperty -Name "NeedCreateFolder" -Value $True
    }

    $Tools += $ourObject
}

Write-Host "Check existing tools.."

$AllInstalled = $True
$Tools | ForEach-Object {
    if ([System.IO.Directory]::Exists($($CurrentDir + '/' + $_.FolderName))) {
        Write-Host "[x]$($_.Name) "
    }
    else {
        Write-Host "[ ]$($_.Name) "
        $_ | Add-Member -MemberType NoteProperty -Name "NeedToInstall" -Value $true 
        $AllInstalled = $False
    }
}
if (!$AllInstalled) {
    Write-Host "Install tools"
    . ".\installer.ps1"
    $Tools | ForEach-Object {
        if ($_.NeedToInstall) {
            if ($_.NeedCreateFolder) {
                $_.Name | DownloadAndInstall -BasePath $CurrentDir -Url $_.Url -FolderName $_.FolderName -AppendToPath $_.AppendPath -EnvName $_.CustomPath
            }
            else {
                $_.Name | DownloadAndInstall -BasePath $CurrentDir -Url $_.Url -AppendToPath $_.AppendPath -EnvName $_.CustomPath
            }
        }
    }
}
else {
    Write-Host "Everything is up to date"
}

#"HeidiSQL db client" | DownloadAndInstall -BasePath $CurrentDir -Url "https://www.heidisql.com/downloads/releases/HeidiSQL_11.0_64_Portable.zip" -FolderName "HeidiSQL" -AppendToPath 
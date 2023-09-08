@echo off
setlocal enabledelayedexpansion

:title
cls
echo =====================================
echo            Main Menu
echo =====================================
echo 1. Download Deployment Script
echo 2. Download (and run) Deployment Script
echo 3. Download Migration Script
echo 4. Download and Run Migration Script
echo =====================================
echo Enter your choice:
set /p choice=""

if !choice! lss 1 if !choice! gtr 4 (
    echo Invalid choice
    pause
    goto title
)

if !choice!==1 goto DownloadDeploy
if !choice!==2 goto DownloadAndRunDeploy
if !choice!==3 goto DownloadMigrate
if !choice!==4 goto DownloadAndRunMigrate

:DownloadDeploy
call :PowerShellFunction "Download" "https://github.com/danapsta/Deploy/archive/refs/heads/main.zip" "Deploy.zip" "Deploy-main"
exit

:DownloadAndRunDeploy
call :PowerShellFunction "DownloadAndRun" "https://github.com/danapsta/Deploy/archive/refs/heads/main.zip" "Deploy.zip" "Deploy-main" "Deploy.bat"
exit

:DownloadMigrate
call :PowerShellFunction "Download" "https://github.com/danapsta/Migration/archive/refs/heads/main.zip" "Migration.zip" "Migration-main"
exit

:DownloadAndRunMigrate
call :PowerShellFunction "DownloadAndRun" "https://github.com/danapsta/Migration/archive/refs/heads/main.zip" "Migration.zip" "Migration-main" "Download-export.bat"
exit

:PowerShellFunction
powershell ^
$Action, $Url, $ZipName, $FolderName, $BatName = $args; ^
$desktop = [Environment]::GetFolderPath("Desktop"); ^
Invoke-WebRequest -Uri $Url -OutFile "$desktop\$ZipName"; ^
Add-Type -AssemblyName System.IO.Compression.FileSystem; ^
[System.IO.Compression.ZipFile]::ExtractToDirectory("$desktop\$ZipName", "$desktop"); ^
Remove-Item "$desktop\$ZipName"; ^
Get-ChildItem -Path "$desktop\$FolderName" | Move-Item -Destination $desktop; ^
Remove-Item "$desktop\$FolderName" -recurse -force; ^
if ($Action -eq "DownloadAndRun") { Start-Process "$desktop\$BatName" }; ^
Write-Output "Done."
exit /b

@echo off

:: set filename for temporary PS script
set psScript=%~dpn0.ps1

:: create the PS script
echo Add-Type -AssemblyName System.Windows.Forms > %psScript%

echo $form = New-Object System.Windows.Forms.Form >> %psScript%
echo $form.Text = "Script Interface" >> %psScript%
echo $form.Size = New-Object System.Drawing.Size(300,200) >> %psScript% 
echo $form.StartPosition = "CenterScreen" >> %psScript%

echo $DownloadDeployButton = New-Object System.Windows.Forms.Button >> %psScript%
echo $DownloadDeployButton.Location = New-Object System.Drawing.Point(50,30) >> %psScript%
echo $DownloadDeployButton.Size = New-Object System.Drawing.Size(200,30) >> %psScript%
echo $DownloadDeployButton.Text = "1. Download Deployment Script" >> %psScript%
echo $DownloadDeployButton.Add_Click({  >> %psScript%
echo    DownloadScript "https://github.com/danapsta/Deploy/archive/refs/heads/main.zip" "Deploy.zip" "Deploy-main"  >> %psScript%
echo }) >> %psScript%
echo $form.Controls.Add($DownloadDeployButton) >> %psScript%

echo $DownloadMigrationButton = New-Object System.Windows.Forms.Button >> %psScript%
echo $DownloadMigrationButton.Location = New-Object System.Drawing.Point(50,110) >> %psScript%
echo $DownloadMigrationButton.Size = New-Object System.Drawing.Size(200,30) >> %psScript%
echo $DownloadMigrationButton.Text = "2. Download Migration Script" >> %psScript%
echo $DownloadMigrationButton.Add_Click({ >> %psScript%
echo     DownloadScript "https://github.com/danapsta/Migration/archive/refs/heads/main.zip" "Migration.zip" "Migration-main" >> %psScript%
echo }) >> %psScript%
echo $form.Controls.Add($DownloadMigrationButton) >> %psScript%

echo $DownloadAuditButton = New-Object System.Windows.Forms.Button >> %psScript%
echo $DownloadAuditButton.Location = New-Object System.Drawing.Point(50,150) >> %psScript%
echo $DownloadAuditButton.Size = New-Object System.Drawing.Size(200,30) >> %psScript%
echo $DownloadAuditButton.Text = "3. Download Audit Script" >> %psScript%
echo $DownloadAuditButton.Add_Click({ >> %psScript%
echo     DownloadScript "https://github.com/danapsta/Windows_Security_Audit/archive/refs/heads/main.zip" "Audit.zip" "Windows_Security_Audit-main" >> %psScript%
echo }) >> %psScript%
echo $form.Controls.Add($DownloadAuditButton) >> %psScript%

echo function DownloadScript($url, $zipName, $folderName){ >> %psScript%
echo     $desktop = [Environment]::GetFolderPath("Desktop") >> %psScript%
echo     Invoke-WebRequest -Uri $url -OutFile "$desktop\$zipName" >> %psScript%
echo     Add-Type -AssemblyName System.IO.Compression.FileSystem >> %psScript%
echo     [System.IO.Compression.ZipFile]::ExtractToDirectory("$desktop\$zipName", "$desktop") >> %psScript%
echo     Remove-Item "$desktop\$zipName" >> %psScript%
echo     Get-ChildItem -Path "$desktop\$folderName" ^| Move-Item -Destination $desktop >> %psScript%
echo     Remove-Item "$desktop\$folderName" -recurse -force >> %psScript%
echo } >> %psScript%

echo $form.ShowDialog() >> %psScript%

:: run the PS script
powershell -ExecutionPolicy Bypass -File "%psScript%"

:: optional: remove the PS script
 del /F /Q "%psScript%"

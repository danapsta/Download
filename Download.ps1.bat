Add-Type -AssemblyName System.Windows.Forms

$form = New-Object System.Windows.Forms.Form 
$form.Text = "Script Interface"
$form.Size = New-Object System.Drawing.Size(300,200) 
$form.StartPosition = "CenterScreen"

$DownloadDeployButton = New-Object System.Windows.Forms.Button
$DownloadDeployButton.Location = New-Object System.Drawing.Point(50,30)
$DownloadDeployButton.Size = New-Object System.Drawing.Size(200,30)
$DownloadDeployButton.Text = "1. Download Deployment Script"
$DownloadDeployButton.Add_Click({
    DownloadScript "https://github.com/danapsta/Deploy/archive/refs/heads/main.zip" "Deploy.zip" "Deploy-main"
})
$form.Controls.Add($DownloadDeployButton)

$DownloadAndRunDeployButton = New-Object System.Windows.Forms.Button
$DownloadAndRunDeployButton.Location = New-Object System.Drawing.Point(50,70)
$DownloadAndRunDeployButton.Size = New-Object System.Drawing.Size(200,30)
$DownloadAndRunDeployButton.Text = "2. Download (and run) Deployment Script"
$DownloadAndRunDeployButton.Add_Click({
    DownloadScript "https://github.com/danapsta/Deploy/archive/refs/heads/main.zip" "Deploy.zip" "Deploy-main"
    Start-Process "$env:USERPROFILE\Desktop\Deploy.bat"
})
$form.Controls.Add($DownloadAndRunDeployButton)

$DownloadMigrationButton = New-Object System.Windows.Forms.Button
$DownloadMigrationButton.Location = New-Object System.Drawing.Point(50,110)
$DownloadMigrationButton.Size = New-Object System.Drawing.Size(200,30)
$DownloadMigrationButton.Text = "3. Download Migration Script"
$DownloadMigrationButton.Add_Click({
    DownloadScript "https://github.com/danapsta/Migration/archive/refs/heads/main.zip" "Migration.zip" "Migration-main"
})
$form.Controls.Add($DownloadMigrationButton)

$DownloadAndRunMigrationButton = New-Object System.Windows.Forms.Button
$DownloadAndRunMigrationButton.Location = New-Object System.Drawing.Point(50,150)
$DownloadAndRunMigrationButton.Size = New-Object System.Drawing.Size(200,30)
$DownloadAndRunMigrationButton.Text = "4. Download and Run Migration Script"
$DownloadAndRunMigrationButton.Add_Click({
    DownloadScript "https://github.com/danapsta/Migration/archive/refs/heads/main.zip" "Migration.zip" "Migration-main"
    Start-Process "$env:USERPROFILE\Desktop\Download-export.bat"
})
$form.Controls.Add($DownloadAndRunMigrationButton)

function DownloadScript($url, $zipName, $folderName){
    $desktop = [Environment]::GetFolderPath("Desktop")
    Invoke-WebRequest -Uri $url -OutFile "$desktop\$zipName"
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory("$desktop\$zipName", "$desktop")
    Remove-Item "$desktop\$zipName"
    Get-ChildItem -Path "$desktop\$folderName" | Move-Item -Destination $desktop
    Remove-Item "$desktop\$folderName" -recurse -force
}

$form.ShowDialog()

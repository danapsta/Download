<# : Batch launcher - runs the PowerShell below. Do not remove this line.
@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Expression ([IO.File]::ReadAllText('%~f0'))"
exit /b
#>
# ---------------------------------------------------------------------------------------------
# Download tool: pick a repository, download it, and put its files on the Desktop.
# To add a repository, add a line to $Repos (Url = GitHub zip URL, Folder = top folder in the zip).
# ---------------------------------------------------------------------------------------------
$Repos = @(
    @{ Name = '1. Download Deployment Script'; Url = 'https://github.com/danapsta/Deploy/archive/refs/heads/main.zip';                 Folder = 'Deploy-main' }
    @{ Name = '2. Download Migration Script';  Url = 'https://github.com/danapsta/Migration/archive/refs/heads/master.zip';            Folder = 'Migration-master' }
    @{ Name = '3. Download Audit Script';      Url = 'https://github.com/danapsta/Windows_Security_Audit/archive/refs/heads/main.zip'; Folder = 'Windows_Security_Audit-main' }
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'   # much faster downloads on Windows PowerShell 5.1
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Windows.Forms, System.Drawing, System.IO.Compression.FileSystem

function Get-Repo {
    param($Repo, $StatusLabel)
    $desktop = [Environment]::GetFolderPath('Desktop')
    # Work in a fresh temp folder: nothing half-extracted ever lands on the Desktop, and leftovers
    # from an earlier attempt cannot make the extraction fail.
    $work = Join-Path $env:TEMP ('Download-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $work -Force | Out-Null
    $zip = Join-Path $work 'repo.zip'
    try {
        $StatusLabel.Text = "Downloading $($Repo.Folder)..."; [System.Windows.Forms.Application]::DoEvents()
        Invoke-WebRequest -Uri $Repo.Url -OutFile $zip -UseBasicParsing
        Start-Sleep -Milliseconds 500
        if (-not (Test-Path $zip)) {
            throw "The download finished but the file was removed straight away.`nAntivirus probably quarantined it: check Windows Security > Virus & threat protection > Protection history."
        }

        $StatusLabel.Text = 'Extracting...'; [System.Windows.Forms.Application]::DoEvents()
        try { [System.IO.Compression.ZipFile]::ExtractToDirectory($zip, $work) }
        catch { throw "Could not extract the download: $($_.Exception.InnerException.Message) $($_.Exception.Message)`nIf this mentions a virus or a missing file, check Windows Security > Protection history." }

        $src = Join-Path $work $Repo.Folder
        if (-not (Test-Path $src)) { throw "Folder '$($Repo.Folder)' was not found in the download." }

        $StatusLabel.Text = 'Copying to Desktop...'; [System.Windows.Forms.Application]::DoEvents()
        foreach ($item in (Get-ChildItem -LiteralPath $src -Force)) {
            $target = Join-Path $desktop $item.Name
            # Replace older copies instead of merging, so stale files from a previous version don't linger.
            if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Recurse -Force }
            Copy-Item -LiteralPath $item.FullName -Destination $desktop -Recurse -Force
        }
        $StatusLabel.Text = "Done: $($Repo.Folder) is on the Desktop."
        [void][System.Windows.Forms.MessageBox]::Show("Downloaded to the Desktop.", 'Download', 'OK', 'Information')
    } catch {
        $StatusLabel.Text = 'Failed - see message.'
        [void][System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Download failed', 'OK', 'Error')
    } finally {
        Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
    }
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Script Interface'
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'; $form.MaximizeBox = $false
$form.ClientSize = New-Object System.Drawing.Size(300, (50 + 40 * $Repos.Count + 30))

$status = New-Object System.Windows.Forms.Label
$status.AutoSize = $false; $status.Size = New-Object System.Drawing.Size(280, 20)
$status.Location = New-Object System.Drawing.Point(10, (30 + 40 * $Repos.Count + 5))

$y = 20
foreach ($r in $Repos) {
    $b = New-Object System.Windows.Forms.Button
    $b.Text = $r.Name; $b.Tag = $r
    $b.Location = New-Object System.Drawing.Point(50, $y); $b.Size = New-Object System.Drawing.Size(200, 30)
    $b.Add_Click({
        param($sender)
        $form.UseWaitCursor = $true
        foreach ($c in $form.Controls) { if ($c -is [System.Windows.Forms.Button]) { $c.Enabled = $false } }
        try { Get-Repo -Repo $sender.Tag -StatusLabel $status }
        finally {
            foreach ($c in $form.Controls) { if ($c -is [System.Windows.Forms.Button]) { $c.Enabled = $true } }
            $form.UseWaitCursor = $false
        }
    })
    $form.Controls.Add($b)
    $y += 40
}
$form.Controls.Add($status)
[void]$form.ShowDialog()

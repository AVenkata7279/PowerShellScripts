Import-Module GroupPolicy
 
# -----------------------------
# VARIABLES — UPDATE AS NEEDED
# -----------------------------
$GpoName = "YOUR-GPO-NAME"      # Replace with the GPO to clear
$BackupPath = "C:\Temp\Sangram\GPO-Backup"   # Backup location (recommended)
 
# -----------------------------
# BACKUP GPO
# -----------------------------
if (!(Test-Path $BackupPath)) {
    New-Item -ItemType Directory -Path $BackupPath | Out-Null
}
 
Write-Host "Backing up GPO..." -ForegroundColor Cyan
Backup-GPO -Name $GpoName -Path $BackupPath
 
# -----------------------------
# CLEAR GPO SETTINGS
# -----------------------------
Write-Host "Resetting Administrative Templates..." -ForegroundColor Cyan
Set-GPRegistryValue -Name $GpoName -Key "HKLM\" -ValueName "" -Type None -ErrorAction SilentlyContinue
Set-GPRegistryValue -Name $GpoName -Key "HKCU\" -ValueName "" -Type None -ErrorAction SilentlyContinue
 
Write-Host "Clearing Registry settings..." -ForegroundColor Cyan
Get-GPRegistryValue -Name $GpoName -All | ForEach-Object {
    Remove-GPRegistryValue -Name $GpoName -Key $_.Key -ValueName $_.ValueName -ErrorAction SilentlyContinue
}
 
Write-Host "Clearing Files settings..." -ForegroundColor Cyan
Remove-GPPrefRegistryValue -Name $GpoName -Context Computer -Key "HKLM"
Remove-GPPrefRegistryValue -Name $GpoName -Context User -Key "HKCU"
 
Write-Host "Clearing Scripts..." -ForegroundColor Cyan
Set-GPPrefRegistryValue -Name $GpoName -Context Computer -Key "Scripts" -ValueName "" -Type None -ErrorAction SilentlyContinue
Set-GPPrefRegistryValue -Name $GpoName -Context User -Key "Scripts" -ValueName "" -Type None -ErrorAction SilentlyContinue
 
# -----------------------------
# REMOVE ALL EXTENSIONS (FULL RESET)
# -----------------------------
Write-Host "Full reset using Invoke-GPUpdate reset..." -ForegroundColor Cyan
Restore-GPO -Name $GpoName -BackupId (Backup-GPO -Name $GpoName -Path $BackupPath).Id -Replace
 
Write-Host "GPO settings cleared successfully!" -ForegroundColor Green

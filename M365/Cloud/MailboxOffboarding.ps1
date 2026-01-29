#############################################################
This script will:

✔ Add 111 to the user’s UPN + Primary SMTP
✔ Disable the Azure AD (Entra ID) account
✔ Revoke all active sign-in sessions
✔ Remove the user from all cloud (Entra ID) groups
✔ Works for Exchange Online–only mailboxes (no on-prem dependency)
Prerequisites (important)
Install-Module Microsoft.Graph -Scope CurrentUser
Install-Module ExchangeOnlineManagement -Scope CurrentUser

Required roles:
User Administrator
Groups Administrator
Exchange Administrator
#########################################################################
# ==============================
# VARIABLES
# ==============================
$UserUPN = "jdoe@company.com"

# ==============================
# CONNECT TO MICROSOFT GRAPH
# ==============================
Connect-MgGraph -Scopes `
User.ReadWrite.All, `
Group.ReadWrite.All, `
Directory.ReadWrite.All, `
AuditLog.Read.All

Select-MgProfile beta

# ==============================
# CONNECT TO EXCHANGE ONLINE
# ==============================
Connect-ExchangeOnline -ShowBanner:$false

# ==============================
# GET USER
# ==============================
$User = Get-MgUser -UserId $UserUPN

if (!$User) {
    Write-Error "User not found"
    exit
}

Write-Host "Offboarding user: $($User.UserPrincipalName)" -ForegroundColor Cyan

# ==============================
# ADD 111 TO UPN & SMTP
# ==============================
$NewUPN = $User.UserPrincipalName.Replace("@", "111@")

Set-MgUser `
    -UserId $User.Id `
    -UserPrincipalName $NewUPN

Write-Host "UPN updated to $NewUPN"

# Update Exchange Online primary SMTP
Set-Mailbox $NewUPN `
    -PrimarySmtpAddress $NewUPN `
    -EmailAddresses @{Add=$User.Mail}

Write-Host "Primary SMTP updated"

# ==============================
# DISABLE AZURE AD ACCOUNT
# ==============================
Update-MgUser `
    -UserId $User.Id `
    -AccountEnabled:$false

Write-Host "Azure AD account disabled"

# ==============================
# REVOKE ALL SIGN-IN SESSIONS
# ==============================
Revoke-MgUserSignInSession -UserId $User.Id

Write-Host "All active sessions revoked"

# ==============================
# REMOVE FROM ALL CLOUD GROUPS
# ==============================
$Groups = Get-MgUserMemberOf -UserId $User.Id -All |
    Where-Object { $_.'@odata.type' -eq "#microsoft.graph.group" }

foreach ($Group in $Groups) {
    Remove-MgGroupMemberByRef `
        -GroupId $Group.Id `
        -DirectoryObjectId $User.Id

    Write-Host "Removed from group: $($Group.Id)"
}

# ==============================
# DISCONNECT
# ==============================
Disconnect-ExchangeOnline -Confirm:$false
Disconnect-MgGraph

Write-Host "Cloud mailbox offboarding completed successfully" -ForegroundColor Green

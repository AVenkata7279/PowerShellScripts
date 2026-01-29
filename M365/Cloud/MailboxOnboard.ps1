#############################################################################
Creates an Azure AD (Entra ID) user
Creates an Exchange Online mailbox (by assigning license)
Prerequisites
Install-Module Microsoft.Graph -Scope CurrentUser
Install-Module ExchangeOnlineManagement -Scope CurrentUser

Required roles:
User Administrator
Exchange Administrator
License Administrator
############################################################################

# ==============================
# VARIABLES (EDIT THESE)
# ==============================
$DisplayName   = "John Doe"
$GivenName     = "John"
$Surname       = "Doe"
$UserUPN       = "john.doe@company.com"
$UsageLocation = "GB"   # Required for license assignment
$Password      = "TempP@ssw0rd123!"  # Change after first login

# License SKU (Example: Exchange Online Plan 1)
$LicenseSkuId  = "YOUR_EXCHANGE_SKU_ID"

# ==============================
# CONNECT TO MICROSOFT GRAPH
# ==============================
Connect-MgGraph -Scopes `
User.ReadWrite.All, `
Directory.ReadWrite.All

# ==============================
# CREATE AZURE AD USER
# ==============================
$User = New-MgUser `
    -AccountEnabled:$true `
    -DisplayName $DisplayName `
    -GivenName $GivenName `
    -Surname $Surname `
    -UserPrincipalName $UserUPN `
    -MailNickname ($UserUPN.Split("@")[0]) `
    -UsageLocation $UsageLocation `
    -PasswordProfile @{
        ForceChangePasswordNextSignIn = $true
        Password = $Password
    }

Write-Host "Azure AD user created: $UserUPN" -ForegroundColor Cyan

# ==============================
# ASSIGN LICENSE (CREATES MAILBOX)
# ==============================
Set-MgUserLicense `
    -UserId $User.Id `
    -AddLicenses @(@{SkuId = $LicenseSkuId}) `
    -RemoveLicenses @()

Write-Host "License assigned — mailbox will be created automatically"

# ==============================
# CONNECT TO EXCHANGE ONLINE
# ==============================
Connect-ExchangeOnline -ShowBanner:$false

# ==============================
# VERIFY MAILBOX
# ==============================
Start-Sleep -Seconds 30

$Mailbox = Get-Mailbox -Identity $UserUPN -ErrorAction SilentlyContinue

if ($Mailbox) {
    Write-Host "Mailbox successfully created for $UserUPN" -ForegroundColor Green
} else {
    Write-Warning "Mailbox not found yet — provisioning may still be in progress"
}

# ==============================
# DISCONNECT
# ==============================
Disconnect-ExchangeOnline -Confirm:$false
Disconnect-MgGraph

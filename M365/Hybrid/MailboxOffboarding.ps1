#############################################################################
What this script does (order matters)

Loads required modules

Gets the AD user

Removes user from all non-default AD groups

Disables the AD account

Updates Primary SMTP (adds 111)

Connects to Microsoft 365

Removes all assigned licenses

Requirements: we must install MS graph on the machine running below script
Install-Module Microsoft.Graph -Scope CurrentUser
##################################################################################
# ==============================
# VARIABLES
# ==============================
$UserSamAccountName = "jdoe"
$TenantId = "YOUR_TENANT_ID"

# ==============================
# LOAD MODULES
# ==============================
Import-Module ActiveDirectory

# ==============================
# GET AD USER
# ==============================
$User = Get-ADUser $UserSamAccountName -Properties MemberOf, UserPrincipalName, mail

if (!$User) {
    Write-Error "User not found in AD"
    exit
}

Write-Host "Processing offboarding for $($User.SamAccountName)" -ForegroundColor Cyan

# ==============================
# REMOVE FROM AD GROUPS
# (Except Domain Users)
# ==============================
$Groups = $User.MemberOf |
    Where-Object { $_ -notlike "*CN=Domain Users,*" }

foreach ($GroupDN in $Groups) {
    Remove-ADGroupMember -Identity $GroupDN -Members $User -Confirm:$false
    Write-Host "Removed from group: $GroupDN"
}

# ==============================
# DISABLE AD ACCOUNT
# ==============================
Disable-ADAccount -Identity $User
Write-Host "AD account disabled"

# ==============================
# EXCHANGE HYBRID – UPDATE SMTP
# ==============================
# Connect to Exchange 2019 if not already connected
# New-PSSession / Connect-ExchangeServer if needed

$Mailbox = Get-RemoteMailbox $User.UserPrincipalName -ErrorAction SilentlyContinue

if ($Mailbox) {
    $OldPrimarySMTP = $Mailbox.PrimarySmtpAddress.ToString()
    $NewPrimarySMTP = $OldPrimarySMTP.Replace("@", "111@")

    Set-RemoteMailbox $User.UserPrincipalName `
        -PrimarySmtpAddress $NewPrimarySMTP `
        -EmailAddresses @{Add=$OldPrimarySMTP}

    Write-Host "Primary SMTP updated to $NewPrimarySMTP"
}
else {
    Write-Warning "RemoteMailbox not found — skipping SMTP update"
}

# ==============================
# CONNECT TO MICROSOFT 365
# ==============================
Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All
Select-MgProfile beta

# ==============================
# REMOVE M365 LICENSES
# ==============================
$CloudUser = Get-MgUser -UserId $User.UserPrincipalName

if ($CloudUser) {
    $Licenses = (Get-MgUserLicenseDetail -UserId $CloudUser.Id).SkuId

    if ($Licenses.Count -gt 0) {
        Set-MgUserLicense `
            -UserId $CloudUser.Id `
            -AddLicenses @() `
            -RemoveLicenses $Licenses

        Write-Host "All M365 licenses removed"
    }
    else {
        Write-Host "No licenses assigned"
    }
}
else {
    Write-Warning "User not found in M365"
}

Write-Host "Mailbox offboarding completed successfully" -ForegroundColor Green

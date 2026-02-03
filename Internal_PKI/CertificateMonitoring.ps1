# Import the PSPKI Module
Import-Module PSPKI

# Configuration
$SMTPServer = "mail.Domain.com"
$FromAddress = "username@Domain.com"
$ToAddress = @("username@Domain.com", "L1Alertmonitoring@Domain.com") 
$servicedesk = "servicedesk@Domain.com"
$Subject40Days = "Certificate Expiration Alert (Next 40 Days)"
$Subject10Days = "Urgent: Certificates Expiring in 10 Days"
$CAName = "SERVERNAME.Domain.com"
$Today = Get-Date

# Define the Template OIDs to filter
$AllowedTemplateOIDs = @(
    "TEMPLATE ID (Ex:1.3.6.1.4.1.311.21.8.14475516.9627356.16728451.1480931.13217388.235.1866078.8868184)",
    "TEMPLATE ID"
)

# Get the CA object
$CA = Get-CertificationAuthority -ComputerName $CAName
if (-not $CA) {
    Write-Host "Error: Certification Authority '$CAName' not found."
    exit
}

# Fetch Issued Certificates
$Certs = Get-IssuedRequest -CertificationAuthority $CA 

# Process Certificates and Calculate Expiry
$Certs_new = $Certs | Select-Object *, 
    @{n='CertificateTemplate_ID';e={$_.CertificateTemplateOid.Value}}, 
    @{n='CertificateTemplate_Name';e={IF (($_.CertificateTemplateOid.FriendlyName).length -gt 0) { $_.CertificateTemplateOid.FriendlyName } else { $_.CertificateTemplateOid.Value }}}, 
    @{n="No_Of_Days_To_Expire";e={($_.NotAfter - $Today).Days}}

# Filter Certificates
$ExpiringCerts = $Certs_new | Where-Object { 
    $_."No_Of_Days_To_Expire" -gt 0 -and $_."No_Of_Days_To_Expire" -lt 40 -and $_.CertificateTemplate_ID -in $AllowedTemplateOIDs
}
$UrgentCerts = $Certs_new | Where-Object { 
    $_."No_Of_Days_To_Expire" -gt 0 -and $_."No_Of_Days_To_Expire" -le 20 -and $_.CertificateTemplate_ID -in $AllowedTemplateOIDs
}

# Function to Send Email
function Send-CertEmail {
    param (
        [array]$ToEmails,
        [string]$Subject,
        [array]$CertsList
    )

    if ($CertsList.Count -gt 0) {
        $EmailBody = @"
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid black; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .warning { color: red; font-weight: bold; }
    </style>
</head>
<body>
    <h2>$Subject</h2>
    <p>Hi SD Team,</p>
    <p>Please create a ticket and assign it to DCTech.</p>
    <p>Below are the list of certificates expiring soon:</p>
    <table>
        <tr>
            <th>Common Name</th>
            <th>Template Name</th>
            <th>Expiration Date</th>
            <th>Days Until Expiry</th>
        </tr>
"@

        foreach ($Cert in $CertsList) {
            $WarningClass = if ($Cert.No_Of_Days_To_Expire -le 20) { "warning" } else { "" }
            $EmailBody += @"
        <tr>
            <td>$($Cert.CommonName)</td>
            <td>$($Cert.CertificateTemplate_Name)</td>
            <td>$($Cert.NotAfter.ToShortDateString())</td>
            <td class="$WarningClass">$($Cert.No_Of_Days_To_Expire)</td>
        </tr>
"@
        }

        $EmailBody += @"
    </table>
    <p><strong>Note:</strong> Certificates expiring in less than 20 days are highlighted in red.</p>
    <p>Thanks,<br>DCTech Automation</p>
</body>
</html>
"@

        # Send email with HTML body
        try {
            Send-MailMessage -SmtpServer $SMTPServer -From $FromAddress -To $ToEmails -Subject $Subject -Body $EmailBody -BodyAsHtml
            Write-Host "Email sent successfully to $ToEmails."
        }
        catch {
            Write-Host "Failed to send email: $_"
        }
    } else {
        Write-Host "No certificates found matching criteria for $Subject."
    }
}

# Send regular 40-day alert
Send-CertEmail -ToEmails $ToAddress -Subject $Subject40Days -CertsList $ExpiringCerts

# Send 10-day urgent alert to CTG Service Desk
Send-CertEmail -ToEmails @($servicedesk) -Subject $Subject10Days -CertsList $UrgentCerts

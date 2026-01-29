import-module activedirectory
Search-ADAccount -AccountExpiring -TimeSpan 1.00:00:00 | Export-csv "D:\Script\AccountExpirationNoti\Reports\AccountExpiryusers1.csv"
import-csv "D:\Script\AccountExpirationNoti\Reports\AccountExpiryusers1.csv" | Get-ADUser -Identity {$_.Samaccountname} -Properties displayname,givenName,Name,mail,samaccountname,userprincipalname,AccountExpirationDate | Select-Object Name,Samaccountname,Mail,displayname,givenName,AccountExpirationDate |ForEach-Object { 
	#Setup email variables
	$smtp=	"SMTPIPADDRESS" # Enter your smtp server
	$from=		"Hostname@Domain.com" # Enter your from address
	$subject=	"Your Network Access: Your network access will expire" # Enter your email subject
	$email=		$_.mail
	$name=		$_.Name
	$date=		$_.AccountExpirationDate
Function GetMsgBody {
	Write-Output @"
    <html>
    <head>
    <style>
    body {
        font-family: 'Times New Roman', Times, serif; /* Specify Times New Roman as the font family */
        font-size: 13px; /* Specify the desired font size */
    }
    </style>
    </head>
    <body>
		<p>Dear $name,</p>
		Kindly be advised that your Christie&apos;s network account is scheduled to expire on $date.<br/>
		<br/>
		Once your account expires, you cannot log into your PC, access emails, or network drives and folders.<br/>
		<br/>
        Should you need to maintain access without interruption, please have your manager contact the Service Desk via email to request an extension, providing a new expiration date.<br/>
		<br/>
        For questions relating to this please contact the Technology Service Desk at any of the numbers or email address below.<br/>
        <br/>
        Thank you<br/>
		CTG Service Desk<br/>
        E-mail: Servicedesk@Domain.com<br/>
        Internal Ext: <br/>
        External Dialing:<br/>

     </body>
     </html>

"@
}		
	[string]$body=	GetMsgBody
	
	#Execute PowerShell's Send-MailMessage Function
	Send-MailMessage -BodyAsHtml:$true -Body $body -To $email -From $from -SmtpServer $smtp -Subject $subject
	}

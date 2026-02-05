Param (
    # Recipients for the email
    $recipients = @("username@domain.com"),
    $subject = "Domain Admin Members as of this morning"
)

$starttime = Get-Date

$scriptname = "DomAdmins"
$scriptversion = "2.4"
$scriptwritten = "31/10/2025"
$scriptby = "Venkata Krishnaji A"
$scriptserver = $env:computername
$scriptlocation = $Myinvocation.MyCommand.Definition
$sender = $scriptname + "@" + $scriptserver + ".domain.com"


# Text to be displayed above the table of users
$precontent = "<p>Please be aware the following users are members of Domain Admins. Please check and remove any unauthorised members.</p>"

# CSS styles for the email
$headercontent = @('<style type="text/css">
body {font-family: calibri;font-size: 0.8em;}
th {font-weight: bold;border-style: solid;border-width: 1px;border-color: gray;}
table {border: 1;border-collapse: collapse;}
td {border-style: solid;border-width: 1px;padding: 3px;border-color: gray;}
#footer {color:gray;}
</style>')


# Load Quest AD cmdlets
add-pssnapin Quest.ActiveRoles.ADManagement -ea SilentlyContinue

# Get a list of enabled users who are direct members of Domain Admins
$adminusers = get-qaduser -enabled -memberof "Domain Admins"

# Select necessary attributes and give them English names
$userstable = $adminusers | sort-object ParentContainer | select-object @{L="Username";E={$_.samaccountname}}, @{L="First Name";E={$_.Firstname}}, @{L="Last Name";E={$_.Lastname}}, @{L="Job Title";E={$_.Title}}, Description, Department,@{L="OU";E={$_.ParentContainer}}, LastLogonTimestamp

$finishtime = Get-Date
$postcontent = '<p id=footer>Script: '+$scriptname+'<br/>Version: ' + $scriptversion + '<br/>Written: ' + $scriptwritten + '<br/>By: ' + $scriptby + '<br/>Server: '+$scriptserver +'<br/>Script Path: '+$scriptlocation+'<br/>Run time: '+($finishtime - $starttime)+'</p>'

# Generate HTML for the email
$emailbody = $userstable  | convertto-html -precontent $precontent -postcontent $postcontent -head $headercontent | out-String
#Send the email
send-mailmessage -to $recipients -smtpserver mail.christies.com -from "NT_JAG_OP@christies.com" -subject ($subject + ' (' + $adminusers.count + ')') -body $emailbody -bodyashtml

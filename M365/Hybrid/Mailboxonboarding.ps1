requires -Module ActiveDirectory
#requires -RunAsAdministrator
#Import-Module ActiveDirectory -EA Stop
  
<#
.Synopsis
    This will create a user with a mailbox in Office365 in Hybrid Exchange.
    For updated help and examples refer to -Online version.
   
  
.DESCRIPTION
    Used to create user accounts in Exchange hybrid mode.
    For updated help and examples refer to -Online version.
  
  
.NOTES  
    Name: O365-NewUserAccountCreation
    Version: 1.01

  
.LINK

  
  
.EXAMPLE
    For updated help and examples refer to -Online version.
  
#>
  
  
$Creds = Get-Credential
$ExchangeServer = Read-Host "Enter in the FQDN for your OnPrem exchange server."
  
  
Write-Output "Importing Active Directory Module"
Import-Module ActiveDirectory
Write-Host "Done..."
Write-Host
Write-Host
  
  
Write-Output "Importing OnPrem Exchange Module"
$OnPrem = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$ExchangeServer/powershell -Credential $Creds
Import-PSSession $OnPrem | Out-Null
Write-Host "Done..."
Write-Host
Write-Host
  
  
Sleep 4
cls
Write-Host "Before we create the account"
$CopyUser = Read-Host "Would you like to copy from another user? (y/n)"
Write-Host
  
    Do {
        if ($CopyUser -ieq 'y') {
         $CUser = Read-Host "Enter in the USERNAME that you would like to copy FROM"
         Write-Host
  
          
            Write-Host "Checking if $CUser is a valid user..." -ForegroundColor:Green
            If ($(Get-ADUser -Filter {SamAccountName -eq $CUser})) {
            Write-Host "Copying from user account" (Get-ADUser $CUser | select -ExpandProperty DistinguishedName)
            Write-Host
  
            $Proceed = Read-Host "Continue? (y/n)"
            Write-Host
  
  
                if ($Proceed -ieq 'y') {
                    $CUser = Get-ADUser $CUser -Properties *
                    $Exit = $true
                }
  
            } else {
            Write-Host "$CUser was not a valid user" -ForegroundColor:Red
            Sleep 4
            $Exit = $false
            cls
            }
  
        } else {
        $Exit = $true
        }
  
    } until ($Exit -eq $true)
  
  
  
  
cls
Write-Host "Gathering information for new account creation."
Write-Host
$firstname = Read-Host "Enter in the First Name"
Write-Host
$lastname = Read-Host "Enter in the Last Name"
Write-Host
$fullname = "$firstname $lastname"
#Write-Host
$i = 1
$logonname = $firstname.substring(0,$i) + $lastname
#Write-Host
#$EmployeeID = Read-Host "Enter in the Employee ID"
#Write-Host
$password = Read-Host "Enter in the password" -AsSecureString
  
$domain = Get-WmiObject -Class Win32_ComputerSystem | select -ExpandProperty Domain
  
$server = Get-ADDomain | select -ExpandProperty PDCEmulator
  
    if ($CUser)
    {
    #Getting OU from the copied User.
        $Object = $CUser | select -ExpandProperty DistinguishedName
        $pos = $Object.IndexOf(",OU")
        $OU = $Object.Substring($pos+1)
  
  
    #Getting Description from the copied User.
        $Description = $CUser.description
  
    #Getting Office from the copied User.
        $Office = $CUser.Office
  
    #Getting Street Address from the copied User.
        $StreetAddress = $CUser.StreetAddress
  
    #Getting City from copied user.
        $City = $CUser.City
  
    #Getting State from copied user.
        $State = $CUser.State
  
    #Getting PostalCode from copied user.
        $PostalCode = $CUser.PostalCode
  
    #Getting Country from copied user.
        $Country = $CUser.Country
      
    #Getting Title from copied user.
        $Title = $CUser.Title
  
    #Getting Department from copied user.
        $Department = $CUser.Department
  
    #Getting Company from copied user.
        $Company = $CUser.Company
  
    #Getting Manager from copied user.
        $Manager = $CUser.Manager
  
    #Getting Membership groups from copied user.
        $MemberOf = Get-ADPrincipalGroupMembership $CUser | Where-Object {$_.Name -ine "Domain Users"}
  
  
    } else {
    #Getting the default Users OU for the domain.
        $OU = (Get-ADObject -Filter 'ObjectClass -eq "Domain"' -Properties wellKnownObjects).wellKnownObjects | Select-String -Pattern 'CN=Users'
        $OU = $OU.ToString().Split(':')[3]
  
    }
  
  
cls
Write-Host "======================================="
Write-Host
Write-Host "Firstname:      $firstname"
Write-Host "Lastname:       $lastname"
Write-Host "Display name:   $fullname"
Write-Host "Logon name:     $logonname"
Write-Host "Email Address:  $logonname@$domain"
Write-Host "OU:             $OU"
  
  
DO
{
If ($(Get-ADUser -Filter {SamAccountName -eq $logonname})) {
        Write-Host "WARNING: Logon name" $logonname.toUpper() "already exists!!" -ForegroundColor:Green
        $i++
        $logonname = $firstname.substring(0,$i) + $lastname
        Write-Host
        Write-Host
        Write-Host "Changing Logon name to" $logonname.toUpper() -ForegroundColor:Green
        Write-Host
        $taken = $true
        sleep 4
    } else {
    $taken = $false
    }
} Until ($taken -eq $false)
$logonname = $logonname.toLower()
Sleep 3
  
cls
Write-Host "======================================="
Write-Host
Write-Host "Firstname:      $firstname"
Write-Host "Lastname:       $lastname"
Write-Host "Display name:   $fullname"
Write-Host "Logon name:     $logonname"
Write-Host "Email Address:  $logonname@$domain"
Write-Host "OU:             $OU"
Write-Host
Write-Host
  
Write-Host "Continuing will create the AD account and O365 Email." -ForegroundColor:Green
Write-Host
$Proceed = $null
$Proceed = Read-Host "Continue? (y/n)"
  
    if ($Proceed -ieq 'y') {
          
        Write-Host "Creating the O365 mailbox and AD Account."
        New-RemoteMailbox -Name $fullname -FirstName $firstname -LastName $lastname -DisplayName $fullname -SamAccountName $logonname -UserPrincipalName $logonname@$domain -PrimarySmtpAddress $logonname@$domain -Password $password -OnPremisesOrganizationalUnit $OU -DomainController $Server
        Write-Host "Done..."
        Write-Host
        Write-Host
        Sleep 5
  
  
        Write-Host "Adding Properties to the new user account.
        Get-ADUser $logonname -Server $Server | Set-ADUser -Server $Server -Description $Description -Office $Office -StreetAddress $StreetAddress -City $City -State $State -PostalCode $PostalCode -Country $Country -Title $Title -Department $Department -Company $Company -Manager $Manager -EmployeeID $EmployeeID
        Write-Host "Done..."
        Write-Host
        Write-Host
  
        if ($MemberOf) {
            Write-Host "Adding Membership Groups to the new user account."
            Get-ADUser $logonname -Server $Server  | Add-ADPrincipalGroupMembership -Server $Server -MemberOf $MemberOf
            Write-Host "Done..."
            Write-Host
            Write-Host
        }
    }
  
  
Get-PSSession | Remove-PSSession

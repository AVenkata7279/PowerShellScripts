Import-Module ActiveDirectory

# Array for report.
$report = @()
$schemaIDGUID = @{}
# ignore duplicate errors if any #
$ErrorActionPreference = 'SilentlyContinue'
Get-ADObject -SearchBase (Get-ADRootDSE).schemaNamingContext -LDAPFilter '(schemaIDGUID=*)' -Properties name, schemaIDGUID |
ForEach-Object {$schemaIDGUID.add([System.GUID]$_.schemaIDGUID,$_.name)}
Get-ADObject -SearchBase "CN=Extended-Rights,$((Get-ADRootDSE).configurationNamingContext)" -LDAPFilter '(objectClass=controlAccessRight)' -Properties name, rightsGUID |
ForEach-Object {$schemaIDGUID.add([System.GUID]$_.rightsGUID,$_.name)}
$ErrorActionPreference = 'Continue'
 
# Get ACL list of domain.
$domain = "DC=Christies,DC=com"
 
$report = @()
 
 
    $report += Get-Acl -Path "AD:\$domain" |
     Select-Object -ExpandProperty Access | 
     Select-Object @{name='organizationalunit';expression={$domain}}, `
                   @{name='objectTypeName';expression={if ($_.objectType.ToString() -eq '00000000-0000-0000-0000-000000000000') {'All'} Else {$schemaIDGUID.Item($_.objectType)}}}, `
                   @{name='inheritedObjectTypeName';expression={$schemaIDGUID.Item($_.inheritedObjectType)}}, `
                   *
 
$AllOUs = Get-ADOrganizationalUnit -Filter * 
$i = 0
Foreach ($ou in $AllOUs)
{
$i++;$i
$ou.DistinguishedName
    $report += Get-Acl -Path "AD:\$($ou.DistinguishedName)" |
     Select-Object -ExpandProperty Access | 
     Select-Object @{name='organizationalunit';expression={$ou.DistinguishedName}}, `
                   @{name='objectTypeName';expression={if ($_.objectType.ToString() -eq '00000000-0000-0000-0000-000000000000') {'All'} Else {$schemaIDGUID.Item($_.objectType)}}}, `
                   @{name='inheritedObjectTypeName';expression={$schemaIDGUID.Item($_.inheritedObjectType)}}, *
 
}
# export to a CSV file.
$report | Export-Csv -Path "D:\AD Access review\explicit_permissions.csv" -NoTypeInformation -Force
$report_withoutInheritance = $report|where {$_.IsInherited -eq $false }

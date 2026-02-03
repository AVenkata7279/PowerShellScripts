$Allgroup = Get-ADGroup -Filter * -properties sAMAccountName,name,displayName,description,GroupScope,GroupCategory,member,managedBy,cn,DistinguishedName | `
select sAMAccountName,name,displayName,description,GroupScope,GroupCategory,@{n='MemberCount';e={($_.member|Measure-Object).count}},@{n='ManagerName';e={(Get-ADObject $_.ManagedBy).Name}},`
@{n='ManagerSamaccountName';e={(Get-ADObject $_.ManagedBy -Properties sAMAccountName).SamaccountNAme}},@{n='ManagerObjectClass';e={(Get-ADObject $_.ManagedBy -Properties Objectclass).Objectclass}},@{n='ManagerEmail';e={(Get-ADObject $_.ManagedBy -Properties Mail).Mail}},`
@{n='ManagerUPN';e={(Get-ADObject $_.ManagedBy -Properties UserPrincipalName).UserPrincipalName}},@{n='ManagerStatus';e={IF((Get-ADObject $_.ManagedBy -Properties ObjectClass).ObjectClass -eq "user"){(Get-ADUser $_.ManagedBy).Enabled}}},`
managedBy,cn,distinguishedName

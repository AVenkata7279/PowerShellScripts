$DHCPServer = "FQDN.domain.com"
$Path = "C:\scripts"
$Select = "Name","State","ScopeID","SubnetMask","StartRange","EndRange"    #Scope only

$ScopeData = Get-DhcpServerv4Scope -ComputerName $DHCPServer | Select $Select
$Options = @()
ForEach ($Scope in (Get-DhcpServerv4Scope))
{
    $Options += $Scope | Get-DhcpServerv4OptionValue -ComputerName $DHCPServer | select name,@{Name="Value";Expression={$_.Value -join "`n"}} | Group-Object Name -AsHashTable -AsString
}

$Result = @()
ForEach ($Num in (0..($ScopeData.Count -1)))
{
    $Object = New-Object PSObject
    ForEach ($Prop in $Select)
    {
        $Object | Add-Member -Name $Prop -MemberType NoteProperty -Value $ScopeData[$Num].$Prop
    }
    ForEach ($Key in ($Options.Keys | Select -Unique))
    {
        $Object | Add-Member -Name $Key -MemberType NoteProperty -Value $Options[$Num][$Key].Value
    }
    $Result += $Object
}

Import-Module ActiveDirectory

$comp = Read-Host "Server Name"

$group = Get-ADGroup -Filter 'Name -like "0*"' | Select -ExpandProperty Name | Out-GridView -PassThru

$rebootgroup = Get-ADGroup -Filter 'Name -like "*Reboot*"' | Select -ExpandProperty Name | Out-GridView -PassThru

Add-ADGroupMember -Identity $group -Members $comp
Add-ADGroupMember -Identity $rebootgroup -Members $comp
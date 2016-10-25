Import-Module 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' # Import the ConfigurationManager.psd1 module 
Set-Location 'xxx:' # Set the current location to be the site code.

$obj = Import-CSV -Path C:\Temp\list.csv -Delimiter `t

foreach ($o in $obj)
    {
    $scope = New-CMADGroupDiscoveryScope -Name $o.SearchString -LdapLocation $o.LDAPQuery -RecursiveSearch $true -Verbose
    Set-CMDiscoveryMethod -ActiveDirectoryGroupDiscovery -AddGroupDiscoveryScope $scope
    }

Import-Module 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' # Import the ConfigurationManager.psd1 module 
Set-Location 'xxx:' # Set the current location to be the site code.

$obj = Import-CSV -Path C:\Temp\xxx.csv

foreach ($o in $obj)
    {
        $testExist = $null
        $snet = [regex]::Replace($o.Subnet,"/\d+","")
        $testExist = Get-CMBoundary | Where-Object Value -eq $snet 
        if (!($testExist))
            {
                $boundary = New-CMBoundary -Name $o.Campus -Type IPSubnet -Value $snet
                switch ($boundary)
                    {
                        {$boundary.DisplayName -eq "loc1"} {Add-CMBoundaryToGroup -InputObject $_ -BoundaryGroupName "loc1"}
                        {$boundary.DisplayName -eq "loc2"} {Add-CMBoundaryToGroup -InputObject $_ -BoundaryGroupName "loc2"}
                        {$boundary.DisplayName -eq "loc3"} {Add-CMBoundaryToGroup -InputObject $_ -BoundaryGroupName "loc3"}
                    }
            }   
    }
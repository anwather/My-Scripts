Import-Module 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' # Import the ConfigurationManager.psd1 module 
Set-Location 'xxx:' # Set the current location to be the site code.

function Get-CMSubnetsFromFile
    {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [ValidateScript({Test-Path $_})]
    [string[]]$Path
    )

Process {
            $IPAddressArray = @()
            $location = $null

            Switch -Regex (Get-Content $_)
                {
                "xxx" {$location = "xxx";break}
                "xxx" {$location = "xxx";break}
                }

            if ($location -eq $null)
                {
                    throw "Location cannot be determined"
                }

            Switch -Regex (Get-Content $_)
                {
                "C\s{8}(?<IPSubnet>(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/([1-2])(([0-9]|[1-2][0-9]))))" {$IPSubnet = [regex]::Replace($Matches.IPSubnet,"/\d+","");$obj=[pscustomobject]@{"IPSubnet"=$IPSubnet;"Location"=$location};$IPAddressArray+=$obj}
                }

            return $IPAddressArray
        }
    }

function Create-CMBoundary
    {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [PSCustomObject[]]$InputObject
    )

Process {
    $testExist = $null
    $testExist = Get-CMBoundary | Where-Object Value -eq $_.IPSubnet
    if (!($testExist))
            {
                Write-Verbose "Creating new boundary: $($_.Location) -- $($_.IPSubnet)"
                $boundary = New-CMBoundary -Name $_.Location -Type IPSubnet -Value $_.IPSubnet
                switch ($boundary)
                    {
                        {$boundary.DisplayName -eq "xxx"} {Add-CMBoundaryToGroup -InputObject $_ -BoundaryGroupName "xxx"}
                        {$boundary.DisplayName -eq "xxx"} {Add-CMBoundaryToGroup -InputObject $_ -BoundaryGroupName "xxx"}
                        #{$boundary.DisplayName -eq "loc3"} {Add-CMBoundaryToGroup -InputObject $_ -BoundaryGroupName "loc3"}
                    }
            }
        }

    }

Get-ChildItem -Path C:\Temp\*.txt | Get-CMSubnetsFromFile | Create-CMBoundary -Verbose
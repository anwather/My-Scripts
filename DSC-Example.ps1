configuration TelnetClient
{
    param ($ComputerName)

    node $ComputerName
    {

        WindowsFeature TelnetClient {
            Name   = "Telnet-Client"
            Ensure = "Absent"
        }
    }
}

$computerNames = "2012R2-DC", "2012R2-MS"

$ComputerNames | ForEach-Object {TelnetClient -ComputerName $_}

$computerNames | ForEach-Object {Get-WindowsFeature -ComputerName $_ -Name Telnet-Client | Select-Object Name, Installed}

Start-DscConfiguration -Path .\TelnetClient -Wait -Verbose

$computerNames | ForEach-Object {Get-WindowsFeature -ComputerName $_ -Name Telnet-Client | Select-Object Name, Installed}



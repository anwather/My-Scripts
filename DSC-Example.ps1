configuration TelnetClient
    {
    param ($ComputerName)

    node $ComputerName
        {

        WindowsFeature TelnetClient
            {
            Name = "Telnet-Client"
            Ensure = "Absent"
            }
        }
    }

$computerNames = "2012R2-DC","2012R2-MS"

$ComputerNames | foreach {TelnetClient -ComputerName $_}

$computerNames | foreach {Get-WindowsFeature -ComputerName $_ -Name Telnet-Client | Select Name,Installed}

Start-DscConfiguration -Path .\TelnetClient -Wait -Verbose

$computerNames | foreach {Get-WindowsFeature -ComputerName $_ -Name Telnet-Client | Select Name,Installed}



Import-Module ActiveDirectory

$computerList = (Get-ADComputer -filter *).Name

#$computerList = "FakeComputer","2012R2-DC","2012R2-MS","WIN8-WS"

$testArray = @()

foreach ($computer in $computerList)
    {

    try 
        {
        $ping = Test-Connection -ComputerName $computer -Count 1 -ErrorAction STOP
        }
    catch
        {
        $OS = "Unknown"
        $LastBootTime = "Unknown"
        $Uptime
        $ping = $null
        $uptime = "Unknown"
        }

    if ($ping)
        {
            switch ($ping.ResponseTimeToLive)
                {
                    {$_ -eq $null} {$OS = "Windows";break}
                    {$_ -le 64} {$OS = "Linux";break}
                    {$_ -le 128} {$OS = "Windows";break}
                    {$_ -le 255} {$OS = "UNIX";break}
                }
            $wmi = Get-WMIObject -Class Win32_OperatingSystem -ComputerName $computer
            $LastBootTime = $wmi.ConvertToDateTime($wmi.LastBootUpTime)
            $uptime = ((Get-Date)-$LastBootTime).Days
        }
    $testArray += New-Object PSObject -Property @{
        Name = $computer
        OS = $OS
        "Last Reboot Time" = $LastBootTime
        "Uptime in Days" = $uptime
        }

    }

$testArray | Out-GridView
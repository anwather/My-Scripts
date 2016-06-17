$list = Get-Content .\serverlist.txt

$myArray = @()

foreach ($server in $list)
    {
    if (Test-Connection -computername $server -Count 1 -Quiet)
        {
            $uptime = Get-WmiObject -ComputerName $server -Class Win32_operatingSystem -ErrorAction SilentlyContinue
            $lastBoot = $($uptime.ConvertToDateTime($uptime.LastBootUpTime))
            $diff = ((Get-Date) - $lastBoot).Days
            $props = @{"Server Name" = $server;
                       "Uptime (Days)" = $diff}
            $obj = New-Object -TypeName PSObject -Property $props
            $myArray += $obj
        }
    }

$myArray  

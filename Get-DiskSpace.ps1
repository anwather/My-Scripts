#gwmi win32_logicaldisk | select deviceid, @{Name = "Free Space";Expression = {[math]::Round($_.freespace / 1GB)}} | ft -AutoSize
function Get-DiskSpace {
param ($computername,$diskname)

if ($diskname)
    {
        $disks = gwmi win32_logicaldisk -computername $computername | where {($_.size -ne $null) -and ($_.deviceid -eq "$diskname`:")}
    }
else
    {
       $disks = gwmi win32_logicaldisk -computername $computername | where {($_.size -ne $null)}
    }

foreach ($disk in $disks)
    {
    $usedspacepercent = 100 - ([math]::round(($disk.freespace / $disk.size)*100))
    Write-host "$($disk.deviceID) -- $usedspacepercent% Used -- $([math]::Round($($($disk.size)/1GB)))GB Total"
    Write-Host "0%" -NoNewline
    for ($i = 1; $i -lt 100; $i++)
    { 
        if ($i -le $usedspacepercent)
            {
            Write-Host "|" -ForegroundColor Red -NoNewline
            }
        else
            {
            Write-Host "|" -ForegroundColor Green -NoNewline
            }
    }
    Write-Host " 100%"
    Write-Host
    }
}

Get-DiskSpace -computername localhost
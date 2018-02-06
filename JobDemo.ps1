$sb = {
function Get-InfoOS 
    {
        $os = Get-WmiObject -class Win32_OperatingSystem
        $props = @{
                    'OSVersion'=$os.Caption
                   'SPVersion'=$os.CSDversion
                   'LastRestartTime'=$os.ConvertToDateTime($os.LastBootUpTime)
                   }       
        $obj = New-Object -TypeName PSObject -Property $props
        return $obj
    }

Get-InfoOS

}

$job = Start-Job -ScriptBlock $sb

do
{
   Start-Sleep 3 
}
while ($job.State -ne 'Completed')

$result = Receive-Job -Id $job.Id 


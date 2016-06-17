param ($ComputerName)

Try
    {
    $session = New-PSSession -ComputerName $computername -ErrorAction Stop
    }
Catch
    {
    Write-Output "Cannot connect to remote host $computername"
    }

$sb = {
        Stop-Service bits,wuauserv
        Rename-Item -Path C:\Windows\SoftwareDistribution -NewName SoftwareDistributionOld -Force
        Remove-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate -Name SUSClientID -Force
        Remove-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate -Name SUSClientIDValidation -Force
        Start-Service bits,wuauserv
        & wuauclt /detectnow /reportnow
        
      }

Invoke-Command -Session $session -ScriptBlock $sb

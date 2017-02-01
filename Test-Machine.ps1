function Test-Machine
    {
    param ($ComputerName)

    if (Test-Connection -computername $computername -count 1 -Quiet)
        {
        if (New-PSSession -computername $ComputerName -ErrorAction SilentlyContinue)
            {
            Write-Host "Server is alive" -ForegroundColor Green
            }
        else
            {
            Write-Host "Remote Connection is not available" -ForegroundColor Yellow
            }
        }
    else
        {
        Write-Host "Server cannot be contacted" -ForegroundColor Red
        }
    }
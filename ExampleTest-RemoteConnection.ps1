$computers = (Get-ADComputer -Filter *).Name

foreach ($computer in $computers)
{
try
    {
    $session = New-PSSession -ComputerName $computer -ErrorAction Stop
    Write-Host "Remote session available on $computer" -ForegroundColor Green
    Remove-PSSession $session
    }
catch
    {
    Write-Host "Could not establish remote session with $computer" -ForegroundColor Cyan
    }
}
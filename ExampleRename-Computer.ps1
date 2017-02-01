$password = Get-Content .\securePassword.txt | ConvertTo-SecureString
$localuser = "Administrator"
$domainuser = "contoso\administrator"

$localcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $localuser,$password
$domaincred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $domainuser,$password

Rename-Computer -ComputerName WIN8-WS2 -NewName WIN8-WS3 -LocalCredential $localcred -Restart -Force

while ((Test-Connection -computername WIN8-WS3 -count 1 -quiet) -ne $true)
{
    Start-Sleep 10
}

Add-Computer -ComputerName WIN8-WS3 -DomainName CONTOSO.COM -Credential $domaincred -Restart -Force
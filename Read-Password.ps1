Read-Host -Prompt "Enter the password:" -AsSecureString | ConvertFrom-SecureString | Set-Content c:\scripts\encrypted_password1.txt -Force

$pass = Get-Content C:\scripts\encrypted_password1.txt | ConvertTo-SecureString

$mycreds = New-Object System.Management.Automation.PSCredential ("username", $pass)

New-PSSession -ComputerName test -Credential $myCreds


$secure = Read-Host "Enter Password" -AsSecureString
$bytes = ConvertFrom-SecureString $secure
$bytes | Out-file securePassword.txt
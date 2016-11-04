$ftploc = "ftp://waws-prod-ch1-005.ftp.azurewebsites.windows.net"
#$cred = Get-Credential
[System.Net.FtpWebRequest]$Request = [System.Net.WebRequest]::Create($ftploc)

$Request.Credentials = $cred
$Request.Method = [System.Net.WebRequestMethods+FTP]::ListDirectoryDetails

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$ignoreCert}
$Response = $Request.GetResponse()
$Response.Close()
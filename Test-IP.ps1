function Test-IP  
{  
    param  
    (  
        [Parameter(Mandatory=$true)]  
        [ValidateScript({$_ -match [IPAddress]$_ })]  
        [String]$ip  
          
    )  
      
    $ip  
}
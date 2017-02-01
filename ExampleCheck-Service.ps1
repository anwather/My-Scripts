function Check-Service {

param($Name)

$upperName = $null

for ($i = 0; $i -lt $name.length; $i++)
{ 
    if ($i -eq 0)
        {
        $upperName = $upperName + ($name[$i].ToString()).ToUpper()
        }
    else
        {
        $upperName = $upperName + $name[$i]
        }
}

if (($services | where name -eq $Name) -ne $null)
    {
    Write-host "$uppername Service Exists"
    }
}
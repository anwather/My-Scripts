$serverlist = "DC01", "MS01", "SVR01"
$arrayList = New-Object System.Collections.ArrayList
foreach ($server in $serverlist) {$arrayList.Add($server)}
$orderedArray = @()
[boolean]$end = $false

do {

    if ($arrayList[-1] -notmatch "DC") {
        Write-output $arrayList[-1]
        $orderedArray += $arrayList[-1]
        $arrayList.Remove($arrayList[-1])
    }
    if ($arrayList.Count -eq 1) {
        $orderedArray += $arrayList[0]
        $end = $true
    }

    
}
until ($end -eq $true)
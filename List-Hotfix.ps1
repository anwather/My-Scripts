function List-hotfixes
    {
    param($computername)
    
    $result = @{$computername=(Get-HotFix -ComputerName $computername)}

    return $result
    }

function Check-Hotfix
    {
    param($HotfixList,$HotFixID)
    $found = @{}
    foreach ($key in $HotfixList.Keys) 
        {
        $updateID = $hotfixID
        $update = ($HotfixList.$key.Values).hotfixID | where {$_ -eq $updateID}

        if ($update)
            {
            $found.Add("$key","$updateID")
            }
        return $found
    }
}

$hotfixList = @{}

$computers = (Get-ADComputer -filter *).Name

foreach ($computer in $computers)
    {
    $result = List-hotfixes -computername $computer
    $hotfixlist.Add("$computer",$result)
    }

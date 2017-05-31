$obj = [pscustomobject]@{
        ComputerName = $env:COMPUTERNAME
        UserName = $env:USERNAME
}

$array += $obj


$obj = @{
        ComputerName = $env:COMPUTERNAME
        UserName = $env:USERNAME
}


$obj | get-member
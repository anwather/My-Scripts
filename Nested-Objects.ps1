#Install the OutTabulatorView module for PSGallery
$object = [pscustomobject]@{
    ComputerName = "MyServer01"
    Disks = @(
        @{
            Name = "C"
            FreeSpace = "70%"
        },
        @{
            Name = "D"
            FreeSpace = "70%"
        }
    )
    NetworkInterface = @(
        @{
            Name = "Ethernet"
            State = "Up"
        },
        @{
            Name = "Wifi"
            State = "Down"
        }
    )
    
}

$object2 = [pscustomobject]@{
    ComputerName = "MyServer02"
    Disks = @(
        @{
            Name = "C"
            FreeSpace = "60%"
        },
        @{
            Name = "D"
            FreeSpace = "50%"
        }
    )
    NetworkInterface = @(
        @{
            Name = "Ethernet"
            State = "Up"
        },
        @{
            Name = "Wifi"
            State = "Down"
        }
    )
    
}

$all = @()
$all += $object
$all += $object2

$formatArray = @()

foreach ($obj in $all) {
    #Multione
    foreach ($d in $obj.Disks) {
        $formatArray += [pscustomobject]@{
            ComputerName = $obj.ComputerName
            DriveLetter = $d.Name
            FreeSpace = $d.FreeSpace
            InterfaceName = $null
            State = $null
        }
    }
    foreach ($d in $obj.NetworkInterface) {
        $formatArray += [pscustomobject]@{
            ComputerName = $obj.ComputerName
            DriveLetter = $null
            FreeSpace = $null
            InterfaceName = $d.Name
            State = $d.State
        }
    }
}

$columnOptions = @()
$columnOptions += New-ColumnOption -ColumnName FreeSpace -title "Free Space" -formatter progress

$formatArray | otv -columnOptions $columnOptions -groupBy ComputerName
$formatArray | otv -groupBy ComputerName

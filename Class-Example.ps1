Class ComputerObject
    {

    [string]$ComputerName
    [string]$OsCaption

    ComputerObject()
        {
        $this.ComputerName = (Get-CimInstance CIM_ComputerSystem).Name
        $this.OsCaption = (Get-CIMInstance CIM_OperatingSystem).Caption
        }

    ComputerObject([String]$ComputerName)
        {
        $session = New-CimSession -ComputerName $ComputerName
        $cimComSys = Get-CimInstance CIM_ComputerSystem
        $cimOpSys = Get-CimInstance CIM_OperatingSystem

        $this.ComputerName = $cimComSys.Name
        $this.OsCaption = $cimOpSys.Caption
        }

    [void]ConvertToFQDN()
        {
        $this.ComputerName = $this.ComputerName + '.' + $env:USERDNSDOMAIN
        }

    }

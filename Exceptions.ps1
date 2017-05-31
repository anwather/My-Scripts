try {
    Get-Service Bits -ErrorAction STOP
    Get-Acl fakefile.txt -ErrorAction STOP
}
catch [Microsoft.PowerShell.Commands.ServiceCommandException] {
    $_.Exception.Message
}
catch [System.Management.Automation.ItemNotFoundException] {
    Write-Output "Item not found"
}
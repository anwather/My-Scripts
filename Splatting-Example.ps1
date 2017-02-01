function list
    {
    param([HashTable]$properties)
            
    Get-ChildItem @properties | Format-Wide
    }
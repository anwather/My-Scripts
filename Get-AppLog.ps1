function Get-AppLog {
    
    $applog = Get-EventLog -LogName "Application" -EntryType Error -After (Get-Date).AddDays(-1)
    # Optimise and put in array 
    $obj = @()
    foreach ($entry in $applog)  
        {    
         $props = @{'EntryType'=$entry.EntryType;
                    'Source'=$entry.Source;
                    'Message'=$entry.Message}
         $tempobj = New-Object -TypeName PSObject -Property $props
         $obj += $tempobj
        }
    return $obj
    }

$obj = Get-AppLog
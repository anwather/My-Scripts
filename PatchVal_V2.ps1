<#
.Synopsis
   Validates information pre and post patching
.DESCRIPTION
   Checks each provided server for OS information, disk information, services, application and system logs and installed hotfixes.
.EXAMPLE
   "server1","server2","server3" | Foreach-Object {.\PatchVal_V2.ps1 -ComputerName $_ -OutputFolder D:\Temp -Logfile C:\Temp\log.txt}
.EXAMPLE
   Get-Content C:\Temp\ServerList.txt | Foreach-Object {.\PatchVal_V2.ps1 -ComputerName $_ -OutputFolder D:\Temp -Logfile C:\Temp\log.txt}
.EXAMPLE
   .\PatchVal_V2.ps1 -ComputerName Server1 -OutputFolder D:\Temp -Logfile C:\Temp\log.txt
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$True,
               ValueFromPipeline=$True,
               ValueFromPipelineByPropertyName=$True)]
    [string[]]$ComputerName,
    [string]$LogFile="C:\Temp\Log.txt",
    [Parameter(Mandatory=$True)]
    [string]$OutputFolder
    <#[Parameter(Mandatory=$True)]
    [ValidateSet("Pre","Post")]
    [string]$Status#>
)

#region Style
$style = @"
<style>
body {
    color:#333333;
    font-family:Calibri,Tahoma;
    font-size: 10pt;
}
h1 {
    text-align:Left;
}
h2 {
    border-top:1px solid #666666;
}

th {
    font-weight:bold;
    color:#eeeeee;
    background-color:#333333;
    cursor:pointer;
}
.odd  { background-color:#ffffff; }
.even { background-color:#dddddd; }
.paginate_enabled_next, .paginate_enabled_previous {
    cursor:pointer; 
    border:1px solid #222222; 
    background-color:#dddddd; 
    padding:2px; 
    margin:4px;
    border-radius:2px;
}
.paginate_disabled_previous, .paginate_disabled_next {
    color:#666666; 
    cursor:pointer;
    background-color:#dddddd; 
    padding:2px; 
    margin:4px;
    border-radius:2px;
}
.dataTables_info { margin-bottom:4px; }
.sectionheader { cursor:pointer; }
.sectionheader:hover { color:red; }
.grid { width:100% }
.red {
    color:red;
    font-weight:bold;
} 
</style>
"@
#endRegion Style

$logfile = "C:\Temp\Log.txt"

#$computerName = "CMTP-DC01"

Import-Module EnhancedHTML2

$sb = {

function Get-InfoOS {
    
    $os = Get-WmiObject -class Win32_OperatingSystem
    $props = @{
                'OSVersion'=$os.Caption
               'SPVersion'=$os.CSDversion
               'LastRestartTime'=$os.ConvertToDateTime($os.LastBootUpTime)
               }       
    $obj = New-Object -TypeName PSObject -Property $props
    return $obj
}

function Get-Hotfixes
    {
        $hotfix = Get-Hotfix | Sort-Object InstalledOn 
        $props = @{
               #"Count" = $hotfix.Count
               "Hotfixes" = $hotfix
        }
        $obj = New-Object -TypeName PSObject -Property $props
    return $obj
    }


function Get-InfoDisk {
    
    $drives = Get-WmiObject -class Win32_LogicalDisk -Filter "DriveType=3" 
    $obj = @()       
    foreach ($drive in $drives) {      
        $props = @{'Drive'=$drive.DeviceID;
                   'Size'=$drive.size / 1GB -as [int];
                   'Free'="{0:N2}" -f ($drive.freespace / 1GB);
                   'FreePct'=$drive.freespace / $drive.size * 100 -as [int]}
        $tempobj = New-Object -TypeName PSObject -Property $props
        $obj += $tempobj
    }
    return $obj
}
function Get-InfoBadService {
    
    $svcs = Get-WmiObject -class Win32_Service -Filter "StartMode='Auto' AND State<>'Running'"
    $obj = @()       
    foreach ($svc in $svcs) {
        $props = @{'ServiceName'=$svc.name;
                   'DisplayName'=$svc.displayname}
     $tempobj = New-Object -TypeName PSObject -Property $props
     $obj += $tempobj
    }
    return $obj
}

function Get-AppLog {
    param($lastBoot)
    $applog = Get-EventLog -LogName "Application" -EntryType Error -After $lastBoot
    # Optimise and put in array 
    $obj = @()
    foreach ($entry in $applog)  
        {    
         $props = @{'EventID'=$entry.EventID;
                    'Source'=$entry.Source;
                    'Message'=$entry.Message}
         $tempobj = New-Object -TypeName PSObject -Property $props
         $obj += $tempobj
        }
    return $obj
    }
    

function Get-SysLog {
    param($lastBoot)
    $applog = Get-EventLog -LogName "System" -EntryType Error -After $lastBoot
    $obj = @()
    foreach ($entry in $applog)  
        {    
         $props = @{'EventID'=$entry.EventID;
                    'Source'=$entry.Source;
                    'Message'=$entry.Message}
         $tempobj = New-Object -TypeName PSObject -Property $props
         $obj += $tempobj
        }
    return $obj
    }

#Remote Main Region
$info_OS = Get-InfoOS

$props = @{
        "InfoOS" = $info_OS
        "InfoDisk" = Get-InfoDisk
        "InfoBadService" = Get-InfoBadService
        "AppLog" = Get-AppLog -lastBoot $info_OS.LastRestartTime
        "SysLog" = Get-SysLog -lastBoot $info_OS.LastRestartTime
        "Hotfixes" = Get-Hotfixes
}

$obj = New-Object -TypeName PSObject -Property $props
return $obj
}


foreach ($computer in $computerName)
    {

        try {
            Write-Host "Checking connectivity for $computer"
            $session = New-PSSession -ComputerName $computer -ErrorAction Stop
            }
        catch [System.Exception] 
            {
            Write-Host "Remote connection failed for $computer - $(Get-Date)" -ForegroundColor Red | Out-File -FilePath $logfile -Append
            break; 
            }

        $result = Invoke-Command -ComputerName $computer -ScriptBlock $sb

        $filePath = "$OutputFolder\$computer`_$(Get-Date -Format ddMMyyyy_HHmm).html"

        Write-Host "Getting OS Information for $computer"
        $params = @{'As'='List';
                    'PreContent'='<h2>OS</h2>'}
        $html_os = $result.InfoOS | ConvertTo-EnhancedHTMLFragment @params

        Write-Host "Getting disk information for $computer"
        $params = @{'As'='Table';
                    'PreContent'='<h2>Local Disks</h2>';
                    'EvenRowCssClass'='even';
                    'OddRowCssClass'='odd';
                    #'MakeTableDynamic'=$false;
                    'TableCssClass'='grid';
                    'Properties'='Drive',
                                 @{n='Size(GB)';e={$_.Size}},
                                 @{n='Free(GB)';e={$_.Free};css={if ($_.FreePct -lt 5) { 'black' }}},
                                 @{n='Free(%)';e={$_.FreePct};css={if ($_.FreeePct -lt 5) { 'black' }}}}

        $html_dr = $result.InfoDisk | ConvertTo-EnhancedHTMLFragment @params

        Write-Host "Getting service information for $computer"
        $params = @{'As'='Table';
                    'PreContent'='<h2>Services to Check</h2>';
                    'EvenRowCssClass'='even';
                    'OddRowCssClass'='odd';
                    #'MakeHiddenSection'=$false;
                    'TableCssClass'='grid'}
        $html_sv = $result.InfoBadService | ConvertTo-EnhancedHTMLFragment @params

        Write-Host "Getting application log information for $computer"
        $params = @{'As'='Table';
                    'PreContent'="<h2>Application Log Errors - Total Errors: $($result.AppLog | Measure-Object | Select -ExpandProperty Count) </h2>";
                    'EvenRowCssClass'='even';
                    'OddRowCssClass'='odd';
                    #'MakeHiddenSection'=$false;
                    'TableCssClass'='grid'}
        $html_al = $result.AppLog | ConvertTo-EnhancedHTMLFragment @params

        Write-Host "Getting system log information for $computer"
        $params = @{'As'='Table';
                    'PreContent'="<h2>System Log Errors - Total Errors: $($result.SysLog | Measure-Object | Select -ExpandProperty Count)</h2>";
                    'EvenRowCssClass'='even';
                    'OddRowCssClass'='odd';
                    #'MakeHiddenSection'=$false;
                    'TableCssClass'='grid'}
        $html_sl = $result.SysLog | ConvertTo-EnhancedHTMLFragment @params
        
        Write-Host "Getting installed hotfixes for $computer"
        $params = @{'As'='Table';
                    'PreContent'="<h2>Installed Hotfixes - Total: $($result.Hotfixes.Hotfixes.GetEnumerator() | Measure-Object | Select -ExpandProperty Count)</h2>";
                    'EvenRowCssClass'='even';
                    'OddRowCssClass'='odd';
                    #'MakeHiddenSection'=$false;
                    'TableCssClass'='grid'}
        $html_hf = $result.Hotfixes.Hotfixes.GetEnumerator() | Sort-Object InstalledOn -Descending | Select Description,HotFixID,InstalledBy,InstalledOn | ConvertTo-EnhancedHTMLFragment @params
        $html_ver = "Script version 1.1"

        $html_date = get-date
        Write-Host "Creating Report for $computer"
        $params = @{'CssStyleSheet'=$style;
                    'Title'="$Status Patch System Report for $computer";
                    'PreContent'="<h1>$Status Patch Validation Report for $computer</h1>";
                    'HTMLFragments'=@($html_os,$html_dr,$html_sv,$html_al,$html_sl,$html_hf,$html_ver,$html_date);
                    'jQueryDataTableUri'='http://ajax.aspnetcdn.com/ajax/jquery.dataTables/1.9.3/jquery.dataTables.min.js';
                    'jQueryUri'='http://ajax.aspnetcdn.com/ajax/jQuery/jquery-1.8.2.min.js'} 
        ConvertTo-EnhancedHTML @params |
        Out-File -FilePath $filepath
        Write-Host "Created report $filepath"
        Remove-PSSession -Session $session
    
        
        
    }

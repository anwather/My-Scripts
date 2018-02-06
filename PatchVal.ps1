#requires -module EnhancedHTML2

<#
.SYNOPSIS
Generates an HTML-based system report for one or more computers.
Each computer specified will result in a separate HTML file; 
specify the -Path as a folder where you want the files written.
Note that existing files will be overwritten.
.PARAMETER ComputerName
One or more computer names or IP addresses to query.
.PARAMETER Path
The path of the folder where the files should be written.
.PARAMETER CssPath
The path and filename of the CSS template to use. 
.EXAMPLE
.\patchval.ps1 -ComputerName ONE,TWO `
                       -Path C:\Reports\ 
                       -Status "Pre"\"Post"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$True,
               ValueFromPipeline=$True,
               ValueFromPipelineByPropertyName=$True)]
    [string[]]$ComputerName,

    [Parameter(Mandatory=$True)]
    [string]$Path,
    [Parameter(Mandatory=$True)]
    [ValidateSet("Pre","Post")]
    [string]$Status
)
BEGIN {
    Remove-Module EnhancedHTML2
    Import-Module EnhancedHTML2
}
PROCESS {

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

function Get-InfoOS {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True)][string]$ComputerName
    )
    $os = Get-WmiObject -class Win32_OperatingSystem -ComputerName $ComputerName
    $props = @{'OSVersion'=$os.Caption;
               'SPVersion'=$os.CSDversion}         
    New-Object -TypeName PSObject -Property $props
}


function Get-InfoDisk {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True)][string]$ComputerName
    )
    $drives = Get-WmiObject -class Win32_LogicalDisk -ComputerName $ComputerName `
           -Filter "DriveType=3"
    foreach ($drive in $drives) {      
        $props = @{'Drive'=$drive.DeviceID;
                   'Size'=$drive.size / 1GB -as [int];
                   'Free'="{0:N2}" -f ($drive.freespace / 1GB);
                   'FreePct'=$drive.freespace / $drive.size * 100 -as [int]}
        New-Object -TypeName PSObject -Property $props 
    }
}
function Get-InfoBadService {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True)][string]$ComputerName
    )
    $svcs = Get-WmiObject -class Win32_Service -ComputerName $ComputerName `
           -Filter "StartMode='Auto' AND State<>'Running'"
    foreach ($svc in $svcs) {
        $props = @{'ServiceName'=$svc.name;
                   'DisplayName'=$svc.displayname}
        New-Object -TypeName PSObject -Property $props
    }
}

function Get-AppLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True)][string]$ComputerName
    )
    $applog = Get-EventLog -Computername $ComputerName `
            -LogName "Application" -EntryType Error -After (Get-Date).AddDays(-1)
        $props = @{'EntryType'=$applog.EntryType;
                   'Source'=$applog.Source;
                   'Message'=$applog.Message}
        New-Object -TypeName PSObject -Property $props
    }
    

function Get-SysLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True)][string]$ComputerName
    )
    $applog = Get-EventLog -Computername $ComputerName `
            -LogName "System" -EntryType Error -After (Get-Date).AddDays(-1)
        $props = @{'EntryType'=$syslog.EntryType;
                   'Source'=$syslog.Source;
                   'Message'=$syslog.Message}
        New-Object -TypeName PSObject -Property $props
    }

foreach ($computer in $computername) {
    try {
        $everything_ok = $true
        Write-Host "Checking connectivity to $computer"
        Get-WmiObject -class Win32_BIOS -ComputerName $Computer -EA Stop | Out-Null
    } catch {
        Write-Warning "Cannot connect to $computer for WMI query. Report Failed. Please Check System"
        $everything_ok = $false
    }

    if ($everything_ok) {
        Write-Host "Gathering Information For $Computer. Please Wait- This may take a few minutes."
        $filepath = Join-Path -Path $Path -ChildPath "$computer.html"
        Write-Host "Gettinging OS Information"
        $params = @{'As'='List';
                    'PreContent'='<h2>OS</h2>'}
        $html_os = Get-InfoOS -ComputerName $computer |
                   ConvertTo-EnhancedHTMLFragment @params 


        Write-Host "Gathering Disk Information"
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
        $html_dr = Get-InfoDisk -ComputerName $computer |
                   ConvertTo-EnhancedHTMLFragment @params

        Write-Host "Looking for failed Services"
        $params = @{'As'='Table';
                    'PreContent'='<h2>Services to Check</h2>';
                    'EvenRowCssClass'='even';
                    'OddRowCssClass'='odd';
                    #'MakeHiddenSection'=$false;
                    'TableCssClass'='grid'}
        $html_sv = Get-InfoBadService -ComputerName $computer |
                   ConvertTo-EnhancedHTMLFragment @params 

        Write-Host "Looking for Errors in Application Log"
        $params = @{'As'='Table';
                    'PreContent'='<h2>Application Log Errors</h2>';
                    'EvenRowCssClass'='even';
                    'OddRowCssClass'='odd';
                    #'MakeHiddenSection'=$false;
                    'TableCssClass'='grid'}
        $html_al = Get-AppLog -ComputerName $Computer |
                   ConvertTo-EnhancedHTMLFragment @params

        Write-Host "Looking for Errors in System Log"
                $params = @{'As'='Table';
                    'PreContent'='<h2>System Log Errors</h2>';
                    'EvenRowCssClass'='even';
                    'OddRowCssClass'='odd';
                    #'MakeHiddenSection'=$false;
                    'TableCssClass'='grid'}
        $html_sl = Get-SysLog -ComputerName $Computer |
                   ConvertTo-EnhancedHTMLFragment @params

        $html_ver = "Script version 1.1"

        $html_date = get-date

        Write-Host "Creating Report"
        $params = @{'CssStyleSheet'=$style;
                    'Title'="$Status Patch System Report for $computer";
                    'PreContent'="<h1>$Status Patch Validation Report for $computer</h1>";
                    'HTMLFragments'=@($html_os,$html_dr,$html_sv,$html_al,$html_sl,$html_ver,$html_date);
                    'jQueryDataTableUri'='http://ajax.aspnetcdn.com/ajax/jquery.dataTables/1.9.3/jquery.dataTables.min.js';
                    'jQueryUri'='http://ajax.aspnetcdn.com/ajax/jQuery/jquery-1.8.2.min.js'} 
        ConvertTo-EnhancedHTML @params |
        Out-File -FilePath $filepath

        <#
        $params = @{'CssStyleSheet'=$style;
                    'Title'="System Report for $computer";
                    'PreContent'="<h1>System Report for $computer</h1>";
                    'HTMLFragments'=@($html_os,$html_cs,$html_dr,$html_pr,$html_sv,$html_na)}
        ConvertTo-EnhancedHTML @params |
        Out-File -FilePath $filepath
        #>
    }
}
}

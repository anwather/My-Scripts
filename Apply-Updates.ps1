Enter file conparam(

[Parameter(Mandatory=$true)][String]$ComputerName,[switch]$Restart)

$sb = {
#Define update criteria.

$sb = {

$Criteria = "IsInstalled=0 and Type='Software'"


#Search for relevant updates.

$Searcher = New-Object -ComObject Microsoft.Update.Searcher

$SearchResult = $Searcher.Search($Criteria).Updates


#Download updates.

$Session = New-Object -ComObject Microsoft.Update.Session

$Downloader = $Session.CreateUpdateDownloader()

$Downloader.Updates = $SearchResult

$Downloader.Download()


#Install updates.

$Installer = New-Object -ComObject Microsoft.Update.Installer

$Installer.Updates = $SearchResult

$Result = $Installer.Install()

<#If ($Result.rebootRequired)
    {
    exit 1;
    }
else
    {
    exit 0;
    }#>
}

#$computer = "ITSWSUSKEW1"


#Define update criteria.

$Criteria = "IsInstalled=0 and Type='Software'"


#Search for relevant updates.

$Searcher = New-Object -ComObject Microsoft.Update.Searcher

Write-Output "-I- Start patching script for remote machine $env:computername"

Write-Output "-I- Searching for applicable updates. Please wait..."

$SearchResult = $Searcher.Search($Criteria).Updates

if ($SearchResult)
    {
        Write-Output "---------------------------------"
        Write-Output "-I- Updates detected for installation"
        Write-Output "---------------------------------"

        foreach ($result in $SearchResult)
            {
                # Write output from applicable updates
                Write-Output "$($result.Title)"
            }
        Write-Output "---------------------------------"
    }
else
    {
    Write-Output "-W- No updates available for installation"
    exit;
    }

#Download any applicable updates if not downloaded

foreach ($result in $SearchResult)
    {
        if ($result.Downloaded -eq $false)
            {
                $Session = New-Object -ComObject Microsoft.Update.Session

                $Downloader = $Session.CreateUpdateDownloader()
        
                $Downloader.Updates = $result
                Write-Output "Downloading update: $($result.Title)"
                $Downloader.Download()
            }
        else
            {
                Write-Output "Update: $($result.Title) - is already downloaded"
            } 
    }

# Apply Updates

Write-Output "-I- Installing Updates - this may take some time...."

try
    {
        Get-ScheduledJob -Name "WSUS Update Installation" -ErrorAction Stop
        Write-Output "-I- Unregistering job"
        Unregister-ScheduledJob -Name "WSUS Update Installation"
    }
catch
    {
        Write-Output "-I- Job does not exist"
    }

try
    {
    $future = (Get-Date).AddSeconds(10)
    $trigger = New-JobTrigger -At $future -Once
    $options = New-ScheduledJobOption -RunElevated
    Register-ScheduledJob -Name "WSUS Update Installation" -ScriptBlock $sb -Trigger $trigger -ScheduledJobOption $options -ErrorAction Stop | Out-Null
    Write-Output "-I- Registered scheduled job"
    Start-Sleep 15
    #Start-Job -DefinitionName "WSUS Update Installation" | Out-Null
    Write-Output "-I- Running installation job"
    }
catch
    {
    Write-Output "-E- Could not create job"
    if ($($host.version.Major) -lt 3)
        {
        Write-Output "-E- PowerShell on the remote machine must be Version 3.0 to support scheduled jobs"
        }
    else
        {
        Write-Output "-E- Error details: $($error[0].Exception)"
        }
    exit;
    }


while (((Get-Job -Name 'WSUS Update Installation').JobStateInfo).State -eq "Running")
{
   Write-Host "-I- Installing Updates..."
   Sleep -Seconds 30 
}

Write-Output "-I- Receiving job details"

Receive-Job -Name 'WSUS Update Installation'

Remove-Job -Name 'WSUS Update Installation'
}

# Start Main Script



Write-Host "-I- Initialising Script..."
Write-Host "-I- Creating remote session to $computername"

try
    {
    $session = New-PSSession -ComputerName $computername -ErrorAction Stop
    }
catch
    {
    Write-Host "-E- Could not start remote session on $computername" -ForegroundColor Red
    exit;
    }

Write-Host "-I- Session set up successful" -ForegroundColor Green
Write-Host "-I- Invoking remote installation"


try
    {
    Invoke-Command -Session $session -ScriptBlock $sb
    if ($LASTEXITCODE -ne 0)
        {
        Write-Host "-E- Updates were not installed" -ForegroundColor Red
        exit;
        }
    else
        {
        Write-Host "-I- Updates installed" -ForegroundColor Green
        }
    }
catch
    {
    Write-Host "-E- Could not start script on remote host" -ForegroundColor Red
    #exit;
    }

# Check for restart required

Write-Host "Checking if a reboot is required on remote host"

$sb = {
if (Test-Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired')
    {
    $rebootrequired = $true
    return $rebootrequired
    }
else
    {
    $rebootrequired = $false
    return $rebootrequired
    }
}

try
    {
        $rebootrequired = Invoke-Command -Session $session -ScriptBlock $sb
    }
catch
    {
        Write-Host "Unable to determine if a reboot is required"
        exit;
    }




#Prompt for restart



if ($Restart)
    {
    if ($rebootRequired)
        {
        Write-Output "-I- Restarting computer: $computername"
        try
            {
                Restart-Computer -ComputerName $computername -Force -Confirm -Verbose -ErrorAction STOP
            }
        catch
            {
                Write-Host "-E- Machine may have failed rebooting - please confirm success" -ForegroundColor Red
                exit;
            }
        Write-Output "-I- Machine has been restarted"
        }
    else
        {
        Write-Output "-I- Computer does not require a restart"
        }
    }
else
    {
    if ($rebootRequired)
        {
        Write-Output "-I- $computername requires a restart - the next command will prompt if you want this to happen"
        try
            {
                Restart-Computer -ComputerName $computername -Force -Confirm -Verbose -ErrorAction STOP
            }
        catch
            {
                Write-Host "-E- Machine may have failed rebooting - please confirm success" -ForegroundColor Red
                exit;
            }
        Write-Output "-I- Machine has been restarted"
        }
    }

#Cleanup

Remove-PSSession *











tents here

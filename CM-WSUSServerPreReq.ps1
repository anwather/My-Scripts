Configuration SCCM_WSUS
    {

    Param(
    
    [Parameter(Mandatory=$true)]
    [String]$UpdatePath)

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node localhost
        {
            
            WindowsFeature ASPNET46
            {
                Ensure = "Present"
                Name = "NET-Framework-45-ASPNET"
            }

            WindowsFeature HTTPActivation
            {
                Ensure = "Present"
                Name = "Net-WCF-HTTP-Activation45"
                DependsOn = "[WindowsFeature]ASPNET46"
            }

            WindowsFeature ProcessModel
            {
                Ensure = "Present"
                Name = "WAS-Process-Model"
                DependsOn = "[WindowsFeature]HTTPActivation"
            }

            WindowsFeature ConfigAPI
            {
                Ensure = "Present"
                Name = "WAS-Config-APIs"
                DependsOn = "[WindowsFeature]ProcessModel"
            }
            
            WindowsFeature UpdateServices
			{
				Ensure = "Present"
				Name = "UpdateServices"
			}

			WindowsFeature UpdateServices-WidDB
			{
				Ensure = "Present"
				Name = "UpdateServices-WidDB"
				DependsOn = "[WindowsFeature]UpdateServices"
			}

			WindowsFeature UpdateServices-Services
			{
				Ensure = "Present"
				Name = "UpdateServices-Services"
				DependsOn = "[WindowsFeature]UpdateServices-WidDB"
			}

			WindowsFeature UpdateServices-RSAT
			{
				Ensure = "Present"
				Name = "UpdateServices-RSAT"
				DependsOn = "[WindowsFeature]UpdateServices-Services"
			}

			WindowsFeature UpdateServices-API
			{
				Ensure = "Present"
				Name = "UpdateServices-API"
				DependsOn = "[WindowsFeature]UpdateServices-RSAT"
			}

			WindowsFeature UpdateServices-UI
			{
				Ensure = "Present"
				Name = "UpdateServices-UI"
				DependsOn = "[WindowsFeature]UpdateServices-API"
			}

            File TempFolder
            {
                Ensure = "Present"
                Type = "Directory"
                DestinationPath = "C:\Temp"
            }

			File UpdatesStore
			{
				Ensure = "Present"
				Type = "Directory"
				DestinationPath = $UpdatePath
				DependsOn = "[WindowsFeature]UpdateServices-UI"
			}

			Script ConfigureWSUS
			{
				TestScript = {Test-Path C:\Temp\temp.txt}
				SetScript = {
                    $WSUSUtil = "$($Env:ProgramFiles)\Update Services\Tools\WsusUtil.exe"
                    $WSUSUtilArgs = "POSTINSTALL CONTENT_DIR=$($UpdatePath)"
                    Start-Process -FilePath $WSUSUtil -ArgumentList $WSUSUtilArgs -NoNewWindow -Wait -RedirectStandardOutput "C:\Temp\temp.txt" | Out-Null
                            }
				GetScript = {return @{ 'Present' = $true }}
				DependsOn = "[File]UpdatesStore","[File]TempFolder"
			}
        }
    }

Set-Location D:\Scripts

SCCM_WSUS -UpdatePath "D:\Updates"

Start-DscConfiguration -Path .\SCCM_WSUS -Verbose -Wait -Force
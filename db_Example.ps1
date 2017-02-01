$serverList = "AUS-CM01","AUS-SCSM01","AUS-SCSM02","AUS-SCOM01","AUS-SCORCH01"
#$serverList = "AUS-SCORCH01","AUS-CM01"
$resultServer = "AUS-SCORCH01"
$resultDB = "PatchingAdmin"

$sb = {
    Param($Params)

    $serverName = $params.ServerName
    $dbname = "msdb"
    $query = @"
Select @@ServerName AS ServerName,@@Version As Version
"@

    #Create the connection object
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $sqlConnection.ConnectionString = "Server=$servername; Database=$dbname; Integrated Security = True"

    #Create the command object
    $sqlcmd = New-Object System.Data.SqlClient.SqlCommand
    $sqlcmd.CommandText = $query
    $sqlcmd.Connection = $sqlConnection
    Write-Output $sqlcmd.CommandText

    #Retrieve data
    $sqlConnection.Open()
    $result = $sqlcmd.ExecuteReader()

    #Store results in a data table object
    $table = New-Object System.Data.DataTable
    $table.Load($result)

    #Close the connection
    $SqlConnection.Close() 
    
    return $table

}

$updatesb = {
Param($Params)

    $serverName = $params.ServerName
    $version = $params.Version
    $dbname = "PatchingAdmin"
    $query = @"
INSERT INTO [dbo].[Versions]
           ([ServerName]
           ,[Version]
           ,[LastUpdated])
     VALUES
           (`'$serverName`'
           ,`'$version`'
           ,GETDATE())
"@

    #Create the connection object
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $sqlConnection.ConnectionString = "Server=$using:resultServer; Database=$using:resultDB; Integrated Security = True"

    #Create the command object
    $sqlcmd = New-Object System.Data.SqlClient.SqlCommand
    $sqlcmd.CommandText = $query
    $sqlcmd.Connection = $sqlConnection

    #Write the data
    $sqlConnection.Open()
    $sqlcmd.ExecuteNonQuery() | Out-Null
    $sqlConnection.Close()
    }


foreach ($server in $serverList)
    {
    if (Test-Connection -ComputerName $server -Count 1 -Quiet)
        {
        $params = @{
            ServerName = $server
            }

        $session = New-PSSession -ComputerName $server
        $result = Invoke-Command -Session $session -ArgumentList $params -ScriptBlock $sb
        Remove-PSSession $session
        #Transform the results
        $params = @{
            ServerName = $result.ServerName
            Version = $result.Version.Split() | Select-String -Pattern "^\d{2}`.\d{1}`.\d{4}`.\d{1}$"
            }
        #Write to the db
        $session = New-PSSession -ComputerName $resultServer
        $result = Invoke-Command -Session $session -ArgumentList $params -ScriptBlock $updatesb
        Remove-PSSession $session

        }
    else
        {
        Write-Output "Server $server is not responding"
        }
    }
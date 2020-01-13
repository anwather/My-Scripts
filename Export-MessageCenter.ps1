Param([string]$ClientKey, [string]$ClientAppId, [string]$TenantId)

function GetAuthToken {
    [CmdletBinding()]
    Param (
        $ClientID, $ClientSecret, $TenantID 
    )
    

    $TokenEndpoint = "https://login.windows.net/{0}/oauth2/token" -f $TenantID 
    $ARMResource = "https://manage.office.com";
    
    $Body = @{
        'resource'      = $ARMResource
        'client_id'     = $ClientID
        'grant_type'    = 'client_credentials'
        'client_secret' = $ClientSecret
    }
    
    $params = @{
        ContentType = 'application/x-www-form-urlencoded'
        Headers     = @{'accept' = 'application/json' }
        Body        = $Body
        Method      = 'Post'
        URI         = $TokenEndpoint
    }
    
    $token = Invoke-RestMethod @params
    
    return $token
}

$token = (GetAuthToken -ClientID $ClientAppId -ClientSecret $ClientKey -TenantID $TenantId).access_token

$headers = @{
    Authorization       = "Bearer $token"
    PublisherIdentifier = $tenantId
    ContentType         = 'application/json'
}
                     
$testCall = "https://manage.office.com/api/v1.0/$tenantId/ServiceComms/Messages"

$result = Invoke-RestMethod -Uri $testCall -Headers $headers -Verbose

$output = @()
foreach ($message in $result.value) {
    $obj = [PSCustomObject]@{
        Id      = $message.Id
        Title   = $message.Title
        Message = $message.Messages.MessageText -join "`n"
    }
    $output += $obj
}

$output | Export-CSV -Path message.csv -NoTypeInformation
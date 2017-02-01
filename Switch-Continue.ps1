$service = Get-Service

$service[0]
$service[1]

switch ($($service.Name))
    {
    "AdobeARMservice" {continue; "$_"}
    "AeLookupSvc" {"$_"}
    }
function Remove-OU
    {
    param ($OU,[switch]$Remove)

 <#   Get-ADOrganizationalUnit -Identity $OU | `
        Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $false -PassThru | ` 
            Remove-ADOrganizationalUnit #>

    try 
        {
            $orgUnit = Get-ADOrganizationalUnit -Identity $OU -ErrorAction STOP
        }
    catch
        {
            Write-Error "OU $OU does not exist"
            break;
        }

    if ($Remove)
        {
        try
            {
                Set-ADOrganizationalUnit -Identity $OU -ProtectedFromAccidentalDeletion $false -ErrorAction STOP
                Remove-ADOrganizationalUnit -Identity $OU -Confirm:$false
            }
        catch
            {
            Write-Host $error[0]
            }
        }
    else
        {
        Write-Host "Use the Remove switch to force removal"
        }
    }
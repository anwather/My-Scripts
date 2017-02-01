function Copy-ADPrincipalGroupMembership
    {
    Param
        (
    #Parameter Script Validation
        [ValidateScript({Import-Module ActiveDirectory; $_ -eq ((Get-ADUser -Identity $_).Name)})]
        [string]$SourceUser,

        [ValidateScript({Import-Module ActiveDirectory; $_ -eq ((Get-ADUser -Identity $_).Name)})]
        [String]$TargetUser
        )
    
    (Get-ADPrincipalGroupMembership -Identity $SourceUser | Where Name -NE "Domain Users").Name | Add-ADGroupMember -Members $TargetUser -PassThru

    }
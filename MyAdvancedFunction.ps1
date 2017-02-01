function MyAdvancedFunction
    {
    
          Param(

              #Mandatory Parameter  
              [Parameter(Mandatory=$true)]
              [string] $Name,

              #Default Value
              [Parameter()]
              [int] $Age = 18,

              #Parameter Sets
              [Parameter(ParameterSetName = "Set 1")]
              [string] $Set1Value,

              [Parameter(ParameterSetName = "Set 2")]
              [string] $Set2Value,

              [Parameter(Mandatory = $true, HelpMessage = "This is the help for this message")]
              [string] $HelpValue,

              #Parameter Alias
              [Parameter()]
              [alias("ComputerName","MachineName")]
              [string] $ServerName,

              #Parameter Length Validation
              [Parameter()]
              [ValidateLength(4,4)]
              [string] $PostCode,

              #Parameter Range Validation
              [Parameter()]
              [ValidateRange(2000,8999)]
              [int] $PostCodeV2,

              #Parameter Script Validation
              [Parameter()]
              [ValidateScript({Test-Connection -ComputerName $_ -Count 1 -Quiet})]
              [string] $TestServer,

              #Validate Set
              [Parameter()]
              [ValidateSet("High","Medium","Low")]
              [string] $Severity


               
               )
    }
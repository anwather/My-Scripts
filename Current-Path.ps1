$path = $MyInvocation.MyCommand.Path
Write-Output "$(Split-Path $path -Parent)\"
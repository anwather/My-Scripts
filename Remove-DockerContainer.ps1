docker ps -a | foreach-object {Select-String -Pattern "(\w{10})" -InputObject $_ | Select-Object -expandproperty Matches | Select-Object -ExpandProperty Value | foreach-object {docker rm $_}}

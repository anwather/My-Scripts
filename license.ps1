Param($ResourceGroupName, $VMName)

$vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName

$vm.LicenseType = "Windows_Server"

Update-AzVM -VM $vm -ResourceGroupName $ResourceGroupName

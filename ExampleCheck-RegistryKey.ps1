if (Test-path HKLM:\software\MyKey) {
    "Key exists"
}
else {
    "Key does not exist"
    New-Item HKLM:\SOFTWARE\MyKey -force
}


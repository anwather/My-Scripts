$string = $env:Temp

Write-Output "Before Split"
Write-Output "------------"
Write-Output $string
Write-Output $string.GetType()
Write-Output " "

$string = $string.Split("\")

Write-Output "After Split"
Write-Output "------------"
Write-Output $string
Write-Output $string.GetType()
Write-Output " "

$string = [String]::Join("/",$string)

Write-Output "After Join"
Write-Output "------------"
Write-Output $string
Write-Output $string.GetType()
Write-Output " "



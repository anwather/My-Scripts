$paths = "C:\Source","C:\AMD","C:\Intel"

foreach ($path in $paths) {
$params = @{
    Path = $path
    Recurse = $true
    Depth = 0
}

Get-ChildItem @params 
}
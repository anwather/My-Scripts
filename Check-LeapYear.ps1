function Check-LeapYear {
    param($Year)

    $result = [datetime]::IsLeapYear("$Year")

    if ($result -eq $true) {
        Write-Host "$year is a leap year"
    }
    else {
        Write-Host "$year is not a leap year"
    }

}
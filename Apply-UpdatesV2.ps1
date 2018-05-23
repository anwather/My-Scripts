Function Search-Updates {
    $Criteria = "IsInstalled=0 and Type='Software'"
    #Search for relevant updates.
    $Searcher = New-Object -ComObject Microsoft.Update.Searcher
    $SearchResult = $Searcher.Search($Criteria).Updates

    return [System.MarshalByRefObject]$SearchResult
}

Function Download-Updates {
    Param($SearchResult)
    $Session = New-Object -ComObject Microsoft.Update.Session
    $Downloader = $Session.CreateUpdateDownloader()
    $Downloader.Updates = $SearchResult
    $Downloader.Download()
}

[System.MarshalByRefObject]$SearchResult = Search-Updates

Download-Updates -SearchResult $SearchResult
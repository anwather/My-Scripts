$jn = 1..10
$jobs = @()

$scriptblock = {
    $file = New-TemporaryFile
    return $file.Name
    }

$runSpacePool = [runspacefactory]::CreateRunspacePool(1,10).Open()

foreach ($j in $jn)
{
    $job = [powershell]::Create().AddScript($scriptblock)
    $job.RunspacePool = $runSpacePool
    
    $jobs += [pscustomobject]@{
        Pipe = $job
        Result = $job.BeginInvoke()
    }
}

$jobs | ForEach-Object {

        $results += $_.Pipe.EndInvoke($_.Result)

    }
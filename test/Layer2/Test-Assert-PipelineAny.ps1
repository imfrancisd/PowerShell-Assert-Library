[CmdletBinding()]
Param(
    [System.Management.Automation.SwitchParameter]
    $Silent
)

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
if ($Silent) {
    $headerVerbosity = [System.Management.Automation.ActionPreference]::SilentlyContinue
    $VerbosePreference = $headerVerbosity
} else {
    $headerVerbosity = [System.Management.Automation.ActionPreference]::Continue
}

$nonBooleanFalse = @(
    0, '', @($null), @(0), @(''), @($false), @(), @(,@())
)
$nonBooleanTrue = @(
    1, 'True', 'False', @(1), @('True'), @('False'), @($true), @(,@(1)), @(,@($true))
)

& {
    Write-Verbose -Message 'Test Assert-PipelineAny with Boolean $true' -Verbose:$headerVerbosity

    $e = try {$item = $true | Assert-PipelineAny} catch {$_.Exception}

    Assert-Null $e
    Assert-True $item
}

& {
    Write-Verbose -Message 'Test Assert-PipelineAny with Boolean $false' -Verbose:$headerVerbosity

    $e = try {$item = $false | Assert-PipelineAny} catch {$_.Exception}

    Assert-Null $e
    Assert-False $item
}

& {
    Write-Verbose -Message 'Test Assert-PipelineAny with $null' -Verbose:$headerVerbosity

    $objectCount = 0
    $e = try {$item = $null | Assert-PipelineAny | ForEach-Object {$objectCount++; $_}} catch {$_.Exception}

    Assert-Null $e
    Assert-Null $item
    Assert-True (1 -eq $objectCount)
}

& {
    Write-Verbose -Message 'Test Assert-PipelineAny with Non-Booleans that are convertible to $true' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanTrue) {
        $returnedItems = New-Object -TypeName 'System.Collections.ArrayList'
        $e = try {,$item | Assert-PipelineAny | ForEach-Object {[System.Void]$returnedItems.Add($_)}} catch {$_.Exception}

        Assert-Null $e
        Assert-True (1 -eq $returnedItems.Count)
        Assert-True ($item.Equals($returnedItems[0]))
    }
}

& {
    Write-Verbose -Message 'Test Assert-PipelineAny with Non-Booleans that are convertible to $false' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanFalse) {
        $returnedItems = New-Object -TypeName 'System.Collections.ArrayList'
        $e = try {,$item | Assert-PipelineAny | ForEach-Object {[System.Void]$returnedItems.Add($_)}} catch {$_.Exception}

        Assert-Null $e
        Assert-True (1 -eq $returnedItems.Count)
        Assert-True ($item.Equals($returnedItems[0]))
    }
}

& {
    Write-Verbose -Message 'Test Assert-PipelineAny with pipelines that contain zero objects' -Verbose:$headerVerbosity

    $returnedItems = New-Object -TypeName 'System.Collections.ArrayList'
    $e1 = try {@() | Assert-PipelineAny | ForEach-Object {[System.Void]$returnedItems.Add($_)}} catch {$_.Exception}

    Assert-True $e1.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True (0 -eq $returnedItems.Count)

    $returnedItems = New-Object -TypeName 'System.Collections.ArrayList'
    $e2 = try {& {@()} | Assert-PipelineAny | ForEach-Object {[System.Void]$returnedItems.Add($_)}} catch {$_.Exception}

    Assert-True $e2.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True (0 -eq $returnedItems.Count)

    function f1 {}
    $returnedItems = New-Object -TypeName 'System.Collections.ArrayList'
    $e3 = try {f1 | Assert-PipelineAny | ForEach-Object {[System.Void]$returnedItems.Add($_)}} catch {$_.Exception}

    Assert-True $e3.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True (0 -eq $returnedItems.Count)
}

& {
    Write-Verbose -Message 'Test Assert-PipelineAny with a pipeline that contains many objects' -Verbose:$headerVerbosity

    $items = 11..20
    $returnedItems = New-Object -TypeName 'System.Collections.ArrayList'
    $e = try {$items | Assert-PipelineAny | foreach-object {[System.Void]$returnedItems.Add($_)}} catch {$_.Exception}

    Assert-Null $e
    Assert-True (10 -eq $returnedItems.Count)
    for ($i = 0; $i -lt $returnedItems.Count; $i++) {
        Assert-True ($items[$i].Equals($returnedItems[$i]))
    }
}

& {
    Write-Verbose -Message 'Test Assert-PipelineAny with a non-pipeline input' -Verbose:$headerVerbosity

    $e1 = try {Assert-PipelineAny -InputObject $true | Out-Null} catch {$_.Exception}
    $e2 = try {Assert-PipelineAny -InputObject $false | Out-Null} catch {$_.Exception}
    $e3 = try {Assert-PipelineAny -InputObject $null | Out-Null} catch {$_.Exception}
    $e4 = try {Assert-PipelineAny -InputObject @() | Out-Null} catch {$_.Exception}
    $e5 = try {Assert-PipelineAny -InputObject @(0) | Out-Null} catch {$_.Exception}

    $errorMessage = 'Assert-PipelineAny must take its input from the pipeline.'

    Assert-True ($e1 -is [System.ArgumentException])
    Assert-True ($e2 -is [System.ArgumentException])
    Assert-True ($e3 -is [System.ArgumentException])
    Assert-True ($e4 -is [System.ArgumentException])
    Assert-True ($e5 -is [System.ArgumentException])

    Assert-True $e1.Message.StartsWith($errorMessage, [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True $e2.Message.StartsWith($errorMessage, [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True $e3.Message.StartsWith($errorMessage, [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True $e4.Message.StartsWith($errorMessage, [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True $e5.Message.StartsWith($errorMessage, [System.StringComparison]::OrdinalIgnoreCase)
}

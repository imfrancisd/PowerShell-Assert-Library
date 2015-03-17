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
    Write-Verbose -Message 'Test Assert-PipelineCount -Equals with Boolean $true' -Verbose:$headerVerbosity

    $e1 = try {$item1 = $true | Assert-PipelineCount 1} catch {$_.Exception}
    $e2 = try {$item2 = $true | Assert-PipelineCount -Equals 1} catch {$_.Exception}

    Assert-Null $e1
    Assert-Null $e2
    Assert-True $item1
    Assert-True $item2

    $e3 = try {$item3 = $true | Assert-PipelineCount 0} catch {$_.Exception}
    $e4 = try {$item4 = $true | Assert-PipelineCount -Equals 0} catch {$_.Exception}

    Assert-NotNull $e3
    Assert-True $e3.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-NotNull $e4
    Assert-True $e4.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-Null $item3
    Assert-Null $item4

    $e5 = try {$item5 = $true | Assert-PipelineCount 2} catch {$_.Exception}
    $e6 = try {$item6 = $true | Assert-PipelineCount -Equals 2} catch {$_.Exception}

    Assert-NotNull $e5
    Assert-True $e5.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-NotNull $e6
    Assert-True $e6.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-Null $item5
    Assert-Null $item6
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Equals with Boolean $false' -Verbose:$headerVerbosity

    $e1 = try {$item1 = $false | Assert-PipelineCount 1} catch {$_.Exception}
    $e2 = try {$item2 = $false | Assert-PipelineCount -Equals 1} catch {$_.Exception}

    Assert-Null $e1
    Assert-Null $e2
    Assert-False $item1
    Assert-False $item2

    $e3 = try {$item3 = $false | Assert-PipelineCount 0} catch {$_.Exception}
    $e4 = try {$item4 = $false | Assert-PipelineCount -Equals 0} catch {$_.Exception}

    Assert-NotNull $e3
    Assert-True $e3.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-NotNull $e4
    Assert-True $e4.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-Null $item3
    Assert-Null $item4

    $e5 = try {$item5 = $false | Assert-PipelineCount 2} catch {$_.Exception}
    $e6 = try {$item6 = $false | Assert-PipelineCount -Equals 2} catch {$_.Exception}

    Assert-NotNull $e5
    Assert-True $e5.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-NotNull $e6
    Assert-True $e6.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-Null $item5
    Assert-Null $item6
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Equals with $null' -Verbose:$headerVerbosity

    $items1 = New-Object -TypeName 'System.Collections.ArrayList'
    $items2 = New-Object -TypeName 'System.Collections.ArrayList'
    $e1 = try {$null | Assert-PipelineCount 1 | Foreach-Object {[System.Void]$items1.Add($_)}} catch {$_.Exception}
    $e2 = try {$null | Assert-PipelineCount -Equals 1 | Foreach-Object {[System.Void]$items2.Add($_)}} catch {$_.Exception}

    Assert-Null $e1
    Assert-Null $e2
    Assert-True (1 -eq $items1.Count)
    Assert-True (1 -eq $items2.Count)
    Assert-Null $items1[0]
    Assert-Null $items2[0]

    $items3 = New-Object -TypeName 'System.Collections.ArrayList'
    $items4 = New-Object -TypeName 'System.Collections.ArrayList'
    $e3 = try {$null | Assert-PipelineCount 0 | Foreach-Object {[System.Void]$items3.Add($_)}} catch {$_.Exception}
    $e4 = try {$null | Assert-PipelineCount -Equals 0 | Foreach-Object {[System.Void]$items4.Add($_)}} catch {$_.Exception}

    Assert-NotNull $e3
    Assert-True $e3.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-NotNull $e4
    Assert-True $e4.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True (0 -eq $items3.Count)
    Assert-True (0 -eq $items4.Count)

    $items5 = New-Object -TypeName 'System.Collections.ArrayList'
    $items6 = New-Object -TypeName 'System.Collections.ArrayList'
    $e5 = try {$null | Assert-PipelineCount 2 | Foreach-Object {[System.Void]$items5.Add($_)}} catch {$_.Exception}
    $e6 = try {$null | Assert-PipelineCount -Equals 2 | Foreach-Object {[System.Void]$items6.Add($_)}} catch {$_.Exception}

    Assert-NotNull $e5
    Assert-True $e5.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-NotNull $e6
    Assert-True $e6.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True (1 -eq $items5.Count)
    Assert-True (1 -eq $items6.Count)
    Assert-Null $items5[0]
    Assert-Null $items6[0]
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Equals with Non-Booleans that are convertible to $true' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanTrue) {
        $items1 = New-Object -TypeName 'System.Collections.ArrayList'
        $items2 = New-Object -TypeName 'System.Collections.ArrayList'
        $e1 = try {,$item | Assert-PipelineCount 1 | Foreach-Object {[System.Void]$items1.Add($_)}} catch {$_.Exception}
        $e2 = try {,$item | Assert-PipelineCount -Equals 1 | Foreach-Object {[System.Void]$items2.Add($_)}} catch {$_.Exception}

        Assert-Null $e1
        Assert-Null $e2
        Assert-True (1 -eq $items1.Count)
        Assert-True (1 -eq $items2.Count)
        Assert-True ($item.Equals($items1[0]))
        Assert-True ($item.Equals($items2[0]))

        $items3 = New-Object -TypeName 'System.Collections.ArrayList'
        $items4 = New-Object -TypeName 'System.Collections.ArrayList'
        $e3 = try {,$item | Assert-PipelineCount 0 | Foreach-Object {[System.Void]$items3.Add($_)}} catch {$_.Exception}
        $e4 = try {,$item | Assert-PipelineCount -Equals 0 | Foreach-Object {[System.Void]$items4.Add($_)}} catch {$_.Exception}

        Assert-NotNull $e3
        Assert-True $e3.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
        Assert-NotNull $e4
        Assert-True $e4.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
        Assert-True (0 -eq $items3.Count)
        Assert-True (0 -eq $items4.Count)

        $items5 = New-Object -TypeName 'System.Collections.ArrayList'
        $items6 = New-Object -TypeName 'System.Collections.ArrayList'
        $e5 = try {,$item | Assert-PipelineCount 2 | Foreach-Object {[System.Void]$items5.Add($_)}} catch {$_.Exception}
        $e6 = try {,$item | Assert-PipelineCount -Equals 2 | Foreach-Object {[System.Void]$items6.Add($_)}} catch {$_.Exception}

        Assert-NotNull $e5
        Assert-True $e5.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
        Assert-NotNull $e6
        Assert-True $e6.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
        Assert-True (1 -eq $items5.Count)
        Assert-True (1 -eq $items6.Count)
        Assert-True ($item.Equals($items5[0]))
        Assert-True ($item.Equals($items6[0]))
    }
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Equals with Non-Booleans that are convertible to $false' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanFalse) {
        $items1 = New-Object -TypeName 'System.Collections.ArrayList'
        $items2 = New-Object -TypeName 'System.Collections.ArrayList'
        $e1 = try {,$item | Assert-PipelineCount 1 | Foreach-Object {[System.Void]$items1.Add($_)}} catch {$_.Exception}
        $e2 = try {,$item | Assert-PipelineCount -Equals 1 | Foreach-Object {[System.Void]$items2.Add($_)}} catch {$_.Exception}

        Assert-Null $e1
        Assert-Null $e2
        Assert-True (1 -eq $items1.Count)
        Assert-True (1 -eq $items2.Count)
        Assert-True ($item.Equals($items1[0]))
        Assert-True ($item.Equals($items2[0]))

        $items3 = New-Object -TypeName 'System.Collections.ArrayList'
        $items4 = New-Object -TypeName 'System.Collections.ArrayList'
        $e3 = try {,$item | Assert-PipelineCount 0 | Foreach-Object {[System.Void]$items3.Add($_)}} catch {$_.Exception}
        $e4 = try {,$item | Assert-PipelineCount -Equals 0 | Foreach-Object {[System.Void]$items4.Add($_)}} catch {$_.Exception}

        Assert-NotNull $e3
        Assert-True $e3.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
        Assert-NotNull $e4
        Assert-True $e4.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
        Assert-True (0 -eq $items3.Count)
        Assert-True (0 -eq $items4.Count)

        $items5 = New-Object -TypeName 'System.Collections.ArrayList'
        $items6 = New-Object -TypeName 'System.Collections.ArrayList'
        $e5 = try {,$item | Assert-PipelineCount 2 | Foreach-Object {[System.Void]$items5.Add($_)}} catch {$_.Exception}
        $e6 = try {,$item | Assert-PipelineCount -Equals 2 | Foreach-Object {[System.Void]$items6.Add($_)}} catch {$_.Exception}

        Assert-NotNull $e5
        Assert-True $e5.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
        Assert-NotNull $e6
        Assert-True $e6.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
        Assert-True (1 -eq $items5.Count)
        Assert-True (1 -eq $items6.Count)
        Assert-True ($item.Equals($items5[0]))
        Assert-True ($item.Equals($items6[0]))
    }
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Equals with pipelines that contain zero objects' -Verbose:$headerVerbosity

    $items1 = New-Object -TypeName 'System.Collections.ArrayList'
    $items2 = New-Object -TypeName 'System.Collections.ArrayList'
    $e1 = try {@() | Assert-PipelineCount 0 | ForEach-Object {[System.Void]$items1.Add($_)}} catch {$_.Exception}
    $e2 = try {@() | Assert-PipelineCount -Equals 0 | ForEach-Object {[System.Void]$items2.Add($_)}} catch {$_.Exception}

    Assert-Null $e1
    Assert-Null $e2
    Assert-True (0 -eq $items1.Count)
    Assert-True (0 -eq $items2.Count)

    $items3 = New-Object -TypeName 'System.Collections.ArrayList'
    $items4 = New-Object -TypeName 'System.Collections.ArrayList'
    $e3 = try {@() | Assert-PipelineCount 1 | ForEach-Object {[System.Void]$items3.Add($_)}} catch {$_.Exception}
    $e4 = try {@() | Assert-PipelineCount -Equals 1 | ForEach-Object {[System.Void]$items4.Add($_)}} catch {$_.Exception}

    Assert-NotNull $e3
    Assert-NotNull $e4
    Assert-True $e3.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True $e4.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True (0 -eq $items3.Count)
    Assert-True (0 -eq $items4.Count)

    $items5 = New-Object -TypeName 'System.Collections.ArrayList'
    $items6 = New-Object -TypeName 'System.Collections.ArrayList'
    $e5 = try {@() | Assert-PipelineCount (-1) | ForEach-Object {[System.Void]$items5.Add($_)}} catch {$_.Exception}
    $e6 = try {@() | Assert-PipelineCount -Equals (-1) | ForEach-Object {[System.Void]$items6.Add($_)}} catch {$_.Exception}

    Assert-NotNull $e5
    Assert-NotNull $e6
    Assert-True $e5.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True $e6.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True (0 -eq $items5.Count)
    Assert-True (0 -eq $items6.Count)
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Equals with a pipeline that contains many objects' -Verbose:$headerVerbosity

    $items = 11..20

    $items1 = New-Object -TypeName 'System.Collections.ArrayList'
    $items2 = New-Object -TypeName 'System.Collections.ArrayList'
    $e1 = try {$items | Assert-PipelineCount 10 | ForEach-Object {[System.Void]$items1.Add($_)}} catch {$_.Exception}
    $e2 = try {$items | Assert-PipelineCount -Equals 10 | ForEach-Object {[System.Void]$items2.Add($_)}} catch {$_.Exception}

    Assert-Null $e1
    Assert-Null $e2
    Assert-True (10 -eq $items1.Count)
    Assert-True (10 -eq $items2.Count)
    for ($i = 0; $i -lt $items1.Count; $i++) {
        Assert-True ($items[$i].Equals($items1[$i]))
        Assert-True ($items[$i].Equals($items2[$i]))
    }

    $items3 = New-Object -TypeName 'System.Collections.ArrayList'
    $items4 = New-Object -TypeName 'System.Collections.ArrayList'
    $e3 = try {$items | Assert-PipelineCount 11 | ForEach-Object {[System.Void]$items3.Add($_)}} catch {$_.Exception}
    $e4 = try {$items | Assert-PipelineCount -Equals 11 | ForEach-Object {[System.Void]$items4.Add($_)}} catch {$_.Exception}

    Assert-NotNull $e3
    Assert-NotNull $e4
    Assert-True $e3.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True $e4.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True (10 -eq $items3.Count)
    Assert-True (10 -eq $items4.Count)
    for ($i = 0; $i -lt $items1.Count; $i++) {
        Assert-True ($items[$i].Equals($items3[$i]))
        Assert-True ($items[$i].Equals($items4[$i]))
    }

    $items5 = New-Object -TypeName 'System.Collections.ArrayList'
    $items6 = New-Object -TypeName 'System.Collections.ArrayList'
    $e5 = try {$items | Assert-PipelineCount 9 | ForEach-Object {[System.Void]$items5.Add($_)}} catch {$_.Exception}
    $e6 = try {$items | Assert-PipelineCount -Equals 9 | ForEach-Object {[System.Void]$items6.Add($_)}} catch {$_.Exception}

    Assert-NotNull $e5
    Assert-NotNull $e6
    Assert-True $e5.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True $e6.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True (9 -eq $items5.Count)
    Assert-True (9 -eq $items6.Count)
    for ($i = 0; $i -lt $items5.Count; $i++) {
        Assert-True ($items[$i].Equals($items5[$i]))
        Assert-True ($items[$i].Equals($items6[$i]))
    }
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Minimum with Boolean $true' -Verbose:$headerVerbosity

    $e1 = try {$item1 = $true | Assert-PipelineCount -Minimum 1} catch {$_.Exception}

    Assert-Null $e1
    Assert-True $item1

    $e2 = try {$item2 = $true | Assert-PipelineCount -Minimum 0} catch {$_.Exception}

    Assert-Null $e2
    Assert-True $item2

    $e3 = try {$item3 = $true | Assert-PipelineCount -Minimum 2} catch {$_.Exception}

    Assert-NotNull $e3
    Assert-True $e3.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-Null $item3
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Minimum with Boolean $false' -Verbose:$headerVerbosity

    $e1 = try {$item1 = $false | Assert-PipelineCount -Minimum 1} catch {$_.Exception}

    Assert-Null $e1
    Assert-False $item1

    $e2 = try {$item2 = $false | Assert-PipelineCount -Minimum 0} catch {$_.Exception}

    Assert-Null $e2
    Assert-False $item2

    $e3 = try {$item3 = $false | Assert-PipelineCount -Minimum 2} catch {$_.Exception}

    Assert-NotNull $e3
    Assert-True $e3.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-Null $item3
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Minimum with $null' -Verbose:$headerVerbosity

    $items1 = New-Object -TypeName 'System.Collections.ArrayList'
    $e1 = try {$null | Assert-PipelineCount -Minimum 1 | Foreach-Object {[System.Void]$items1.Add($_)}} catch {$_.Exception}

    Assert-Null $e1
    Assert-True (1 -eq $items1.Count)
    Assert-Null $items1[0]

    $items2 = New-Object -TypeName 'System.Collections.ArrayList'
    $e2 = try {$null | Assert-PipelineCount -Minimum 0 | Foreach-Object {[System.Void]$items2.Add($_)}} catch {$_.Exception}

    Assert-Null $e2
    Assert-True (1 -eq $items2.Count)
    Assert-Null $items2[0]

    $items3 = New-Object -TypeName 'System.Collections.ArrayList'
    $e3 = try {$null | Assert-PipelineCount -Minimum 2 | Foreach-Object {[System.Void]$items3.Add($_)}} catch {$_.Exception}

    Assert-NotNull $e3
    Assert-True $e3.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True (1 -eq $items3.Count)
    Assert-Null $items3[0]
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Minimum with Non-Booleans that are convertible to $true' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanTrue) {
        $items1 = New-Object -TypeName 'System.Collections.ArrayList'
        $e1 = try {,$item | Assert-PipelineCount -Minimum 1 | Foreach-Object {[System.Void]$items1.Add($_)}} catch {$_.Exception}

        Assert-Null $e1
        Assert-True (1 -eq $items1.Count)
        Assert-True ($item.Equals($items1[0]))

        $items2 = New-Object -TypeName 'System.Collections.ArrayList'
        $e2 = try {,$item | Assert-PipelineCount -Minimum 0 | Foreach-Object {[System.Void]$items2.Add($_)}} catch {$_.Exception}

        Assert-Null $e2
        Assert-True (1 -eq $items2.Count)
        Assert-True ($item.Equals($items2[0]))

        $items3 = New-Object -TypeName 'System.Collections.ArrayList'
        $e3 = try {,$item | Assert-PipelineCount -Minimum 2 | Foreach-Object {[System.Void]$items3.Add($_)}} catch {$_.Exception}

        Assert-NotNull $e3
        Assert-True $e3.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
        Assert-True (1 -eq $items3.Count)
        Assert-True ($item.Equals($items3[0]))
    }
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Minimum with Non-Booleans that are convertible to $false' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanFalse) {
        $items1 = New-Object -TypeName 'System.Collections.ArrayList'
        $e1 = try {,$item | Assert-PipelineCount -Minimum 1 | Foreach-Object {[System.Void]$items1.Add($_)}} catch {$_.Exception}

        Assert-Null $e1
        Assert-True (1 -eq $items1.Count)
        Assert-True ($item.Equals($items1[0]))

        $items2 = New-Object -TypeName 'System.Collections.ArrayList'
        $e2 = try {,$item | Assert-PipelineCount -Minimum 0 | Foreach-Object {[System.Void]$items2.Add($_)}} catch {$_.Exception}

        Assert-Null $e2
        Assert-True (1 -eq $items2.Count)
        Assert-True ($item.Equals($items2[0]))

        $items3 = New-Object -TypeName 'System.Collections.ArrayList'
        $e3 = try {,$item | Assert-PipelineCount -Minimum 2 | Foreach-Object {[System.Void]$items3.Add($_)}} catch {$_.Exception}

        Assert-NotNull $e3
        Assert-True $e3.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
        Assert-True (1 -eq $items3.Count)
        Assert-True ($item.Equals($items3[0]))
    }
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Minimum with pipelines that contain zero objects' -Verbose:$headerVerbosity

    $items1 = New-Object -TypeName 'System.Collections.ArrayList'
    $e1 = try {@() | Assert-PipelineCount -Minimum 0 | ForEach-Object {[System.Void]$items1.Add($_)}} catch {$_.Exception}

    Assert-Null $e1
    Assert-True (0 -eq $items1.Count)

    $items2 = New-Object -TypeName 'System.Collections.ArrayList'
    $e2 = try {@() | Assert-PipelineCount -Minimum (-1) | ForEach-Object {[System.Void]$items2.Add($_)}} catch {$_.Exception}

    Assert-Null $e2
    Assert-True (0 -eq $items2.Count)

    $items3 = New-Object -TypeName 'System.Collections.ArrayList'
    $e3 = try {@() | Assert-PipelineCount -Minimum 1 | ForEach-Object {[System.Void]$items3.Add($_)}} catch {$_.Exception}

    Assert-NotNull $e3
    Assert-True $e3.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True (0 -eq $items3.Count)
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Minimum with a pipeline that contains many objects' -Verbose:$headerVerbosity

    $items = 11..20

    $items1 = New-Object -TypeName 'System.Collections.ArrayList'
    $e1 = try {$items | Assert-PipelineCount -Minimum 10 | ForEach-Object {[System.Void]$items1.Add($_)}} catch {$_.Exception}

    Assert-Null $e1
    Assert-True (10 -eq $items1.Count)
    for ($i = 0; $i -lt $items1.Count; $i++) {
        Assert-True ($items[$i].Equals($items1[$i]))
    }

    $items2 = New-Object -TypeName 'System.Collections.ArrayList'
    $e2 = try {$items | Assert-PipelineCount -Minimum 11 | ForEach-Object {[System.Void]$items2.Add($_)}} catch {$_.Exception}

    Assert-NotNull $e2
    Assert-True $e2.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True (10 -eq $items2.Count)
    for ($i = 0; $i -lt $items2.Count; $i++) {
        Assert-True ($items[$i].Equals($items2[$i]))
    }

    $items3 = New-Object -TypeName 'System.Collections.ArrayList'
    $e3 = try {$items | Assert-PipelineCount -Minimum 9 | ForEach-Object {[System.Void]$items3.Add($_)}} catch {$_.Exception}

    Assert-Null $e3
    Assert-True (10 -eq $items3.Count)
    for ($i = 0; $i -lt $items3.Count; $i++) {
        Assert-True ($items[$i].Equals($items3[$i]))
    }
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Maximum with Boolean $true' -Verbose:$headerVerbosity

    $e1 = try {$item1 = $true | Assert-PipelineCount -Maximum 1} catch {$_.Exception}

    Assert-Null $e1
    Assert-True $item1

    $e2 = try {$item2 = $true | Assert-PipelineCount -Maximum 2} catch {$_.Exception}

    Assert-Null $e2
    Assert-True $item2

    $e3 = try {$item3 = $true | Assert-PipelineCount -Maximum 0} catch {$_.Exception}

    Assert-NotNull $e3
    Assert-True $e3.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-Null $item3
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Maximum with Boolean $false' -Verbose:$headerVerbosity

    $e1 = try {$item1 = $false | Assert-PipelineCount -Maximum 1} catch {$_.Exception}

    Assert-Null $e1
    Assert-False $item1

    $e2 = try {$item2 = $false | Assert-PipelineCount -Maximum 2} catch {$_.Exception}

    Assert-Null $e2
    Assert-False $item2

    $e3 = try {$item3 = $false | Assert-PipelineCount -Maximum 0} catch {$_.Exception}

    Assert-NotNull $e3
    Assert-True $e3.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-Null $item3
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Maximum with $null' -Verbose:$headerVerbosity

    $items1 = New-Object -TypeName 'System.Collections.ArrayList'
    $e1 = try {$null | Assert-PipelineCount -Maximum 1 | Foreach-Object {[System.Void]$items1.Add($_)}} catch {$_.Exception}

    Assert-Null $e1
    Assert-True (1 -eq $items1.Count)
    Assert-Null $items1[0]

    $items2 = New-Object -TypeName 'System.Collections.ArrayList'
    $e2 = try {$null | Assert-PipelineCount -Maximum 2 | Foreach-Object {[System.Void]$items2.Add($_)}} catch {$_.Exception}

    Assert-Null $e2
    Assert-True (1 -eq $items2.Count)
    Assert-Null $items2[0]

    $items3 = New-Object -TypeName 'System.Collections.ArrayList'
    $e3 = try {$null | Assert-PipelineCount -Maximum 0 | Foreach-Object {[System.Void]$items3.Add($_)}} catch {$_.Exception}

    Assert-NotNull $e3
    Assert-True $e3.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True (0 -eq $items3.Count)
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Maximum with Non-Booleans that are convertible to $true' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanTrue) {
        $items1 = New-Object -TypeName 'System.Collections.ArrayList'
        $e1 = try {,$item | Assert-PipelineCount -Maximum 1 | Foreach-Object {[System.Void]$items1.Add($_)}} catch {$_.Exception}

        Assert-Null $e1
        Assert-True (1 -eq $items1.Count)
        Assert-True ($item.Equals($items1[0]))

        $items2 = New-Object -TypeName 'System.Collections.ArrayList'
        $e2 = try {,$item | Assert-PipelineCount -Maximum 2 | Foreach-Object {[System.Void]$items2.Add($_)}} catch {$_.Exception}

        Assert-Null $e2
        Assert-True (1 -eq $items2.Count)
        Assert-True ($item.Equals($items2[0]))

        $items3 = New-Object -TypeName 'System.Collections.ArrayList'
        $e3 = try {,$item | Assert-PipelineCount -Maximum 0 | Foreach-Object {[System.Void]$items3.Add($_)}} catch {$_.Exception}

        Assert-NotNull $e3
        Assert-True $e3.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
        Assert-True (0 -eq $items3.Count)
    }
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Maximum with Non-Booleans that are convertible to $false' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanFalse) {
        $items1 = New-Object -TypeName 'System.Collections.ArrayList'
        $e1 = try {,$item | Assert-PipelineCount -Maximum 1 | Foreach-Object {[System.Void]$items1.Add($_)}} catch {$_.Exception}

        Assert-Null $e1
        Assert-True (1 -eq $items1.Count)
        Assert-True ($item.Equals($items1[0]))

        $items2 = New-Object -TypeName 'System.Collections.ArrayList'
        $e2 = try {,$item | Assert-PipelineCount -Maximum 2 | Foreach-Object {[System.Void]$items2.Add($_)}} catch {$_.Exception}

        Assert-Null $e2
        Assert-True (1 -eq $items2.Count)
        Assert-True ($item.Equals($items2[0]))

        $items3 = New-Object -TypeName 'System.Collections.ArrayList'
        $e3 = try {,$item | Assert-PipelineCount -Maximum 0 | Foreach-Object {[System.Void]$items3.Add($_)}} catch {$_.Exception}

        Assert-NotNull $e3
        Assert-True $e3.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
        Assert-True (0 -eq $items3.Count)
    }
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Maximum with pipelines that contain zero objects' -Verbose:$headerVerbosity

    $items1 = New-Object -TypeName 'System.Collections.ArrayList'
    $e1 = try {@() | Assert-PipelineCount -Maximum 0 | ForEach-Object {[System.Void]$items1.Add($_)}} catch {$_.Exception}

    Assert-Null $e1
    Assert-True (0 -eq $items1.Count)

    $items2 = New-Object -TypeName 'System.Collections.ArrayList'
    $e2 = try {@() | Assert-PipelineCount -Maximum 1 | ForEach-Object {[System.Void]$items2.Add($_)}} catch {$_.Exception}

    Assert-Null $e2
    Assert-True (0 -eq $items2.Count)

    $items3 = New-Object -TypeName 'System.Collections.ArrayList'
    $e3 = try {@() | Assert-PipelineCount -Maximum (-1) | ForEach-Object {[System.Void]$items3.Add($_)}} catch {$_.Exception}

    Assert-NotNull $e3
    Assert-True $e3.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True (0 -eq $items3.Count)
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Maximum with a pipeline that contains many objects' -Verbose:$headerVerbosity

    $items = 11..20

    $items1 = New-Object -TypeName 'System.Collections.ArrayList'
    $e1 = try {$items | Assert-PipelineCount -Maximum 10 | ForEach-Object {[System.Void]$items1.Add($_)}} catch {$_.Exception}

    Assert-Null $e1
    Assert-True (10 -eq $items1.Count)
    for ($i = 0; $i -lt $items1.Count; $i++) {
        Assert-True ($items[$i].Equals($items1[$i]))
    }

    $items2 = New-Object -TypeName 'System.Collections.ArrayList'
    $e2 = try {$items | Assert-PipelineCount -Maximum 11 | ForEach-Object {[System.Void]$items2.Add($_)}} catch {$_.Exception}

    Assert-Null $e2
    Assert-True (10 -eq $items2.Count)
    for ($i = 0; $i -lt $items2.Count; $i++) {
        Assert-True ($items[$i].Equals($items2[$i]))
    }

    $items3 = New-Object -TypeName 'System.Collections.ArrayList'
    $e3 = try {$items | Assert-PipelineCount -Maximum 9 | ForEach-Object {[System.Void]$items3.Add($_)}} catch {$_.Exception}

    Assert-NotNull $e3
    Assert-True $e3.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True (9 -eq $items3.Count)
    for ($i = 0; $i -lt $items3.Count; $i++) {
        Assert-True ($items[$i].Equals($items3[$i]))
    }
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount with a non-pipeline input' -Verbose:$headerVerbosity

    $e1 = try {Assert-PipelineCount -InputObject $true -Equals 1 | Out-Null} catch {$_.Exception}
    $e2 = try {Assert-PipelineCount -InputObject $false -Minimum 1 | Out-Null} catch {$_.Exception}
    $e3 = try {Assert-PipelineCount -InputObject $null -Maximum 1| Out-Null} catch {$_.Exception}
    $e4 = try {Assert-PipelineCount -InputObject @() -Minimum 1| Out-Null} catch {$_.Exception}
    $e5 = try {Assert-PipelineCount -InputObject @(0) -Maximum 0 | Out-Null} catch {$_.Exception}

    $errorMessage = 'Assert-PipelineCount must take its input from the pipeline.'

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

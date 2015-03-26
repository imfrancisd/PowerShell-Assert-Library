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

& {
    Write-Verbose -Message 'Test Group-ListItem -Pair with nulls' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {Group-ListItem -Pair $null -OutVariable out1 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 0)
    Assert-True ($er1 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er1.FullyQualifiedErrorId.Equals('ParameterArgumentValidationErrorNullNotAllowed,Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er1.Exception.ParameterName.Equals('Pair', [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Pair with lists of length 0' -Verbose:$headerVerbosity

    Group-ListItem -Pair @() | Assert-PipelineEmpty
    Group-ListItem -Pair (New-Object -TypeName 'System.Collections.ArrayList') | Assert-PipelineEmpty
    Group-ListItem -Pair (New-Object -TypeName 'System.Collections.Generic.List[System.Double]') | Assert-PipelineEmpty
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Pair with lists of length 1' -Verbose:$headerVerbosity

    Group-ListItem -Pair @($null) | Assert-PipelineEmpty
    Group-ListItem -Pair (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello world'))) | Assert-PipelineEmpty
    Group-ListItem -Pair (New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(3.14))) | Assert-PipelineEmpty
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Pair with lists of length 2' -Verbose:$headerVerbosity

    $list1 = @($null, 5)
    Group-ListItem -Pair $list1 | Assert-PipelineCount 1 | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Object[]])
        Assert-True ($_.Items.Length -eq 2)
        Assert-True ($null -eq $_.Items[0])
        Assert-True (5 -eq $_.Items[1])
    }

    $list2 = (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello', 'world')))
    Group-ListItem -Pair $list2 | Assert-PipelineCount 1 | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Object[]])
        Assert-True ($_.Items.Length -eq 2)
        Assert-True ('hello' -eq $_.Items[0])
        Assert-True ('world' -eq $_.Items[1])
    }

    $list3 = (New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(3.14, 2.72)))
    Group-ListItem -Pair $list3 | Assert-PipelineCount 1 | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Double[]])
        Assert-True ($_.Items.Length -eq 2)
        Assert-True (3.14 -eq $_.Items[0])
        Assert-True (2.72 -eq $_.Items[1])
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Pair with lists of length 3' -Verbose:$headerVerbosity

    $list1 = @(3.14, 2.72, 0.00)
    $groups1 = Group-ListItem -Pair $list1 | Assert-PipelineCount 2 | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Object[]])
        Assert-True ($_.Items.Length -eq 2)
        $_
    }
    Assert-True (3.14 -eq $groups1[0].Items[0])
    Assert-True (2.72 -eq $groups1[0].Items[1])
    Assert-True (2.72 -eq $groups1[1].Items[0])
    Assert-True (0.00 -eq $groups1[1].Items[1])

    $list2 = (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello', $null, 'world')))
    $groups2 = Group-ListItem -Pair $list2 | Assert-PipelineCount 2 | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Object[]])
        Assert-True ($_.Items.Length -eq 2)
        $_
    }
    Assert-True ('hello' -eq $groups2[0].Items[0])
    Assert-True ($null   -eq $groups2[0].Items[1])
    Assert-True ($null   -eq $groups2[1].Items[0])
    Assert-True ('world' -eq $groups2[1].Items[1])

    $list3 = (New-Object -TypeName 'System.Collections.Generic.List[System.Object]' -ArgumentList @(,[System.Object[]]@($null, 'hello', 3.14)))
    $groups3 = Group-ListItem -Pair $list3 | Assert-PipelineCount 2 | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Object[]])
        Assert-True ($_.Items.Length -eq 2)
        $_
    }
    Assert-True ($null   -eq $groups3[0].Items[0])
    Assert-True ('hello' -eq $groups3[0].Items[1])
    Assert-True ('hello' -eq $groups3[1].Items[0])
    Assert-True (3.14    -eq $groups3[1].Items[1])
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Pair with lists of length 4 or more' -Verbose:$headerVerbosity

    $count = 0
    $list1 = @('a', 1, @(), ([System.Int32[]]@(1..5)))
    Group-ListItem -Pair $list1 | Assert-PipelineCount 3 | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Object[]])
        Assert-True ($_.Items.Length -eq 2)
        Assert-True ($list1[$count].Equals($_.Items[0]))
        Assert-True ($list1[$count + 1].Equals($_.Items[1]))
        $count++
    }

    $count = 0
    $list2 = (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello', @($null), 'world', 5)))
    Group-ListItem -Pair $list2 | Assert-PipelineCount 3 | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Object[]])
        Assert-True ($_.Items.Length -eq 2)
        Assert-True ($list2[$count].Equals($_.Items[0]))
        Assert-True ($list2[$count + 1].Equals($_.Items[1]))
        $count++
    }

    $count = 0
    $list3 = (New-Object -TypeName 'System.Collections.Generic.List[System.Int32]' -ArgumentList @(,[System.Int32[]]@(100, 200, 300, 400)))
    Group-ListItem -Pair $list3 | Assert-PipelineCount 3 | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Int32[]])
        Assert-True ($_.Items.Length -eq 2)
        Assert-True ($list3[$count].Equals($_.Items[0]))
        Assert-True ($list3[$count + 1].Equals($_.Items[1]))
        $count++
    }

    for ($size = 5; $size -lt 10; $size++) {
        $count = 0
        $list = [System.Int32[]]@(1..$size)
        Group-ListItem -Pair $list | Assert-PipelineCount ($size - 1) | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Int32[]])
            Assert-True ($_.Items.Length -eq 2)
            Assert-True ($list[$count].Equals($_.Items[0]))
            Assert-True ($list[$count + 1].Equals($_.Items[1]))
            $count++
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Window with nulls' -Verbose:$headerVerbosity

    $noarg = New-Object 'System.Object'

    foreach ($size in @($noarg, -1, 0, 1)) {
        $gliArgs = @{
            'Window' = $null
            'Size' = $size
        }
        if ($noarg.Equals($size)) {
            $gliArgs.Remove('Size')
        }

        $out1 = New-Object -TypeName 'System.Collections.ArrayList'
        $er1 = try {Group-ListItem @gliArgs -OutVariable out1 | Out-Null} catch {$_}

        Assert-True ($out1.Count -eq 0)
        Assert-True ($er1 -is [System.Management.Automation.ErrorRecord])
        Assert-True ($er1.FullyQualifiedErrorId.Equals('ParameterArgumentValidationErrorNullNotAllowed,Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($er1.Exception.ParameterName.Equals('Window', [System.StringComparison]::OrdinalIgnoreCase))
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Window with lists of length 0' -Verbose:$headerVerbosity

    $noarg = New-Object 'System.Object'

    foreach ($size in @(-2, -1, 1, 2)) {
        Group-ListItem -Size $size -Window @() | Assert-PipelineEmpty
        Group-ListItem -Size $size -Window (New-Object -TypeName 'System.Collections.ArrayList') | Assert-PipelineEmpty
        Group-ListItem -Size $size -Window (New-Object -TypeName 'System.Collections.Generic.List[System.Double]') | Assert-PipelineEmpty
    }

    foreach ($size in @($noarg, 0)) {
        $gliArgs = @{
            'Size' = $size
        }
        if ($noarg.Equals($size)) {
            $gliArgs.Remove('Size')
        }

        Group-ListItem @gliArgs -Window @() | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq 0)
        }
        Group-ListItem @gliArgs -Window (New-Object -TypeName 'System.Collections.ArrayList') | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq 0)
        }
        Group-ListItem @gliArgs -Window (New-Object -TypeName 'System.Collections.Generic.List[System.Double]') | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Double[]])
            Assert-True ($_.Items.Length -eq 0)
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Window with lists of length 1' -Verbose:$headerVerbosity

    $noarg = New-Object 'System.Object'

    foreach ($size in @(-2, -1, 2)) {
        Group-ListItem -Size $size -Window @($null) | Assert-PipelineEmpty
        Group-ListItem -Size $size -Window (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello world'))) | Assert-PipelineEmpty
        Group-ListItem -Size $size -Window (New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(3.14))) | Assert-PipelineEmpty
    }

    Group-ListItem -Size 0 -Window @($null) | Assert-PipelineSingle | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Object[]])
        Assert-True ($_.Items.Length -eq 0)
    }
    Group-ListItem -Size 0 -Window (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello world'))) | Assert-PipelineSingle | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Object[]])
        Assert-True ($_.Items.Length -eq 0)
    }
    Group-ListItem -Size 0 -Window (New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(3.14))) | Assert-PipelineSingle | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Double[]])
        Assert-True ($_.Items.Length -eq 0)
    }

    foreach ($size in @($noarg, 1)) {
        $gliArgs = @{
            'Size' = $size
        }
        if ($noarg.Equals($size)) {
            $gliArgs.Remove('Size')
        }

        Group-ListItem @gliArgs -Window @($null) | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq 1)
            Assert-True ($null -eq $_.Items[0])
        }
        Group-ListItem @gliArgs -Window (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello world'))) | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq 1)
            Assert-True ('hello world' -eq $_.Items[0])
        }
        Group-ListItem @gliArgs -Window (New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(3.14))) | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Double[]])
            Assert-True ($_.Items.Length -eq 1)
            Assert-True (3.14 -eq $_.Items[0])
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Window with lists of length 2' -Verbose:$headerVerbosity

    $noarg = New-Object 'System.Object'

    $list1 = @($null, 5)
    $list2 = (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello', 'world')))
    $list3 = (New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(3.14, 2.72)))

    foreach ($size in @(-2, -1, 3)) {
        Group-ListItem -Size $size -Window $list1 | Assert-PipelineEmpty
        Group-ListItem -Size $size -Window $list2 | Assert-PipelineEmpty
        Group-ListItem -Size $size -Window $list3 | Assert-PipelineEmpty
    }

    Group-ListItem -Size 0 -Window $list1 | Assert-PipelineSingle | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Object[]])
        Assert-True ($_.Items.Length -eq 0)
    }
    Group-ListItem -Size 0 -Window $list2 | Assert-PipelineSingle | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Object[]])
        Assert-True ($_.Items.Length -eq 0)
    }
    Group-ListItem -Size 0 -Window $list3 | Assert-PipelineSingle | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Double[]])
        Assert-True ($_.Items.Length -eq 0)
    }

    $count = 0
    Group-ListItem -Size 1 -Window $list1 | Assert-PipelineCount 2 | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Object[]])
        Assert-True ($_.Items.Length -eq 1)
        Assert-True ($list1[$count] -eq $_.Items[0])
        $count++
    }
    $count = 0
    Group-ListItem -Size 1 -Window $list2 | Assert-PipelineCount 2 | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Object[]])
        Assert-True ($_.Items.Length -eq 1)
        Assert-True ($list2[$count] -eq $_.Items[0])
        $count++
    }
    $count = 0
    Group-ListItem -Size 1 -Window $list3 | Assert-PipelineCount 2 | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Double[]])
        Assert-True ($_.Items.Length -eq 1)
        Assert-True ($list3[$count] -eq $_.Items[0])
        $count++
    }

    foreach ($size in @($noarg, 2)) {
        $gliArgs = @{
            'Size' = $size
        }
        if ($noarg.Equals($size)) {
            $gliArgs.Remove('Size')
        }

        Group-ListItem @gliArgs -Window $list1 | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq 2)
            Assert-True ($null -eq $_.Items[0])
            Assert-True (5 -eq $_.Items[1])
        }

        Group-ListItem @gliArgs -Window $list2 | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq 2)
            Assert-True ('hello' -eq $_.Items[0])
            Assert-True ('world' -eq $_.Items[1])
        }

        Group-ListItem @gliArgs -Window $list3 | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Double[]])
            Assert-True ($_.Items.Length -eq 2)
            Assert-True (3.14 -eq $_.Items[0])
            Assert-True (2.72 -eq $_.Items[1])
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Window with lists of length 3' -Verbose:$headerVerbosity

    $noarg = New-Object 'System.Object'

    $list1 = @(3.14, 2.72, 0.00)
    $list2 = (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello', $null, 'world')))
    $list3 = (New-Object -TypeName 'System.Collections.Generic.List[System.Object]' -ArgumentList @(,[System.Object[]]@($null, 'hello', 3.14)))

    foreach ($size in @(-2, -1, 4)) {
        Group-ListItem -Size $size -Window $list1 | Assert-PipelineEmpty
        Group-ListItem -Size $size -Window $list2 | Assert-PipelineEmpty
        Group-ListItem -Size $size -Window $list3 | Assert-PipelineEmpty
    }

    Group-ListItem -Size 0 -Window $list1 | Assert-PipelineSingle | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Object[]])
        Assert-True ($_.Items.Length -eq 0)
    }
    Group-ListItem -Size 0 -Window $list2 | Assert-PipelineSingle | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Object[]])
        Assert-True ($_.Items.Length -eq 0)
    }
    Group-ListItem -Size 0 -Window $list3 | Assert-PipelineSingle | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Object[]])
        Assert-True ($_.Items.Length -eq 0)
    }

    foreach ($size in @(1..2)) {
        $count = 0
        Group-ListItem -Size $size -Window $list1 | Assert-PipelineCount (3 - $size + 1) | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq $size)
            for ($i = 0; $i -lt $size; $i++) {
                Assert-True ($list1[$count + $i] -eq $_.Items[$i])
            }
            $count++
        }
        $count = 0
        Group-ListItem -Size $size -Window $list2 | Assert-PipelineCount (3 - $size + 1) | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq $size)
            for ($i = 0; $i -lt $size; $i++) {
                Assert-True ($list2[$count + $i] -eq $_.Items[$i])
            }
            $count++
        }
        $count = 0
        Group-ListItem -Size $size -Window $list3 | Assert-PipelineCount (3 - $size + 1) | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq $size)
            for ($i = 0; $i -lt $size; $i++) {
                Assert-True ($list3[$count + $i] -eq $_.Items[$i])
            }
            $count++
        }
    }

    foreach ($size in @($noarg, 3)) {
        $gliArgs = @{
            'Size' = $size
        }
        if ($noarg.Equals($size)) {
            $gliArgs.Remove('Size')
        }

        Group-ListItem @gliArgs -Window $list1 | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq 3)
            Assert-True (3.14 -eq $_.Items[0])
            Assert-True (2.72 -eq $_.Items[1])
            Assert-True (0.00 -eq $_.Items[2])
        }

        Group-ListItem @gliArgs -Window $list2 | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq 3)
            Assert-True ('hello' -eq $_.Items[0])
            Assert-True ($null   -eq $_.Items[1])
            Assert-True ('world' -eq $_.Items[2])
        }

        Group-ListItem @gliArgs -Window $list3 | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq 3)
            Assert-True ($null   -eq $_.Items[0])
            Assert-True ('hello' -eq $_.Items[1])
            Assert-True (3.14    -eq $_.Items[2])
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Window with lists of length 4 or more' -Verbose:$headerVerbosity

    $noarg = New-Object 'System.Object'

    $list1 = @('a', 1, @(), ([System.Int32[]]@(1..5)))
    $list2 = (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello', @($null), 'world', 5)))
    $list3 = (New-Object -TypeName 'System.Collections.Generic.List[System.Int32]' -ArgumentList @(,[System.Int32[]]@(100, 200, 300, 400)))

    foreach ($size in @(-2, -1, 5)) {
        Group-ListItem -Size $size -Window $list1 | Assert-PipelineEmpty
        Group-ListItem -Size $size -Window $list2 | Assert-PipelineEmpty
        Group-ListItem -Size $size -Window $list3 | Assert-PipelineEmpty
    }

    Group-ListItem -Size 0 -Window $list1 | Assert-PipelineSingle | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Object[]])
        Assert-True ($_.Items.Length -eq 0)
    }
    Group-ListItem -Size 0 -Window $list2 | Assert-PipelineSingle | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Object[]])
        Assert-True ($_.Items.Length -eq 0)
    }
    Group-ListItem -Size 0 -Window $list3 | Assert-PipelineSingle | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Int32[]])
        Assert-True ($_.Items.Length -eq 0)
    }

    foreach ($size in @(1..3)) {
        $count = 0
        Group-ListItem -Size $size -Window $list1 | Assert-PipelineCount (4 - $size + 1) | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq $size)
            for ($i = 0; $i -lt $size; $i++) {
                Assert-True ($list1[$count + $i].Equals($_.Items[$i]))
            }
            $count++
        }
        $count = 0
        Group-ListItem -Size $size -Window $list2 | Assert-PipelineCount (4 - $size + 1) | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq $size)
            for ($i = 0; $i -lt $size; $i++) {
                Assert-True ($list2[$count + $i].Equals($_.Items[$i]))
            }
            $count++
        }
        $count = 0
        Group-ListItem -Size $size -Window $list3 | Assert-PipelineCount (4 - $size + 1) | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Int32[]])
            Assert-True ($_.Items.Length -eq $size)
            for ($i = 0; $i -lt $size; $i++) {
                Assert-True ($list3[$count + $i].Equals($_.Items[$i]))
            }
            $count++
        }
    }

    foreach ($size in @($noarg, 4)) {
        $gliArgs = @{
            'Size' = $size
        }
        if ($noarg.Equals($size)) {
            $gliArgs.Remove('Size')
        }

        Group-ListItem @gliArgs -Window $list1 | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq 4)
            Assert-True ($list1[0].Equals($_.Items[0]))
            Assert-True ($list1[1].Equals($_.Items[1]))
            Assert-True ($list1[2].Equals($_.Items[2]))
            Assert-True ($list1[3].Equals($_.Items[3]))
        }

        Group-ListItem @gliArgs -Window $list2 | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq 4)
            Assert-True ($list2[0].Equals($_.Items[0]))
            Assert-True ($list2[1].Equals($_.Items[1]))
            Assert-True ($list2[2].Equals($_.Items[2]))
            Assert-True ($list2[3].Equals($_.Items[3]))
        }

        Group-ListItem @gliArgs -Window $list3 | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Int32[]])
            Assert-True ($_.Items.Length -eq 4)
            Assert-True ($list3[0].Equals($_.Items[0]))
            Assert-True ($list3[1].Equals($_.Items[1]))
            Assert-True ($list3[2].Equals($_.Items[2]))
            Assert-True ($list3[3].Equals($_.Items[3]))
        }
    }

    for ($len = 5; $len -lt 10; $len++) {
        $list = [System.Int32[]]@(1..$len)

        Group-ListItem -Window $list -Size -1 | Assert-PipelineEmpty
        Group-ListItem -Window $list -Size ($len + 1) | Assert-PipelineEmpty
        Group-ListItem -Window $list -Size 0 | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Int32[]])
            Assert-True ($_.Items.Length -eq 0)
        }

        for ($size = 1; $size -le $len; $size++) {
            $count = 0
            Group-ListItem -Window $list -Size $size | Assert-PipelineCount ($len - $size + 1) | ForEach-Object {
                Assert-True ($_ -isnot [System.Collections.IEnumerable])
                Assert-True ($_.Items -is [System.Int32[]])
                Assert-True ($_.Items.Length -eq $size)
                for ($i = 0; $i -lt $size; $i++) {
                    Assert-True ($list[$count + $i].Equals($_.Items[$i]))
                }
                $count++
            }
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Combine with nulls' -Verbose:$headerVerbosity

    $noarg = New-Object 'System.Object'

    foreach ($size in @($noarg, -1, 0, 1)) {
        $gliArgs = @{
            'Size' = $size
        }
        if ($noarg.Equals($size)) {
            $gliArgs.Remove('Size')
        }

        $out1 = New-Object -TypeName 'System.Collections.ArrayList'
        $er1 = try {Group-ListItem @gliArgs -Combine $null -OutVariable out1 | Out-Null} catch {$_}

        Assert-True ($out1.Count -eq 0)
        Assert-True ($er1 -is [System.Management.Automation.ErrorRecord])
        Assert-True ($er1.FullyQualifiedErrorId.Equals('ParameterArgumentValidationErrorNullNotAllowed,Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($er1.Exception.ParameterName.Equals('Combine', [System.StringComparison]::OrdinalIgnoreCase))
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Combine with lists of length 0' -Verbose:$headerVerbosity

    $noarg = New-Object 'System.Object'

    foreach ($size in @(-2, -1, 1, 2)) {
        Group-ListItem -Size $size -Combine @() | Assert-PipelineEmpty
        Group-ListItem -Size $size -Combine (New-Object -TypeName 'System.Collections.ArrayList') | Assert-PipelineEmpty
        Group-ListItem -Size $size -Combine (New-Object -TypeName 'System.Collections.Generic.List[System.Double]') | Assert-PipelineEmpty
    }

    foreach ($size in @($noarg, 0)) {
        $gliArgs = @{
            'Size' = $size
        }
        if ($noarg.Equals($size)) {
            $gliArgs.Remove('Size')
        }

        Group-ListItem @gliArgs -Combine @() | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq 0)
        }
        Group-ListItem @gliArgs -Combine (New-Object -TypeName 'System.Collections.ArrayList') | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq 0)
        }
        Group-ListItem @gliArgs -Combine (New-Object -TypeName 'System.Collections.Generic.List[System.Double]') | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Double[]])
            Assert-True ($_.Items.Length -eq 0)
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Combine with lists of length 1' -Verbose:$headerVerbosity

    $noarg = New-Object 'System.Object'

    foreach ($size in @(-2, -1, 2)) {
        Group-ListItem -Size $size -Combine @($null) | Assert-PipelineEmpty
        Group-ListItem -Size $size -Combine (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello world'))) | Assert-PipelineEmpty
        Group-ListItem -Size $size -Combine (New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(3.14))) | Assert-PipelineEmpty
    }

    Group-ListItem -Size 0 -Combine @($null) | Assert-PipelineSingle | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Object[]])
        Assert-True ($_.Items.Length -eq 0)
    }
    Group-ListItem -Size 0 -Combine (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello world'))) | Assert-PipelineSingle | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Object[]])
        Assert-True ($_.Items.Length -eq 0)
    }
    Group-ListItem -Size 0 -Combine (New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(3.14))) | Assert-PipelineSingle | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Double[]])
        Assert-True ($_.Items.Length -eq 0)
    }

    foreach ($size in @($noarg, 1)) {
        $gliArgs = @{
            'Size' = $size
        }
        if ($noarg.Equals($size)) {
            $gliArgs.Remove('Size')
        }

        Group-ListItem @gliArgs -Combine @($null) | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq 1)
            Assert-True ($null -eq $_.Items[0])
        }
        Group-ListItem @gliArgs -Combine (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello world'))) | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq 1)
            Assert-True ('hello world' -eq $_.Items[0])
        }
        Group-ListItem @gliArgs -Combine (New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(3.14))) | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Double[]])
            Assert-True ($_.Items.Length -eq 1)
            Assert-True (3.14 -eq $_.Items[0])
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Combine with lists of length 2' -Verbose:$headerVerbosity

    $noarg = New-Object 'System.Object'

    $list1 = @($null, 5)
    $list2 = (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello', 'world')))
    $list3 = (New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(3.14, 2.72)))

    function oracle($list, $size = 2)
    {
        switch ($size) {
            0       {return @{'Items' = @()}}
            1       {return @{'Items' = @(,$list[0])}, @{'Items' = @(,$list[1])}}
            2       {return @{'Items' = @($list[0], $list[1])}}
            default {return}
        }
    }

    foreach ($size in @(-1, 0, 1, 2, 3, $noarg)) {
        if ($noarg.Equals($size)) {
            $gliArgs = @{}
            $expectedSize = 2
        } else {
            $gliArgs = @{'Size' = $size}
            $expectedSize = $size
        }

        $expected1 = @(oracle @gliArgs -list $list1)
        $expected2 = @(oracle @gliArgs -list $list2)
        $expected3 = @(oracle @gliArgs -list $list3)

        $outputCount = $expected1.Length
        Assert-True ($outputCount -eq $expected2.Length)
        Assert-True ($outputCount -eq $expected3.Length)

        $out1 = @(Group-ListItem @gliArgs -Combine $list1 | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq $expectedSize)
            $_
        })
        $out2 = @(Group-ListItem @gliArgs -Combine $list2 | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq $expectedSize)
            $_
        })
        $out3 = @(Group-ListItem @gliArgs -Combine $list3 | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Double[]])
            Assert-True ($_.Items.Length -eq $expectedSize)
            $_
        })

        for ($i = 0; $i -lt $outputCount; $i++) {
            for ($j = 0; $j -lt $expectedSize; $j++) {
                Assert-True ($expected1[$i].Items[$j] -eq $out1[$i].Items[$j])
                Assert-True ($expected2[$i].Items[$j] -eq $out2[$i].Items[$j])
                Assert-True ($expected3[$i].Items[$j] -eq $out3[$i].Items[$j])
            }
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Combine with lists of length 3' -Verbose:$headerVerbosity

    $noarg = New-Object 'System.Object'

    $list1 = @(3.14, 2.72, 0.00)
    $list2 = (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello', $null, 'world')))
    $list3 = (New-Object -TypeName 'System.Collections.Generic.List[System.Object]' -ArgumentList @(,[System.Object[]]@($null, 'hello', 3.14)))

    function oracle($list, $size = 3)
    {
        switch ($size) {
            0       {return @{'Items' = @()}}
            1       {return @{'Items' = @(,$list[0])},
                            @{'Items' = @(,$list[1])},
                            @{'Items' = @(,$list[2])}}
            2       {return @{'Items' = @($list[0], $list[1])},
                            @{'Items' = @($list[0], $list[2])},
                            @{'Items' = @($list[1], $list[2])}}
            3       {return @{'Items' = @($list[0], $list[1], $list[2])}}
            default {return}
        }
    }

    foreach ($size in @(-1, 0, 1, 2, 3, 4, $noarg)) {
        if ($noarg.Equals($size)) {
            $gliArgs = @{}
            $expectedSize = 3
        } else {
            $gliArgs = @{'Size' = $size}
            $expectedSize = $size
        }

        $expected1 = @(oracle @gliArgs -list $list1)
        $expected2 = @(oracle @gliArgs -list $list2)
        $expected3 = @(oracle @gliArgs -list $list3)

        $outputCount = $expected1.Length
        Assert-True ($outputCount -eq $expected2.Length)
        Assert-True ($outputCount -eq $expected3.Length)

        $out1 = @(Group-ListItem @gliArgs -Combine $list1 | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq $expectedSize)
            $_
        })
        $out2 = @(Group-ListItem @gliArgs -Combine $list2 | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq $expectedSize)
            $_
        })
        $out3 = @(Group-ListItem @gliArgs -Combine $list3 | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq $expectedSize)
            $_
        })

        for ($i = 0; $i -lt $outputCount; $i++) {
            for ($j = 0; $j -lt $expectedSize; $j++) {
                Assert-True ($expected1[$i].Items[$j] -eq $out1[$i].Items[$j])
                Assert-True ($expected2[$i].Items[$j] -eq $out2[$i].Items[$j])
                Assert-True ($expected3[$i].Items[$j] -eq $out3[$i].Items[$j])
            }
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Combine with lists of length 4 or more' -Verbose:$headerVerbosity

    $noarg = New-Object 'System.Object'

    $list1 = @('a', 1, @(), ([System.Int32[]]@(1..5)))
    $list2 = (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello', @($null), 'world', 5)))
    $list3 = (New-Object -TypeName 'System.Collections.Generic.List[System.Int32]' -ArgumentList @(,[System.Int32[]]@(100, 200, 300, 400)))

    function oracle($list, $size = 4)
    {
        switch ($size) {
            0       {return @{'Items' = @()}}
            1       {return @{'Items' = @(,$list[0])},
                            @{'Items' = @(,$list[1])},
                            @{'Items' = @(,$list[2])},
                            @{'Items' = @(,$list[3])}}
            2       {return @{'Items' = @($list[0], $list[1])},
                            @{'Items' = @($list[0], $list[2])},
                            @{'Items' = @($list[0], $list[3])},
                            @{'Items' = @($list[1], $list[2])},
                            @{'Items' = @($list[1], $list[3])},
                            @{'Items' = @($list[2], $list[3])}}
            3       {return @{'Items' = @($list[0], $list[1], $list[2])},
                            @{'Items' = @($list[0], $list[1], $list[3])},
                            @{'Items' = @($list[0], $list[2], $list[3])},
                            @{'Items' = @($list[1], $list[2], $list[3])}}
            4       {return @{'Items' = @($list[0], $list[1], $list[2], $list[3])}}
            default {return}
        }
    }

    foreach ($size in @(-1, 0, 1, 2, 3, 4, 5, $noarg)) {
        if ($noarg.Equals($size)) {
            $gliArgs = @{}
            $expectedSize = 4
        } else {
            $gliArgs = @{'Size' = $size}
            $expectedSize = $size
        }

        $expected1 = @(oracle @gliArgs -list $list1)
        $expected2 = @(oracle @gliArgs -list $list2)
        $expected3 = @(oracle @gliArgs -list $list3)

        $outputCount = $expected1.Length
        Assert-True ($outputCount -eq $expected2.Length)
        Assert-True ($outputCount -eq $expected3.Length)

        $out1 = @(Group-ListItem @gliArgs -Combine $list1 | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq $expectedSize)
            $_
        })
        $out2 = @(Group-ListItem @gliArgs -Combine $list2 | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq $expectedSize)
            $_
        })
        $out3 = @(Group-ListItem @gliArgs -Combine $list3 | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Int32[]])
            Assert-True ($_.Items.Length -eq $expectedSize)
            $_
        })

        for ($i = 0; $i -lt $outputCount; $i++) {
            for ($j = 0; $j -lt $expectedSize; $j++) {
                Assert-True ($expected1[$i].Items[$j].Equals($out1[$i].Items[$j]))
                Assert-True ($expected2[$i].Items[$j].Equals($out2[$i].Items[$j]))
                Assert-True ($expected3[$i].Items[$j].Equals($out3[$i].Items[$j]))
            }
        }
    }

    function numCombin($list, $k)
    {
        $n = $list.Length
        if ($n -lt $k) {
            return 0
        } elseif ($k -lt 0) {
            return 0
        } elseif ($k -eq 0) {
            return 1
        } elseif ($n -eq $k) {
            return 1
        } else {
            $num = 1
            $den = 1
            $($n - $k + 1)..$n | ForEach-Object {$num *= $_}
            1..$k | ForEach-Object {$den *= $_}
            return $num / $den
        }
    }

    for ($n = 5; $n -lt 10; $n++) {
        $list = [System.Int32[]]@(1..$n)

        for ($k = -1; $k -le $n + 1; $k++) {
            Group-ListItem -Combine $list -Size $k | Assert-PipelineCount (numCombin $list $k) | ForEach-Object {
                Assert-True ($_ -isnot [System.Collections.IEnumerable])
                Assert-True ($_.Items -is [System.Int32[]])
                Assert-True ($_.Items.Length -eq $k)
            }
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Permute with nulls' -Verbose:$headerVerbosity

    $noarg = New-Object 'System.Object'

    foreach ($size in @($noarg, -1, 0, 1)) {
        $gliArgs = @{
            'Size' = $size
        }
        if ($noarg.Equals($size)) {
            $gliArgs.Remove('Size')
        }

        $out1 = New-Object -TypeName 'System.Collections.ArrayList'
        $er1 = try {Group-ListItem @gliArgs -Permute $null -OutVariable out1 | Out-Null} catch {$_}

        Assert-True ($out1.Count -eq 0)
        Assert-True ($er1 -is [System.Management.Automation.ErrorRecord])
        Assert-True ($er1.FullyQualifiedErrorId.Equals('ParameterArgumentValidationErrorNullNotAllowed,Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($er1.Exception.ParameterName.Equals('Permute', [System.StringComparison]::OrdinalIgnoreCase))
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Permute with lists of length 0' -Verbose:$headerVerbosity

    $noarg = New-Object 'System.Object'

    foreach ($size in @(-2, -1, 1, 2)) {
        Group-ListItem -Size $size -Permute @() | Assert-PipelineEmpty
        Group-ListItem -Size $size -Permute (New-Object -TypeName 'System.Collections.ArrayList') | Assert-PipelineEmpty
        Group-ListItem -Size $size -Permute (New-Object -TypeName 'System.Collections.Generic.List[System.Double]') | Assert-PipelineEmpty
    }

    foreach ($size in @($noarg, 0)) {
        $gliArgs = @{
            'Size' = $size
        }
        if ($noarg.Equals($size)) {
            $gliArgs.Remove('Size')
        }

        Group-ListItem @gliArgs -Permute @() | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq 0)
        }
        Group-ListItem @gliArgs -Permute (New-Object -TypeName 'System.Collections.ArrayList') | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq 0)
        }
        Group-ListItem @gliArgs -Permute (New-Object -TypeName 'System.Collections.Generic.List[System.Double]') | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Double[]])
            Assert-True ($_.Items.Length -eq 0)
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Permute with lists of length 1' -Verbose:$headerVerbosity

    $noarg = New-Object 'System.Object'

    foreach ($size in @(-2, -1, 2)) {
        Group-ListItem -Size $size -Permute @($null) | Assert-PipelineEmpty
        Group-ListItem -Size $size -Permute (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello world'))) | Assert-PipelineEmpty
        Group-ListItem -Size $size -Permute (New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(3.14))) | Assert-PipelineEmpty
    }

    Group-ListItem -Size 0 -Permute @($null) | Assert-PipelineSingle | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Object[]])
        Assert-True ($_.Items.Length -eq 0)
    }
    Group-ListItem -Size 0 -Permute (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello world'))) | Assert-PipelineSingle | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Object[]])
        Assert-True ($_.Items.Length -eq 0)
    }
    Group-ListItem -Size 0 -Permute (New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(3.14))) | Assert-PipelineSingle | ForEach-Object {
        Assert-True ($_ -isnot [System.Collections.IEnumerable])
        Assert-True ($_.Items -is [System.Double[]])
        Assert-True ($_.Items.Length -eq 0)
    }

    foreach ($size in @($noarg, 1)) {
        $gliArgs = @{
            'Size' = $size
        }
        if ($noarg.Equals($size)) {
            $gliArgs.Remove('Size')
        }

        Group-ListItem @gliArgs -Permute @($null) | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq 1)
            Assert-True ($null -eq $_.Items[0])
        }
        Group-ListItem @gliArgs -Permute (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello world'))) | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq 1)
            Assert-True ('hello world' -eq $_.Items[0])
        }
        Group-ListItem @gliArgs -Permute (New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(3.14))) | Assert-PipelineSingle | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Double[]])
            Assert-True ($_.Items.Length -eq 1)
            Assert-True (3.14 -eq $_.Items[0])
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Permute with lists of length 2' -Verbose:$headerVerbosity

    $noarg = New-Object 'System.Object'

    $list1 = @($null, 5)
    $list2 = (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello', 'world')))
    $list3 = (New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(3.14, 2.72)))

    function oracle($list, $size = 2)
    {
        switch ($size) {
            0       {return @{'Items' = @()}}
            1       {return @{'Items' = @(,$list[0])}, @{'Items' = @(,$list[1])}}
            2       {return @{'Items' = @($list[0], $list[1])}, @{'Items' = @($list[1], $list[0])}}
            default {return}
        }
    }

    foreach ($size in @(-1, 0, 1, 2, 3, $noarg)) {
        if ($noarg.Equals($size)) {
            $gliArgs = @{}
            $expectedSize = 2
        } else {
            $gliArgs = @{'Size' = $size}
            $expectedSize = $size
        }

        $expected1 = @(oracle @gliArgs -list $list1)
        $expected2 = @(oracle @gliArgs -list $list2)
        $expected3 = @(oracle @gliArgs -list $list3)

        $outputCount = $expected1.Length
        Assert-True ($outputCount -eq $expected2.Length)
        Assert-True ($outputCount -eq $expected3.Length)

        $out1 = @(Group-ListItem @gliArgs -Permute $list1 | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq $expectedSize)
            $_
        })
        $out2 = @(Group-ListItem @gliArgs -Permute $list2 | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq $expectedSize)
            $_
        })
        $out3 = @(Group-ListItem @gliArgs -Permute $list3 | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Double[]])
            Assert-True ($_.Items.Length -eq $expectedSize)
            $_
        })

        for ($i = 0; $i -lt $outputCount; $i++) {
            for ($j = 0; $j -lt $expectedSize; $j++) {
                Assert-True ($expected1[$i].Items[$j] -eq $out1[$i].Items[$j])
                Assert-True ($expected2[$i].Items[$j] -eq $out2[$i].Items[$j])
                Assert-True ($expected3[$i].Items[$j] -eq $out3[$i].Items[$j])
            }
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Permute with lists of length 3' -Verbose:$headerVerbosity

    $noarg = New-Object 'System.Object'

    $list1 = @(3.14, 2.72, 0.00)
    $list2 = (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello', $null, 'world')))
    $list3 = (New-Object -TypeName 'System.Collections.Generic.List[System.Object]' -ArgumentList @(,[System.Object[]]@($null, 'hello', 3.14)))

    function oracle($list, $size = 3)
    {
        switch ($size) {
            0       {return @{'Items' = @()}}
            1       {return @{'Items' = @(,$list[0])},
                            @{'Items' = @(,$list[1])},
                            @{'Items' = @(,$list[2])}}
            2       {return @{'Items' = @($list[0], $list[1])},
                            @{'Items' = @($list[0], $list[2])},
                            @{'Items' = @($list[1], $list[0])},
                            @{'Items' = @($list[1], $list[2])},
                            @{'Items' = @($list[2], $list[0])},
                            @{'Items' = @($list[2], $list[1])}}
            3       {return @{'Items' = @($list[0], $list[1], $list[2])},
                            @{'Items' = @($list[0], $list[2], $list[1])},
                            @{'Items' = @($list[1], $list[0], $list[2])},
                            @{'Items' = @($list[1], $list[2], $list[0])},
                            @{'Items' = @($list[2], $list[0], $list[1])},
                            @{'Items' = @($list[2], $list[1], $list[0])}}
            default {return}
        }
    }

    foreach ($size in @(-1, 0, 1, 2, 3, 4, $noarg)) {
        if ($noarg.Equals($size)) {
            $gliArgs = @{}
            $expectedSize = 3
        } else {
            $gliArgs = @{'Size' = $size}
            $expectedSize = $size
        }

        $expected1 = @(oracle @gliArgs -list $list1)
        $expected2 = @(oracle @gliArgs -list $list2)
        $expected3 = @(oracle @gliArgs -list $list3)

        $outputCount = $expected1.Length
        Assert-True ($outputCount -eq $expected2.Length)
        Assert-True ($outputCount -eq $expected3.Length)

        $out1 = @(Group-ListItem @gliArgs -Permute $list1 | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq $expectedSize)
            $_
        })
        $out2 = @(Group-ListItem @gliArgs -Permute $list2 | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq $expectedSize)
            $_
        })
        $out3 = @(Group-ListItem @gliArgs -Permute $list3 | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq $expectedSize)
            $_
        })

        for ($i = 0; $i -lt $outputCount; $i++) {
            for ($j = 0; $j -lt $expectedSize; $j++) {
                Assert-True ($expected1[$i].Items[$j] -eq $out1[$i].Items[$j])
                Assert-True ($expected2[$i].Items[$j] -eq $out2[$i].Items[$j])
                Assert-True ($expected3[$i].Items[$j] -eq $out3[$i].Items[$j])
            }
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Permute with lists of length 4 or more' -Verbose:$headerVerbosity

    $noarg = New-Object 'System.Object'

    $list1 = @('a', 1, @(), ([System.Int32[]]@(1..5)))
    $list2 = (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello', @($null), 'world', 5)))
    $list3 = (New-Object -TypeName 'System.Collections.Generic.List[System.Int32]' -ArgumentList @(,[System.Int32[]]@(100, 200, 300, 400)))

    function oracle($list, $size = 4)
    {
        switch ($size) {
            0       {return @{'Items' = @()}}
            1       {return @{'Items' = @(,$list[0])},
                            @{'Items' = @(,$list[1])},
                            @{'Items' = @(,$list[2])},
                            @{'Items' = @(,$list[3])}}
            2       {return @{'Items' = @($list[0], $list[1])},
                            @{'Items' = @($list[0], $list[2])},
                            @{'Items' = @($list[0], $list[3])},
                            @{'Items' = @($list[1], $list[0])},
                            @{'Items' = @($list[1], $list[2])},
                            @{'Items' = @($list[1], $list[3])},
                            @{'Items' = @($list[2], $list[0])},
                            @{'Items' = @($list[2], $list[1])},
                            @{'Items' = @($list[2], $list[3])},
                            @{'Items' = @($list[3], $list[0])},
                            @{'Items' = @($list[3], $list[1])},
                            @{'Items' = @($list[3], $list[2])}}
            3       {return @{'Items' = @($list[0], $list[1], $list[2])},
                            @{'Items' = @($list[0], $list[1], $list[3])},
                            @{'Items' = @($list[0], $list[2], $list[1])},
                            @{'Items' = @($list[0], $list[2], $list[3])},
                            @{'Items' = @($list[0], $list[3], $list[1])},
                            @{'Items' = @($list[0], $list[3], $list[2])},
                            @{'Items' = @($list[1], $list[0], $list[2])},
                            @{'Items' = @($list[1], $list[0], $list[3])},
                            @{'Items' = @($list[1], $list[2], $list[0])},
                            @{'Items' = @($list[1], $list[2], $list[3])},
                            @{'Items' = @($list[1], $list[3], $list[0])},
                            @{'Items' = @($list[1], $list[3], $list[2])},
                            @{'Items' = @($list[2], $list[0], $list[1])},
                            @{'Items' = @($list[2], $list[0], $list[3])},
                            @{'Items' = @($list[2], $list[1], $list[0])},
                            @{'Items' = @($list[2], $list[1], $list[3])},
                            @{'Items' = @($list[2], $list[3], $list[0])},
                            @{'Items' = @($list[2], $list[3], $list[1])},
                            @{'Items' = @($list[3], $list[0], $list[1])},
                            @{'Items' = @($list[3], $list[0], $list[2])},
                            @{'Items' = @($list[3], $list[1], $list[0])},
                            @{'Items' = @($list[3], $list[1], $list[2])},
                            @{'Items' = @($list[3], $list[2], $list[0])},
                            @{'Items' = @($list[3], $list[2], $list[1])}}
            4       {return @{'Items' = @($list[0], $list[1], $list[2], $list[3])},
                            @{'Items' = @($list[0], $list[1], $list[3], $list[2])},
                            @{'Items' = @($list[0], $list[2], $list[1], $list[3])},
                            @{'Items' = @($list[0], $list[2], $list[3], $list[1])},
                            @{'Items' = @($list[0], $list[3], $list[1], $list[2])},
                            @{'Items' = @($list[0], $list[3], $list[2], $list[1])},
                            @{'Items' = @($list[1], $list[0], $list[2], $list[3])},
                            @{'Items' = @($list[1], $list[0], $list[3], $list[2])},
                            @{'Items' = @($list[1], $list[2], $list[0], $list[3])},
                            @{'Items' = @($list[1], $list[2], $list[3], $list[0])},
                            @{'Items' = @($list[1], $list[3], $list[0], $list[2])},
                            @{'Items' = @($list[1], $list[3], $list[2], $list[0])},
                            @{'Items' = @($list[2], $list[0], $list[1], $list[3])},
                            @{'Items' = @($list[2], $list[0], $list[3], $list[1])},
                            @{'Items' = @($list[2], $list[1], $list[0], $list[3])},
                            @{'Items' = @($list[2], $list[1], $list[3], $list[0])},
                            @{'Items' = @($list[2], $list[3], $list[0], $list[1])},
                            @{'Items' = @($list[2], $list[3], $list[1], $list[0])},
                            @{'Items' = @($list[3], $list[0], $list[1], $list[2])},
                            @{'Items' = @($list[3], $list[0], $list[2], $list[1])},
                            @{'Items' = @($list[3], $list[1], $list[0], $list[2])},
                            @{'Items' = @($list[3], $list[1], $list[2], $list[0])},
                            @{'Items' = @($list[3], $list[2], $list[0], $list[1])},
                            @{'Items' = @($list[3], $list[2], $list[1], $list[0])}}
            default {return}
        }
    }

    foreach ($size in @(-1, 0, 1, 2, 3, 4, 5, $noarg)) {
        if ($noarg.Equals($size)) {
            $gliArgs = @{}
            $expectedSize = 4
        } else {
            $gliArgs = @{'Size' = $size}
            $expectedSize = $size
        }

        $expected1 = @(oracle @gliArgs -list $list1)
        $expected2 = @(oracle @gliArgs -list $list2)
        $expected3 = @(oracle @gliArgs -list $list3)

        $outputCount = $expected1.Length
        Assert-True ($outputCount -eq $expected2.Length)
        Assert-True ($outputCount -eq $expected3.Length)

        $out1 = @(Group-ListItem @gliArgs -Permute $list1 | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq $expectedSize)
            $_
        })
        $out2 = @(Group-ListItem @gliArgs -Permute $list2 | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Object[]])
            Assert-True ($_.Items.Length -eq $expectedSize)
            $_
        })
        $out3 = @(Group-ListItem @gliArgs -Permute $list3 | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
            Assert-True ($_.Items -is [System.Int32[]])
            Assert-True ($_.Items.Length -eq $expectedSize)
            $_
        })

        for ($i = 0; $i -lt $outputCount; $i++) {
            for ($j = 0; $j -lt $expectedSize; $j++) {
                Assert-True ($expected1[$i].Items[$j].Equals($out1[$i].Items[$j]))
                Assert-True ($expected2[$i].Items[$j].Equals($out2[$i].Items[$j]))
                Assert-True ($expected3[$i].Items[$j].Equals($out3[$i].Items[$j]))
            }
        }
    }

    function numPermut($list, $k)
    {
        $n = $list.Length
        if ($n -lt $k) {
            return 0
        } elseif ($k -lt 0) {
            return 0
        } elseif ($k -eq 0) {
            return 1
        } elseif ($n -eq $k) {
            $num = 1
            1..$n | ForEach-Object {$num *= $_}
            return $num
        } else {
            $num = 1
            $($n - $k + 1)..$n | ForEach-Object {$num *= $_}
            return $num
        }
    }

    for ($n = 5; $n -lt 7; $n++) {
        $list = [System.Int32[]]@(1..$n)

        for ($k = -1; $k -le $n + 1; $k++) {
            Group-ListItem -Permute $list -Size $k | Assert-PipelineCount (numPermut $list $k) | ForEach-Object {
                Assert-True ($_ -isnot [System.Collections.IEnumerable])
                Assert-True ($_.Items -is [System.Int32[]])
                Assert-True ($_.Items.Length -eq $k)
            }
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Zip with nulls' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $out3 = New-Object -TypeName 'System.Collections.ArrayList'
    $out4 = New-Object -TypeName 'System.Collections.ArrayList'

    $er1 = try {Group-ListItem -Zip $null -OutVariable out1 | Out-Null} catch {$_}
    $er2 = try {Group-ListItem -Zip @($null) -OutVariable out2 | Out-Null} catch {$_}
    $er3 = try {Group-ListItem -Zip (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList (,@(@(1,2,3), $null))) -OutVariable out3 | Out-Null} catch {$_}
    $er4 = try {Group-ListItem -Zip (New-Object -TypeName 'System.Collections.Generic.List[System.Object]' -ArgumentList (,@($null, @(4,5,6)))) -OutVariable out4 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 0)
    Assert-True ($out2.Count -eq 0)
    Assert-True ($out3.Count -eq 0)
    Assert-True ($out4.Count -eq 0)

    Assert-True ($er1 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er2 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er3 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er4 -is [System.Management.Automation.ErrorRecord])

    Assert-True ($er1.FullyQualifiedErrorId.Equals('ParameterArgumentValidationError,Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er2.FullyQualifiedErrorId.Equals('ParameterArgumentValidationError,Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er3.FullyQualifiedErrorId.Equals('ParameterArgumentValidationError,Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er4.FullyQualifiedErrorId.Equals('ParameterArgumentValidationError,Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase))

    Assert-True $er1.Exception.ParameterName.Equals('Zip', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True $er2.Exception.ParameterName.Equals('Zip', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True $er3.Exception.ParameterName.Equals('Zip', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True $er4.Exception.ParameterName.Equals('Zip', [System.StringComparison]::OrdinalIgnoreCase)
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Zip with lists of length 0' -Verbose:$headerVerbosity

    Group-ListItem -Zip @(,@()) | Assert-PipelineEmpty

    Group-ListItem -Zip @(@(), (New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@()))) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@(), @($null)) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@($null), @()) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@(1,2), (New-Object -TypeName 'System.Collections.ArrayList')) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@(), (New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@(1,2)))) | Assert-PipelineEmpty

    Group-ListItem -Zip @(@(), @(), @()) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@(), @($null), @(1,2)) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@(1,2), @(), @($null)) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@($null), @(1,2), @()) | Assert-PipelineEmpty

    Group-ListItem -Zip @(@(), @(), @(), @()) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@(), @($null), @(1,2), @('a','b','c')) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@($null), @(), @(1,2), @('a','b','c')) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@($null), @(1,2), @(), @('a','b','c')) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@($null), @(1,2), @('a','b','c'), @()) | Assert-PipelineEmpty
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Zip with no lists' -Verbose:$headerVerbosity

    Group-ListItem -Zip @() | Assert-PipelineEmpty
    Group-ListItem -Zip (New-Object -TypeName 'System.Collections.ArrayList') | Assert-PipelineEmpty
    Group-ListItem -Zip (New-Object -TypeName 'System.Collections.Generic.List[System.Byte[]]') | Assert-PipelineEmpty
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Zip with 1 list' -Verbose:$headerVerbosity

    $list1 = [System.String[]]@('a')
    $list2 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@($null, @()))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(0.00, 2.72, 3.14))
    $list4 = [System.Double[]]@(100, 200, 300, 400)
    $list5 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@(@($null), @(), 'hi', $null, 5))
    $list6 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('hello', 'world', 'how', 'are', 'you', 'today'))

    function oracleType($list)
    {
        if ($list[0].Equals($list1) -or $list[0].Equals($list6)) {
            return [System.String[]]
        } elseif ($list[0].Equals($list3) -or $list[0].Equals($list4)) {
            return [System.Double[]]
        } else {
            return [System.Object[]]
        }
    }

    function oracleOutput($list)
    {
        $count = $list[0].Count
        for ($i = 0; $i -lt $count; $i++) {
            @{'Items' = @(,$list[0][$i])}
        }
    }
    
    foreach ($list in @(@(,$list1), @(,$list2), @(,$list3), @(,$list4), @(,$list5), @(,$list6))) {
        $expectedType = oracleType $list
        $expectedOutput = @(oracleOutput $list)
        $outputCount = $expectedOutput.Length

        $i = 0
        Group-ListItem -Zip $list | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_.Items -is $expectedType)
            Assert-True ($_.Items.Length -eq $expectedOutput[$i].Items.Length)

            $itemCount = $_.Items.Length
            for ($j = 0; $j -lt $itemCount; $j++) {
                if ($null -eq $_.Items[$j]) {
                    Assert-True ($_.Items[$j] -eq $expectedOutput[$i].Items[$j])
                } else {
                    Assert-True ($_.Items[$j].Equals($expectedOutput[$i].Items[$j]))
                }
            }

            $i++
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Zip with 2 lists' -Verbose:$headerVerbosity

    $list1 = [System.String[]]@('a')
    $list2 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@($null, @()))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(0.00, 2.72, 3.14))
    $list4 = [System.Double[]]@(100, 200, 300, 400)
    $list5 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@(@($null), @(), 'hi', $null, 5))
    $list6 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('hello', 'world', 'how', 'are', 'you', 'today'))

    function oracleType($list)
    {
        if ($list[0].Equals($list1) -and $list[1].Equals($list6)) {
            return [System.String[]]
        } elseif ($list[0].Equals($list6) -and $list[1].Equals($list1)) {
            return [System.String[]]
        } elseif ($list[0].Equals($list1) -and $list[1].Equals($list1)) {
            return [System.String[]]
        } elseif ($list[0].Equals($list6) -and $list[1].Equals($list6)) {
            return [System.String[]]
        } elseif ($list[0].Equals($list3) -and $list[1].Equals($list4)) {
            return [System.Double[]]
        } elseif ($list[0].Equals($list4) -and $list[1].Equals($list3)) {
            return [System.Double[]]
        } elseif ($list[0].Equals($list3) -and $list[1].Equals($list3)) {
            return [System.Double[]]
        } elseif ($list[0].Equals($list4) -and $list[1].Equals($list4)) {
            return [System.Double[]]
        } else {
            return [System.Object[]]
        }
    }

    function oracleOutput($list)
    {
        $count = @($list[0].Count, $list[1].Count | Sort-Object)[0]
        for ($i = 0; $i -lt $count; $i++) {
            @{'Items' = @($list[0][$i], $list[1][$i])}
        }
    }
    
    $lists = @(
        @($list1, $list1), @($list1, $list2), @($list1, $list3), @($list1, $list4), @($list1, $list5), @($list1, $list6),
        @($list2, $list1), @($list2, $list2), @($list2, $list3), @($list2, $list4), @($list2, $list5), @($list2, $list6),
        @($list3, $list1), @($list3, $list2), @($list3, $list3), @($list3, $list4), @($list3, $list5), @($list3, $list6),
        @($list4, $list1), @($list4, $list2), @($list4, $list3), @($list4, $list4), @($list4, $list5), @($list4, $list6),
        @($list5, $list1), @($list5, $list2), @($list5, $list3), @($list5, $list4), @($list5, $list5), @($list5, $list6),
        @($list6, $list1), @($list6, $list2), @($list6, $list3), @($list6, $list4), @($list6, $list5), @($list6, $list6)
    )

    foreach ($list in $lists) {
        $expectedType = oracleType $list
        $expectedOutput = @(oracleOutput $list)
        $outputCount = $expectedOutput.Length

        $i = 0
        Group-ListItem -Zip $list | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_.Items -is $expectedType)
            Assert-True ($_.Items.Length -eq $expectedOutput[$i].Items.Length)

            $itemCount = $_.Items.Length
            for ($j = 0; $j -lt $itemCount; $j++) {
                if ($null -eq $_.Items[$j]) {
                    Assert-True ($_.Items[$j] -eq $expectedOutput[$i].Items[$j])
                } else {
                    Assert-True ($_.Items[$j].Equals($expectedOutput[$i].Items[$j]))
                }
            }

            $i++
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Zip with 3 lists' -Verbose:$headerVerbosity

    $list1 = [System.String[]]@('a')
    $list2 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@($null, @()))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(0.00, 2.72, 3.14))
    $list4 = [System.String[]]@('100', '200', '300', '400')
    $list5 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@(@($null), @(), 'hi', $null, 5))
    $list6 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('hello', 'world', 'how', 'are', 'you', 'today'))

    function oracleType($list)
    {
        if ($list[0].Equals($list3) -and $list[1].Equals($list3) -and $list[2].Equals($list3)) {
            return [System.Double[]]
        } elseif ($list[0].Equals($list2) -or $list[0].Equals($list3) -or $list[0].Equals($list5)) {
            return [System.Object[]]
        } elseif ($list[1].Equals($list2) -or $list[1].Equals($list3) -or $list[1].Equals($list5)) {
            return [System.Object[]]
        } elseif ($list[2].Equals($list2) -or $list[2].Equals($list3) -or $list[2].Equals($list5)) {
            return [System.Object[]]
        } else {
            return [System.String[]]
        }
    }

    function oracleOutput($list)
    {
        $count = @($list[0].Count, $list[1].Count, $list[2].Count | Sort-Object)[0]
        for ($i = 0; $i -lt $count; $i++) {
            @{'Items' = @($list[0][$i], $list[1][$i], $list[2][$i])}
        }
    }
    
    $lists = @(
        @($list1, $list2, $list3), @($list1, $list2, $list4), @($list1, $list2, $list5), @($list1, $list2, $list6),
        @($list1, $list3, $list2), @($list1, $list3, $list4), @($list1, $list3, $list5), @($list1, $list3, $list6),
        @($list1, $list4, $list2), @($list1, $list4, $list3), @($list1, $list4, $list5), @($list1, $list4, $list6),
        @($list1, $list5, $list2), @($list1, $list5, $list3), @($list1, $list5, $list4), @($list1, $list5, $list6),
        @($list1, $list6, $list2), @($list1, $list6, $list3), @($list1, $list6, $list4), @($list1, $list6, $list5),
        @($list2, $list1, $list3), @($list2, $list1, $list4), @($list2, $list1, $list5), @($list2, $list1, $list6),
        @($list2, $list3, $list1), @($list2, $list3, $list4), @($list2, $list3, $list5), @($list2, $list3, $list6),
        @($list2, $list4, $list1), @($list2, $list4, $list3), @($list2, $list4, $list5), @($list2, $list4, $list6),
        @($list2, $list5, $list1), @($list2, $list5, $list3), @($list2, $list5, $list4), @($list2, $list5, $list6),
        @($list2, $list6, $list1), @($list2, $list6, $list3), @($list2, $list6, $list4), @($list2, $list6, $list5),
        @($list3, $list1, $list2), @($list3, $list1, $list4), @($list3, $list1, $list5), @($list3, $list1, $list6),
        @($list3, $list2, $list1), @($list3, $list2, $list4), @($list3, $list2, $list5), @($list3, $list2, $list6),
        @($list3, $list4, $list1), @($list3, $list4, $list2), @($list3, $list4, $list5), @($list3, $list4, $list6),
        @($list3, $list5, $list1), @($list3, $list5, $list2), @($list3, $list5, $list4), @($list3, $list5, $list6),
        @($list3, $list6, $list1), @($list3, $list6, $list2), @($list3, $list6, $list4), @($list3, $list6, $list5),
        @($list4, $list1, $list2), @($list4, $list1, $list3), @($list4, $list1, $list5), @($list4, $list1, $list6),
        @($list4, $list2, $list1), @($list4, $list2, $list3), @($list4, $list2, $list5), @($list4, $list2, $list6),
        @($list4, $list3, $list1), @($list4, $list3, $list2), @($list4, $list3, $list5), @($list4, $list3, $list6),
        @($list4, $list5, $list1), @($list4, $list5, $list2), @($list4, $list5, $list3), @($list4, $list5, $list6),
        @($list4, $list6, $list1), @($list4, $list6, $list2), @($list4, $list6, $list3), @($list4, $list6, $list5),
        @($list5, $list1, $list2), @($list5, $list1, $list3), @($list5, $list1, $list4), @($list5, $list1, $list6),
        @($list5, $list2, $list1), @($list5, $list2, $list3), @($list5, $list2, $list4), @($list5, $list2, $list6),
        @($list5, $list3, $list1), @($list5, $list3, $list2), @($list5, $list3, $list4), @($list5, $list3, $list6),
        @($list5, $list4, $list1), @($list5, $list4, $list2), @($list5, $list4, $list3), @($list5, $list4, $list6),
        @($list5, $list6, $list1), @($list5, $list6, $list2), @($list5, $list6, $list3), @($list5, $list6, $list4),
        @($list6, $list1, $list2), @($list6, $list1, $list3), @($list6, $list1, $list4), @($list6, $list1, $list5),
        @($list6, $list2, $list1), @($list6, $list2, $list3), @($list6, $list2, $list4), @($list6, $list2, $list5),
        @($list6, $list3, $list1), @($list6, $list3, $list2), @($list6, $list3, $list4), @($list6, $list3, $list5),
        @($list6, $list4, $list1), @($list6, $list4, $list2), @($list6, $list4, $list3), @($list6, $list4, $list5),
        @($list6, $list5, $list1), @($list6, $list5, $list2), @($list6, $list5, $list3), @($list6, $list5, $list4)
    )

    foreach ($list in $lists) {
        $expectedType = oracleType $list
        $expectedOutput = @(oracleOutput $list)
        $outputCount = $expectedOutput.Length

        $i = 0
        Group-ListItem -Zip $list | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_.Items -is $expectedType)
            Assert-True ($_.Items.Length -eq $expectedOutput[$i].Items.Length)

            $itemCount = $_.Items.Length
            for ($j = 0; $j -lt $itemCount; $j++) {
                if ($null -eq $_.Items[$j]) {
                    Assert-True ($_.Items[$j] -eq $expectedOutput[$i].Items[$j])
                } else {
                    Assert-True ($_.Items[$j].Equals($expectedOutput[$i].Items[$j]))
                }
            }

            $i++
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Zip with 4 lists' -Verbose:$headerVerbosity

    $list1 = [System.String[]]@('a')
    $list2 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@($null, @()))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('0.00', '2.72', '3.14'))
    $list4 = [System.String[]]@('100', '200', '300', '400')
    $list5 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@(@($null), @(), 'hi', $null, 5))
    $list6 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('hello', 'world', 'how', 'are', 'you', 'today'))

    function oracleType($list)
    {
        if ($list[0].Equals($list2) -or $list[0].Equals($list5)) {
            return [System.Object[]]
        } elseif ($list[1].Equals($list2) -or $list[1].Equals($list5)) {
            return [System.Object[]]
        } elseif ($list[2].Equals($list2) -or $list[2].Equals($list5)) {
            return [System.Object[]]
        } elseif ($list[3].Equals($list2) -or $list[3].Equals($list5)) {
            return [System.Object[]]
        } else {
            return [System.String[]]
        }
    }

    function oracleOutput($list)
    {
        $count = @($list[0].Count, $list[1].Count, $list[2].Count, $list[3].Count | Sort-Object)[0]
        for ($i = 0; $i -lt $count; $i++) {
            @{'Items' = @($list[0][$i], $list[1][$i], $list[2][$i], $list[3][$i])}
        }
    }
    
    $lists = @(
        @($list1, $list2, $list3, $list4), @($list1, $list2, $list3, $list5), @($list1, $list2, $list3, $list6),
        @($list1, $list2, $list4, $list3), @($list1, $list2, $list4, $list5), @($list1, $list2, $list4, $list6),
        @($list1, $list2, $list5, $list3), @($list1, $list2, $list5, $list4), @($list1, $list2, $list5, $list6),
        @($list1, $list2, $list6, $list3), @($list1, $list2, $list6, $list4), @($list1, $list2, $list6, $list5),
        @($list1, $list3, $list2, $list4), @($list1, $list3, $list2, $list5), @($list1, $list3, $list2, $list6),
        @($list1, $list3, $list4, $list2), @($list1, $list3, $list4, $list5), @($list1, $list3, $list4, $list6),
        @($list1, $list3, $list5, $list2), @($list1, $list3, $list5, $list4), @($list1, $list3, $list5, $list6),
        @($list1, $list3, $list6, $list2), @($list1, $list3, $list6, $list4), @($list1, $list3, $list6, $list5),
        @($list1, $list4, $list2, $list3), @($list1, $list4, $list2, $list5), @($list1, $list4, $list2, $list6),
        @($list1, $list4, $list3, $list2), @($list1, $list4, $list3, $list5), @($list1, $list4, $list3, $list6),
        @($list1, $list4, $list5, $list2), @($list1, $list4, $list5, $list3), @($list1, $list4, $list5, $list6),
        @($list1, $list4, $list6, $list2), @($list1, $list4, $list6, $list3), @($list1, $list4, $list6, $list5),
        @($list1, $list5, $list2, $list3), @($list1, $list5, $list2, $list4), @($list1, $list5, $list2, $list6),
        @($list1, $list5, $list3, $list2), @($list1, $list5, $list3, $list4), @($list1, $list5, $list3, $list6),
        @($list1, $list5, $list4, $list2), @($list1, $list5, $list4, $list3), @($list1, $list5, $list4, $list6),
        @($list1, $list5, $list6, $list2), @($list1, $list5, $list6, $list3), @($list1, $list5, $list6, $list4),
        @($list1, $list6, $list2, $list3), @($list1, $list6, $list2, $list4), @($list1, $list6, $list2, $list5),
        @($list1, $list6, $list3, $list2), @($list1, $list6, $list3, $list4), @($list1, $list6, $list3, $list5),
        @($list1, $list6, $list4, $list2), @($list1, $list6, $list4, $list3), @($list1, $list6, $list4, $list5),
        @($list1, $list6, $list5, $list2), @($list1, $list6, $list5, $list3), @($list1, $list6, $list5, $list4),
        @($list2, $list1, $list3, $list4), @($list2, $list1, $list3, $list5), @($list2, $list1, $list3, $list6),
        @($list2, $list1, $list4, $list3), @($list2, $list1, $list4, $list5), @($list2, $list1, $list4, $list6),
        @($list2, $list1, $list5, $list3), @($list2, $list1, $list5, $list4), @($list2, $list1, $list5, $list6),
        @($list2, $list1, $list6, $list3), @($list2, $list1, $list6, $list4), @($list2, $list1, $list6, $list5),
        @($list2, $list3, $list1, $list4), @($list2, $list3, $list1, $list5), @($list2, $list3, $list1, $list6),
        @($list2, $list3, $list4, $list1), @($list2, $list3, $list4, $list5), @($list2, $list3, $list4, $list6),
        @($list2, $list3, $list5, $list1), @($list2, $list3, $list5, $list4), @($list2, $list3, $list5, $list6),
        @($list2, $list3, $list6, $list1), @($list2, $list3, $list6, $list4), @($list2, $list3, $list6, $list5),
        @($list2, $list4, $list1, $list3), @($list2, $list4, $list1, $list5), @($list2, $list4, $list1, $list6),
        @($list2, $list4, $list3, $list1), @($list2, $list4, $list3, $list5), @($list2, $list4, $list3, $list6),
        @($list2, $list4, $list5, $list1), @($list2, $list4, $list5, $list3), @($list2, $list4, $list5, $list6),
        @($list2, $list4, $list6, $list1), @($list2, $list4, $list6, $list3), @($list2, $list4, $list6, $list5),
        @($list2, $list5, $list1, $list3), @($list2, $list5, $list1, $list4), @($list2, $list5, $list1, $list6),
        @($list2, $list5, $list3, $list1), @($list2, $list5, $list3, $list4), @($list2, $list5, $list3, $list6),
        @($list2, $list5, $list4, $list1), @($list2, $list5, $list4, $list3), @($list2, $list5, $list4, $list6),
        @($list2, $list5, $list6, $list1), @($list2, $list5, $list6, $list3), @($list2, $list5, $list6, $list4),
        @($list2, $list6, $list1, $list3), @($list2, $list6, $list1, $list4), @($list2, $list6, $list1, $list5),
        @($list2, $list6, $list3, $list1), @($list2, $list6, $list3, $list4), @($list2, $list6, $list3, $list5),
        @($list2, $list6, $list4, $list1), @($list2, $list6, $list4, $list3), @($list2, $list6, $list4, $list5),
        @($list2, $list6, $list5, $list1), @($list2, $list6, $list5, $list3), @($list2, $list6, $list5, $list4),
        @($list3, $list1, $list2, $list4), @($list3, $list1, $list2, $list5), @($list3, $list1, $list2, $list6),
        @($list3, $list1, $list4, $list2), @($list3, $list1, $list4, $list5), @($list3, $list1, $list4, $list6),
        @($list3, $list1, $list5, $list2), @($list3, $list1, $list5, $list4), @($list3, $list1, $list5, $list6),
        @($list3, $list1, $list6, $list2), @($list3, $list1, $list6, $list4), @($list3, $list1, $list6, $list5),
        @($list3, $list2, $list1, $list4), @($list3, $list2, $list1, $list5), @($list3, $list2, $list1, $list6),
        @($list3, $list2, $list4, $list1), @($list3, $list2, $list4, $list5), @($list3, $list2, $list4, $list6),
        @($list3, $list2, $list5, $list1), @($list3, $list2, $list5, $list4), @($list3, $list2, $list5, $list6),
        @($list3, $list2, $list6, $list1), @($list3, $list2, $list6, $list4), @($list3, $list2, $list6, $list5),
        @($list3, $list4, $list1, $list2), @($list3, $list4, $list1, $list5), @($list3, $list4, $list1, $list6),
        @($list3, $list4, $list2, $list1), @($list3, $list4, $list2, $list5), @($list3, $list4, $list2, $list6),
        @($list3, $list4, $list5, $list1), @($list3, $list4, $list5, $list2), @($list3, $list4, $list5, $list6),
        @($list3, $list4, $list6, $list1), @($list3, $list4, $list6, $list2), @($list3, $list4, $list6, $list5),
        @($list3, $list5, $list1, $list2), @($list3, $list5, $list1, $list4), @($list3, $list5, $list1, $list6),
        @($list3, $list5, $list2, $list1), @($list3, $list5, $list2, $list4), @($list3, $list5, $list2, $list6),
        @($list3, $list5, $list4, $list1), @($list3, $list5, $list4, $list2), @($list3, $list5, $list4, $list6),
        @($list3, $list5, $list6, $list1), @($list3, $list5, $list6, $list2), @($list3, $list5, $list6, $list4),
        @($list3, $list6, $list1, $list2), @($list3, $list6, $list1, $list4), @($list3, $list6, $list1, $list5),
        @($list3, $list6, $list2, $list1), @($list3, $list6, $list2, $list4), @($list3, $list6, $list2, $list5),
        @($list3, $list6, $list4, $list1), @($list3, $list6, $list4, $list2), @($list3, $list6, $list4, $list5),
        @($list3, $list6, $list5, $list1), @($list3, $list6, $list5, $list2), @($list3, $list6, $list5, $list4),
        @($list4, $list1, $list2, $list3), @($list4, $list1, $list2, $list5), @($list4, $list1, $list2, $list6),
        @($list4, $list1, $list3, $list2), @($list4, $list1, $list3, $list5), @($list4, $list1, $list3, $list6),
        @($list4, $list1, $list5, $list2), @($list4, $list1, $list5, $list3), @($list4, $list1, $list5, $list6),
        @($list4, $list1, $list6, $list2), @($list4, $list1, $list6, $list3), @($list4, $list1, $list6, $list5),
        @($list4, $list2, $list1, $list3), @($list4, $list2, $list1, $list5), @($list4, $list2, $list1, $list6),
        @($list4, $list2, $list3, $list1), @($list4, $list2, $list3, $list5), @($list4, $list2, $list3, $list6),
        @($list4, $list2, $list5, $list1), @($list4, $list2, $list5, $list3), @($list4, $list2, $list5, $list6),
        @($list4, $list2, $list6, $list1), @($list4, $list2, $list6, $list3), @($list4, $list2, $list6, $list5),
        @($list4, $list3, $list1, $list2), @($list4, $list3, $list1, $list5), @($list4, $list3, $list1, $list6),
        @($list4, $list3, $list2, $list1), @($list4, $list3, $list2, $list5), @($list4, $list3, $list2, $list6),
        @($list4, $list3, $list5, $list1), @($list4, $list3, $list5, $list2), @($list4, $list3, $list5, $list6),
        @($list4, $list3, $list6, $list1), @($list4, $list3, $list6, $list2), @($list4, $list3, $list6, $list5),
        @($list4, $list5, $list1, $list2), @($list4, $list5, $list1, $list3), @($list4, $list5, $list1, $list6),
        @($list4, $list5, $list2, $list1), @($list4, $list5, $list2, $list3), @($list4, $list5, $list2, $list6),
        @($list4, $list5, $list3, $list1), @($list4, $list5, $list3, $list2), @($list4, $list5, $list3, $list6),
        @($list4, $list5, $list6, $list1), @($list4, $list5, $list6, $list2), @($list4, $list5, $list6, $list3),
        @($list4, $list6, $list1, $list2), @($list4, $list6, $list1, $list3), @($list4, $list6, $list1, $list5),
        @($list4, $list6, $list2, $list1), @($list4, $list6, $list2, $list3), @($list4, $list6, $list2, $list5),
        @($list4, $list6, $list3, $list1), @($list4, $list6, $list3, $list2), @($list4, $list6, $list3, $list5),
        @($list4, $list6, $list5, $list1), @($list4, $list6, $list5, $list2), @($list4, $list6, $list5, $list3),
        @($list5, $list1, $list2, $list3), @($list5, $list1, $list2, $list4), @($list5, $list1, $list2, $list6),
        @($list5, $list1, $list3, $list2), @($list5, $list1, $list3, $list4), @($list5, $list1, $list3, $list6),
        @($list5, $list1, $list4, $list2), @($list5, $list1, $list4, $list3), @($list5, $list1, $list4, $list6),
        @($list5, $list1, $list6, $list2), @($list5, $list1, $list6, $list3), @($list5, $list1, $list6, $list4),
        @($list5, $list2, $list1, $list3), @($list5, $list2, $list1, $list4), @($list5, $list2, $list1, $list6),
        @($list5, $list2, $list3, $list1), @($list5, $list2, $list3, $list4), @($list5, $list2, $list3, $list6),
        @($list5, $list2, $list4, $list1), @($list5, $list2, $list4, $list3), @($list5, $list2, $list4, $list6),
        @($list5, $list2, $list6, $list1), @($list5, $list2, $list6, $list3), @($list5, $list2, $list6, $list4),
        @($list5, $list3, $list1, $list2), @($list5, $list3, $list1, $list4), @($list5, $list3, $list1, $list6),
        @($list5, $list3, $list2, $list1), @($list5, $list3, $list2, $list4), @($list5, $list3, $list2, $list6),
        @($list5, $list3, $list4, $list1), @($list5, $list3, $list4, $list2), @($list5, $list3, $list4, $list6),
        @($list5, $list3, $list6, $list1), @($list5, $list3, $list6, $list2), @($list5, $list3, $list6, $list4),
        @($list5, $list4, $list1, $list2), @($list5, $list4, $list1, $list3), @($list5, $list4, $list1, $list6),
        @($list5, $list4, $list2, $list1), @($list5, $list4, $list2, $list3), @($list5, $list4, $list2, $list6),
        @($list5, $list4, $list3, $list1), @($list5, $list4, $list3, $list2), @($list5, $list4, $list3, $list6),
        @($list5, $list4, $list6, $list1), @($list5, $list4, $list6, $list2), @($list5, $list4, $list6, $list3),
        @($list5, $list6, $list1, $list2), @($list5, $list6, $list1, $list3), @($list5, $list6, $list1, $list4),
        @($list5, $list6, $list2, $list1), @($list5, $list6, $list2, $list3), @($list5, $list6, $list2, $list4),
        @($list5, $list6, $list3, $list1), @($list5, $list6, $list3, $list2), @($list5, $list6, $list3, $list4),
        @($list5, $list6, $list4, $list1), @($list5, $list6, $list4, $list2), @($list5, $list6, $list4, $list3),
        @($list6, $list1, $list2, $list3), @($list6, $list1, $list2, $list4), @($list6, $list1, $list2, $list5),
        @($list6, $list1, $list3, $list2), @($list6, $list1, $list3, $list4), @($list6, $list1, $list3, $list5),
        @($list6, $list1, $list4, $list2), @($list6, $list1, $list4, $list3), @($list6, $list1, $list4, $list5),
        @($list6, $list1, $list5, $list2), @($list6, $list1, $list5, $list3), @($list6, $list1, $list5, $list4),
        @($list6, $list2, $list1, $list3), @($list6, $list2, $list1, $list4), @($list6, $list2, $list1, $list5),
        @($list6, $list2, $list3, $list1), @($list6, $list2, $list3, $list4), @($list6, $list2, $list3, $list5),
        @($list6, $list2, $list4, $list1), @($list6, $list2, $list4, $list3), @($list6, $list2, $list4, $list5),
        @($list6, $list2, $list5, $list1), @($list6, $list2, $list5, $list3), @($list6, $list2, $list5, $list4),
        @($list6, $list3, $list1, $list2), @($list6, $list3, $list1, $list4), @($list6, $list3, $list1, $list5),
        @($list6, $list3, $list2, $list1), @($list6, $list3, $list2, $list4), @($list6, $list3, $list2, $list5),
        @($list6, $list3, $list4, $list1), @($list6, $list3, $list4, $list2), @($list6, $list3, $list4, $list5),
        @($list6, $list3, $list5, $list1), @($list6, $list3, $list5, $list2), @($list6, $list3, $list5, $list4),
        @($list6, $list4, $list1, $list2), @($list6, $list4, $list1, $list3), @($list6, $list4, $list1, $list5),
        @($list6, $list4, $list2, $list1), @($list6, $list4, $list2, $list3), @($list6, $list4, $list2, $list5),
        @($list6, $list4, $list3, $list1), @($list6, $list4, $list3, $list2), @($list6, $list4, $list3, $list5),
        @($list6, $list4, $list5, $list1), @($list6, $list4, $list5, $list2), @($list6, $list4, $list5, $list3),
        @($list6, $list5, $list1, $list2), @($list6, $list5, $list1, $list3), @($list6, $list5, $list1, $list4),
        @($list6, $list5, $list2, $list1), @($list6, $list5, $list2, $list3), @($list6, $list5, $list2, $list4),
        @($list6, $list5, $list3, $list1), @($list6, $list5, $list3, $list2), @($list6, $list5, $list3, $list4),
        @($list6, $list5, $list4, $list1), @($list6, $list5, $list4, $list2), @($list6, $list5, $list4, $list3)
    )

    foreach ($list in $lists) {
        $expectedType = oracleType $list
        $expectedOutput = @(oracleOutput $list)
        $outputCount = $expectedOutput.Length

        $i = 0
        Group-ListItem -Zip $list | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_.Items -is $expectedType)
            Assert-True ($_.Items.Length -eq $expectedOutput[$i].Items.Length)

            $itemCount = $_.Items.Length
            for ($j = 0; $j -lt $itemCount; $j++) {
                if ($null -eq $_.Items[$j]) {
                    Assert-True ($_.Items[$j] -eq $expectedOutput[$i].Items[$j])
                } else {
                    Assert-True ($_.Items[$j].Equals($expectedOutput[$i].Items[$j]))
                }
            }

            $i++
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CartesianProduct with nulls' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $out3 = New-Object -TypeName 'System.Collections.ArrayList'
    $out4 = New-Object -TypeName 'System.Collections.ArrayList'

    $er1 = try {Group-ListItem -CartesianProduct $null -OutVariable out1 | Out-Null} catch {$_}
    $er2 = try {Group-ListItem -CartesianProduct @($null) -OutVariable out2 | Out-Null} catch {$_}
    $er3 = try {Group-ListItem -CartesianProduct (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList (,@(@(1,2,3), $null))) -OutVariable out3 | Out-Null} catch {$_}
    $er4 = try {Group-ListItem -CartesianProduct (New-Object -TypeName 'System.Collections.Generic.List[System.Object]' -ArgumentList (,@($null, @(4,5,6)))) -OutVariable out4 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 0)
    Assert-True ($out2.Count -eq 0)
    Assert-True ($out3.Count -eq 0)
    Assert-True ($out4.Count -eq 0)

    Assert-True ($er1 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er2 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er3 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er4 -is [System.Management.Automation.ErrorRecord])

    Assert-True ($er1.FullyQualifiedErrorId.Equals('ParameterArgumentValidationError,Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er2.FullyQualifiedErrorId.Equals('ParameterArgumentValidationError,Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er3.FullyQualifiedErrorId.Equals('ParameterArgumentValidationError,Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er4.FullyQualifiedErrorId.Equals('ParameterArgumentValidationError,Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase))

    Assert-True $er1.Exception.ParameterName.Equals('CartesianProduct', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True $er2.Exception.ParameterName.Equals('CartesianProduct', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True $er3.Exception.ParameterName.Equals('CartesianProduct', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True $er4.Exception.ParameterName.Equals('CartesianProduct', [System.StringComparison]::OrdinalIgnoreCase)
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CartesianProduct with lists of length 0' -Verbose:$headerVerbosity

    Group-ListItem -CartesianProduct @(,@()) | Assert-PipelineEmpty

    Group-ListItem -CartesianProduct @(@(), (New-Object -TypeName 'System.Collections.Generic.List[System.String]')) | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct @(@(), @($null)) | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct @(@($null), @()) | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct @(@(1,2), (New-Object -TypeName 'System.Collections.ArrayList')) | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct @(@(), (New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@(1,2)))) | Assert-PipelineEmpty

    Group-ListItem -CartesianProduct @(@(), @(), @()) | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct @(@(), @($null), @(1,2)) | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct @(@(1,2), @(), @($null)) | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct @(@($null), @(1,2), @()) | Assert-PipelineEmpty

    Group-ListItem -CartesianProduct @(@(), @(), @(), @()) | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct @(@(), @($null), @(1,2), @('a','b','c')) | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct @(@($null), @(), @(1,2), @('a','b','c')) | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct @(@($null), @(1,2), @(), @('a','b','c')) | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct @(@($null), @(1,2), @('a','b','c'), @()) | Assert-PipelineEmpty
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CartesianProduct with no lists' -Verbose:$headerVerbosity

    Group-ListItem -CartesianProduct @() | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct (New-Object -TypeName 'System.Collections.ArrayList') | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct (New-Object -TypeName 'System.Collections.Generic.List[System.Byte[]]') | Assert-PipelineEmpty
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CartesianProduct with 1 list' -Verbose:$headerVerbosity

    $list1 = [System.String[]]@('a')
    $list2 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@($null, @()))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(0.00, 2.72, 3.14))
    $list4 = [System.Double[]]@(100, 200, 300, 400)
    $list5 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@(@($null), @(), 'hi', $null, 5))
    $list6 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('hello', 'world', 'how', 'are', 'you', 'today'))

    function oracleType($list)
    {
        if ($list[0].Equals($list1) -or $list[0].Equals($list6)) {
            return [System.String[]]
        } elseif ($list[0].Equals($list3) -or $list[0].Equals($list4)) {
            return [System.Double[]]
        } else {
            return [System.Object[]]
        }
    }

    function oracleOutput($list)
    {
        foreach ($i in $list[0]) {
            @{'Items' = @(,$i)}
        }
    }
    
    foreach ($list in @(@(,$list1), @(,$list2), @(,$list3), @(,$list4), @(,$list5), @(,$list6))) {
        $expectedType = oracleType $list
        $expectedOutput = @(oracleOutput $list)
        $outputCount = $expectedOutput.Length

        $i = 0
        Group-ListItem -CartesianProduct $list | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_.Items -is $expectedType)
            Assert-True ($_.Items.Length -eq $expectedOutput[$i].Items.Length)

            $itemCount = $_.Items.Length
            for ($j = 0; $j -lt $itemCount; $j++) {
                if ($null -eq $_.Items[$j]) {
                    Assert-True ($_.Items[$j] -eq $expectedOutput[$i].Items[$j])
                } else {
                    Assert-True ($_.Items[$j].Equals($expectedOutput[$i].Items[$j]))
                }
            }

            $i++
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CartesianProduct with 2 lists' -Verbose:$headerVerbosity

    $list1 = [System.String[]]@('a')
    $list2 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@($null, @()))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(0.00, 2.72, 3.14))
    $list4 = [System.Double[]]@(100, 200, 300, 400)
    $list5 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@(@($null), @(), 'hi', $null, 5))
    $list6 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('hello', 'world', 'how', 'are', 'you', 'today'))

    function oracleType($list)
    {
        if ($list[0].Equals($list1) -and $list[1].Equals($list6)) {
            return [System.String[]]
        } elseif ($list[0].Equals($list6) -and $list[1].Equals($list1)) {
            return [System.String[]]
        } elseif ($list[0].Equals($list1) -and $list[1].Equals($list1)) {
            return [System.String[]]
        } elseif ($list[0].Equals($list6) -and $list[1].Equals($list6)) {
            return [System.String[]]
        } elseif ($list[0].Equals($list3) -and $list[1].Equals($list4)) {
            return [System.Double[]]
        } elseif ($list[0].Equals($list4) -and $list[1].Equals($list3)) {
            return [System.Double[]]
        } elseif ($list[0].Equals($list3) -and $list[1].Equals($list3)) {
            return [System.Double[]]
        } elseif ($list[0].Equals($list4) -and $list[1].Equals($list4)) {
            return [System.Double[]]
        } else {
            return [System.Object[]]
        }
    }

    function oracleOutput($list)
    {
        foreach ($i in $list[0]) {
            foreach ($j in $list[1]) {
                @{'Items' = @($i, $j)}
            }
        }
    }
    
    $lists = @(
        @($list1, $list1), @($list1, $list2), @($list1, $list3), @($list1, $list4), @($list1, $list5), @($list1, $list6),
        @($list2, $list1), @($list2, $list2), @($list2, $list3), @($list2, $list4), @($list2, $list5), @($list2, $list6),
        @($list3, $list1), @($list3, $list2), @($list3, $list3), @($list3, $list4), @($list3, $list5), @($list3, $list6),
        @($list4, $list1), @($list4, $list2), @($list4, $list3), @($list4, $list4), @($list4, $list5), @($list4, $list6),
        @($list5, $list1), @($list5, $list2), @($list5, $list3), @($list5, $list4), @($list5, $list5), @($list5, $list6),
        @($list6, $list1), @($list6, $list2), @($list6, $list3), @($list6, $list4), @($list6, $list5), @($list6, $list6)
    )

    foreach ($list in $lists) {
        $expectedType = oracleType $list
        $expectedOutput = @(oracleOutput $list)
        $outputCount = $expectedOutput.Length

        $i = 0
        Group-ListItem -CartesianProduct $list | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_.Items -is $expectedType)
            Assert-True ($_.Items.Length -eq $expectedOutput[$i].Items.Length)

            $itemCount = $_.Items.Length
            for ($j = 0; $j -lt $itemCount; $j++) {
                if ($null -eq $_.Items[$j]) {
                    Assert-True ($_.Items[$j] -eq $expectedOutput[$i].Items[$j])
                } else {
                    Assert-True ($_.Items[$j].Equals($expectedOutput[$i].Items[$j]))
                }
            }

            $i++
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CartesianProduct with 3 lists' -Verbose:$headerVerbosity

    $list1 = [System.String[]]@('a')
    $list2 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@($null, @()))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(0.00, 2.72, 3.14))
    $list4 = [System.String[]]@('100', '200', '300', '400')
    $list5 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@(@($null), @(), 'hi', $null, 5))
    $list6 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('hello', 'world', 'how', 'are', 'you', 'today'))

    function oracleType($list)
    {
        if ($list[0].Equals($list3) -and $list[1].Equals($list3) -and $list[2].Equals($list3)) {
            return [System.Double[]]
        } elseif ($list[0].Equals($list2) -or $list[0].Equals($list3) -or $list[0].Equals($list5)) {
            return [System.Object[]]
        } elseif ($list[1].Equals($list2) -or $list[1].Equals($list3) -or $list[1].Equals($list5)) {
            return [System.Object[]]
        } elseif ($list[2].Equals($list2) -or $list[2].Equals($list3) -or $list[2].Equals($list5)) {
            return [System.Object[]]
        } else {
            return [System.String[]]
        }
    }

    function oracleOutput($list)
    {
        foreach ($i in $list[0]) {
            foreach ($j in $list[1]) {
                foreach ($k in $list[2]) {
                    @{'Items' = @($i, $j, $k)}
                }
            }
        }
    }
    
    $lists = @(
        @($list1, $list2, $list3), @($list1, $list2, $list4), @($list1, $list2, $list5), @($list1, $list2, $list6),
        @($list1, $list3, $list2), @($list1, $list3, $list4), @($list1, $list3, $list5), @($list1, $list3, $list6),
        @($list1, $list4, $list2), @($list1, $list4, $list3), @($list1, $list4, $list5), @($list1, $list4, $list6),
        @($list1, $list5, $list2), @($list1, $list5, $list3), @($list1, $list5, $list4), @($list1, $list5, $list6),
        @($list1, $list6, $list2), @($list1, $list6, $list3), @($list1, $list6, $list4), @($list1, $list6, $list5),
        @($list2, $list1, $list3), @($list2, $list1, $list4), @($list2, $list1, $list5), @($list2, $list1, $list6),
        @($list2, $list3, $list1), @($list2, $list3, $list4), @($list2, $list3, $list5), @($list2, $list3, $list6),
        @($list2, $list4, $list1), @($list2, $list4, $list3), @($list2, $list4, $list5), @($list2, $list4, $list6),
        @($list2, $list5, $list1), @($list2, $list5, $list3), @($list2, $list5, $list4), @($list2, $list5, $list6),
        @($list2, $list6, $list1), @($list2, $list6, $list3), @($list2, $list6, $list4), @($list2, $list6, $list5),
        @($list3, $list1, $list2), @($list3, $list1, $list4), @($list3, $list1, $list5), @($list3, $list1, $list6),
        @($list3, $list2, $list1), @($list3, $list2, $list4), @($list3, $list2, $list5), @($list3, $list2, $list6),
        @($list3, $list4, $list1), @($list3, $list4, $list2), @($list3, $list4, $list5), @($list3, $list4, $list6),
        @($list3, $list5, $list1), @($list3, $list5, $list2), @($list3, $list5, $list4), @($list3, $list5, $list6),
        @($list3, $list6, $list1), @($list3, $list6, $list2), @($list3, $list6, $list4), @($list3, $list6, $list5),
        @($list4, $list1, $list2), @($list4, $list1, $list3), @($list4, $list1, $list5), @($list4, $list1, $list6),
        @($list4, $list2, $list1), @($list4, $list2, $list3), @($list4, $list2, $list5), @($list4, $list2, $list6),
        @($list4, $list3, $list1), @($list4, $list3, $list2), @($list4, $list3, $list5), @($list4, $list3, $list6),
        @($list4, $list5, $list1), @($list4, $list5, $list2), @($list4, $list5, $list3), @($list4, $list5, $list6),
        @($list4, $list6, $list1), @($list4, $list6, $list2), @($list4, $list6, $list3), @($list4, $list6, $list5),
        @($list5, $list1, $list2), @($list5, $list1, $list3), @($list5, $list1, $list4), @($list5, $list1, $list6),
        @($list5, $list2, $list1), @($list5, $list2, $list3), @($list5, $list2, $list4), @($list5, $list2, $list6),
        @($list5, $list3, $list1), @($list5, $list3, $list2), @($list5, $list3, $list4), @($list5, $list3, $list6),
        @($list5, $list4, $list1), @($list5, $list4, $list2), @($list5, $list4, $list3), @($list5, $list4, $list6),
        @($list5, $list6, $list1), @($list5, $list6, $list2), @($list5, $list6, $list3), @($list5, $list6, $list4),
        @($list6, $list1, $list2), @($list6, $list1, $list3), @($list6, $list1, $list4), @($list6, $list1, $list5),
        @($list6, $list2, $list1), @($list6, $list2, $list3), @($list6, $list2, $list4), @($list6, $list2, $list5),
        @($list6, $list3, $list1), @($list6, $list3, $list2), @($list6, $list3, $list4), @($list6, $list3, $list5),
        @($list6, $list4, $list1), @($list6, $list4, $list2), @($list6, $list4, $list3), @($list6, $list4, $list5),
        @($list6, $list5, $list1), @($list6, $list5, $list2), @($list6, $list5, $list3), @($list6, $list5, $list4)
    )

    foreach ($list in $lists) {
        $expectedType = oracleType $list
        $expectedOutput = @(oracleOutput $list)
        $outputCount = $expectedOutput.Length

        $i = 0
        Group-ListItem -CartesianProduct $list | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_.Items -is $expectedType)
            Assert-True ($_.Items.Length -eq $expectedOutput[$i].Items.Length)

            $itemCount = $_.Items.Length
            for ($j = 0; $j -lt $itemCount; $j++) {
                if ($null -eq $_.Items[$j]) {
                    Assert-True ($_.Items[$j] -eq $expectedOutput[$i].Items[$j])
                } else {
                    Assert-True ($_.Items[$j].Equals($expectedOutput[$i].Items[$j]))
                }
            }

            $i++
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CartesianProduct with 4 lists' -Verbose:$headerVerbosity

    $list1 = [System.String[]]@('a')
    $list2 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@($null, @()))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('0.00', '2.72', '3.14'))
    $list4 = [System.String[]]@('100', '200', '300', '400')
    $list5 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@(@($null), @(), 'hi', $null, 5))
    $list6 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('hello', 'world', 'how', 'are', 'you', 'today'))

    function oracleType($list)
    {
        if ($list[0].Equals($list2) -or $list[0].Equals($list5)) {
            return [System.Object[]]
        } elseif ($list[1].Equals($list2) -or $list[1].Equals($list5)) {
            return [System.Object[]]
        } elseif ($list[2].Equals($list2) -or $list[2].Equals($list5)) {
            return [System.Object[]]
        } elseif ($list[3].Equals($list2) -or $list[3].Equals($list5)) {
            return [System.Object[]]
        } else {
            return [System.String[]]
        }
    }

    function oracleOutput($list)
    {
        foreach ($i in $list[0]) {
            foreach ($j in $list[1]) {
                foreach ($k in $list[2]) {
                    foreach ($l in $list[3]) {
                        @{'Items' = @($i, $j, $k, $l)}
                    }
                }
            }
        }
    }
    
    $lists = @(
        @($list1, $list2, $list3, $list4), @($list1, $list2, $list3, $list5), @($list1, $list2, $list3, $list6),
        @($list1, $list2, $list4, $list3), @($list1, $list2, $list4, $list5), @($list1, $list2, $list4, $list6),
        @($list1, $list2, $list5, $list3), @($list1, $list2, $list5, $list4), @($list1, $list2, $list5, $list6),
        @($list1, $list2, $list6, $list3), @($list1, $list2, $list6, $list4), @($list1, $list2, $list6, $list5),
        @($list1, $list3, $list2, $list4), @($list1, $list3, $list2, $list5), @($list1, $list3, $list2, $list6),
        @($list1, $list3, $list4, $list2), @($list1, $list3, $list4, $list5), @($list1, $list3, $list4, $list6),
        @($list1, $list3, $list5, $list2), @($list1, $list3, $list5, $list4), @($list1, $list3, $list5, $list6),
        @($list1, $list3, $list6, $list2), @($list1, $list3, $list6, $list4), @($list1, $list3, $list6, $list5),
        @($list1, $list4, $list2, $list3), @($list1, $list4, $list2, $list5), @($list1, $list4, $list2, $list6),
        @($list1, $list4, $list3, $list2), @($list1, $list4, $list3, $list5), @($list1, $list4, $list3, $list6),
        @($list1, $list4, $list5, $list2), @($list1, $list4, $list5, $list3), @($list1, $list4, $list5, $list6),
        @($list1, $list4, $list6, $list2), @($list1, $list4, $list6, $list3), @($list1, $list4, $list6, $list5),
        @($list1, $list5, $list2, $list3), @($list1, $list5, $list2, $list4), @($list1, $list5, $list2, $list6),
        @($list1, $list5, $list3, $list2), @($list1, $list5, $list3, $list4), @($list1, $list5, $list3, $list6),
        @($list1, $list5, $list4, $list2), @($list1, $list5, $list4, $list3), @($list1, $list5, $list4, $list6),
        @($list1, $list5, $list6, $list2), @($list1, $list5, $list6, $list3), @($list1, $list5, $list6, $list4),
        @($list1, $list6, $list2, $list3), @($list1, $list6, $list2, $list4), @($list1, $list6, $list2, $list5),
        @($list1, $list6, $list3, $list2), @($list1, $list6, $list3, $list4), @($list1, $list6, $list3, $list5),
        @($list1, $list6, $list4, $list2), @($list1, $list6, $list4, $list3), @($list1, $list6, $list4, $list5),
        @($list1, $list6, $list5, $list2), @($list1, $list6, $list5, $list3), @($list1, $list6, $list5, $list4),
        @($list2, $list1, $list3, $list4), @($list2, $list1, $list3, $list5), @($list2, $list1, $list3, $list6),
        @($list2, $list1, $list4, $list3), @($list2, $list1, $list4, $list5), @($list2, $list1, $list4, $list6),
        @($list2, $list1, $list5, $list3), @($list2, $list1, $list5, $list4), @($list2, $list1, $list5, $list6),
        @($list2, $list1, $list6, $list3), @($list2, $list1, $list6, $list4), @($list2, $list1, $list6, $list5),
        @($list2, $list3, $list1, $list4), @($list2, $list3, $list1, $list5), @($list2, $list3, $list1, $list6),
        @($list2, $list3, $list4, $list1), @($list2, $list3, $list4, $list5), @($list2, $list3, $list4, $list6),
        @($list2, $list3, $list5, $list1), @($list2, $list3, $list5, $list4), @($list2, $list3, $list5, $list6),
        @($list2, $list3, $list6, $list1), @($list2, $list3, $list6, $list4), @($list2, $list3, $list6, $list5),
        @($list2, $list4, $list1, $list3), @($list2, $list4, $list1, $list5), @($list2, $list4, $list1, $list6),
        @($list2, $list4, $list3, $list1), @($list2, $list4, $list3, $list5), @($list2, $list4, $list3, $list6),
        @($list2, $list4, $list5, $list1), @($list2, $list4, $list5, $list3), @($list2, $list4, $list5, $list6),
        @($list2, $list4, $list6, $list1), @($list2, $list4, $list6, $list3), @($list2, $list4, $list6, $list5),
        @($list2, $list5, $list1, $list3), @($list2, $list5, $list1, $list4), @($list2, $list5, $list1, $list6),
        @($list2, $list5, $list3, $list1), @($list2, $list5, $list3, $list4), @($list2, $list5, $list3, $list6),
        @($list2, $list5, $list4, $list1), @($list2, $list5, $list4, $list3), @($list2, $list5, $list4, $list6),
        @($list2, $list5, $list6, $list1), @($list2, $list5, $list6, $list3), @($list2, $list5, $list6, $list4),
        @($list2, $list6, $list1, $list3), @($list2, $list6, $list1, $list4), @($list2, $list6, $list1, $list5),
        @($list2, $list6, $list3, $list1), @($list2, $list6, $list3, $list4), @($list2, $list6, $list3, $list5),
        @($list2, $list6, $list4, $list1), @($list2, $list6, $list4, $list3), @($list2, $list6, $list4, $list5),
        @($list2, $list6, $list5, $list1), @($list2, $list6, $list5, $list3), @($list2, $list6, $list5, $list4),
        @($list3, $list1, $list2, $list4), @($list3, $list1, $list2, $list5), @($list3, $list1, $list2, $list6),
        @($list3, $list1, $list4, $list2), @($list3, $list1, $list4, $list5), @($list3, $list1, $list4, $list6),
        @($list3, $list1, $list5, $list2), @($list3, $list1, $list5, $list4), @($list3, $list1, $list5, $list6),
        @($list3, $list1, $list6, $list2), @($list3, $list1, $list6, $list4), @($list3, $list1, $list6, $list5),
        @($list3, $list2, $list1, $list4), @($list3, $list2, $list1, $list5), @($list3, $list2, $list1, $list6),
        @($list3, $list2, $list4, $list1), @($list3, $list2, $list4, $list5), @($list3, $list2, $list4, $list6),
        @($list3, $list2, $list5, $list1), @($list3, $list2, $list5, $list4), @($list3, $list2, $list5, $list6),
        @($list3, $list2, $list6, $list1), @($list3, $list2, $list6, $list4), @($list3, $list2, $list6, $list5),
        @($list3, $list4, $list1, $list2), @($list3, $list4, $list1, $list5), @($list3, $list4, $list1, $list6),
        @($list3, $list4, $list2, $list1), @($list3, $list4, $list2, $list5), @($list3, $list4, $list2, $list6),
        @($list3, $list4, $list5, $list1), @($list3, $list4, $list5, $list2), @($list3, $list4, $list5, $list6),
        @($list3, $list4, $list6, $list1), @($list3, $list4, $list6, $list2), @($list3, $list4, $list6, $list5),
        @($list3, $list5, $list1, $list2), @($list3, $list5, $list1, $list4), @($list3, $list5, $list1, $list6),
        @($list3, $list5, $list2, $list1), @($list3, $list5, $list2, $list4), @($list3, $list5, $list2, $list6),
        @($list3, $list5, $list4, $list1), @($list3, $list5, $list4, $list2), @($list3, $list5, $list4, $list6),
        @($list3, $list5, $list6, $list1), @($list3, $list5, $list6, $list2), @($list3, $list5, $list6, $list4),
        @($list3, $list6, $list1, $list2), @($list3, $list6, $list1, $list4), @($list3, $list6, $list1, $list5),
        @($list3, $list6, $list2, $list1), @($list3, $list6, $list2, $list4), @($list3, $list6, $list2, $list5),
        @($list3, $list6, $list4, $list1), @($list3, $list6, $list4, $list2), @($list3, $list6, $list4, $list5),
        @($list3, $list6, $list5, $list1), @($list3, $list6, $list5, $list2), @($list3, $list6, $list5, $list4),
        @($list4, $list1, $list2, $list3), @($list4, $list1, $list2, $list5), @($list4, $list1, $list2, $list6),
        @($list4, $list1, $list3, $list2), @($list4, $list1, $list3, $list5), @($list4, $list1, $list3, $list6),
        @($list4, $list1, $list5, $list2), @($list4, $list1, $list5, $list3), @($list4, $list1, $list5, $list6),
        @($list4, $list1, $list6, $list2), @($list4, $list1, $list6, $list3), @($list4, $list1, $list6, $list5),
        @($list4, $list2, $list1, $list3), @($list4, $list2, $list1, $list5), @($list4, $list2, $list1, $list6),
        @($list4, $list2, $list3, $list1), @($list4, $list2, $list3, $list5), @($list4, $list2, $list3, $list6),
        @($list4, $list2, $list5, $list1), @($list4, $list2, $list5, $list3), @($list4, $list2, $list5, $list6),
        @($list4, $list2, $list6, $list1), @($list4, $list2, $list6, $list3), @($list4, $list2, $list6, $list5),
        @($list4, $list3, $list1, $list2), @($list4, $list3, $list1, $list5), @($list4, $list3, $list1, $list6),
        @($list4, $list3, $list2, $list1), @($list4, $list3, $list2, $list5), @($list4, $list3, $list2, $list6),
        @($list4, $list3, $list5, $list1), @($list4, $list3, $list5, $list2), @($list4, $list3, $list5, $list6),
        @($list4, $list3, $list6, $list1), @($list4, $list3, $list6, $list2), @($list4, $list3, $list6, $list5),
        @($list4, $list5, $list1, $list2), @($list4, $list5, $list1, $list3), @($list4, $list5, $list1, $list6),
        @($list4, $list5, $list2, $list1), @($list4, $list5, $list2, $list3), @($list4, $list5, $list2, $list6),
        @($list4, $list5, $list3, $list1), @($list4, $list5, $list3, $list2), @($list4, $list5, $list3, $list6),
        @($list4, $list5, $list6, $list1), @($list4, $list5, $list6, $list2), @($list4, $list5, $list6, $list3),
        @($list4, $list6, $list1, $list2), @($list4, $list6, $list1, $list3), @($list4, $list6, $list1, $list5),
        @($list4, $list6, $list2, $list1), @($list4, $list6, $list2, $list3), @($list4, $list6, $list2, $list5),
        @($list4, $list6, $list3, $list1), @($list4, $list6, $list3, $list2), @($list4, $list6, $list3, $list5),
        @($list4, $list6, $list5, $list1), @($list4, $list6, $list5, $list2), @($list4, $list6, $list5, $list3),
        @($list5, $list1, $list2, $list3), @($list5, $list1, $list2, $list4), @($list5, $list1, $list2, $list6),
        @($list5, $list1, $list3, $list2), @($list5, $list1, $list3, $list4), @($list5, $list1, $list3, $list6),
        @($list5, $list1, $list4, $list2), @($list5, $list1, $list4, $list3), @($list5, $list1, $list4, $list6),
        @($list5, $list1, $list6, $list2), @($list5, $list1, $list6, $list3), @($list5, $list1, $list6, $list4),
        @($list5, $list2, $list1, $list3), @($list5, $list2, $list1, $list4), @($list5, $list2, $list1, $list6),
        @($list5, $list2, $list3, $list1), @($list5, $list2, $list3, $list4), @($list5, $list2, $list3, $list6),
        @($list5, $list2, $list4, $list1), @($list5, $list2, $list4, $list3), @($list5, $list2, $list4, $list6),
        @($list5, $list2, $list6, $list1), @($list5, $list2, $list6, $list3), @($list5, $list2, $list6, $list4),
        @($list5, $list3, $list1, $list2), @($list5, $list3, $list1, $list4), @($list5, $list3, $list1, $list6),
        @($list5, $list3, $list2, $list1), @($list5, $list3, $list2, $list4), @($list5, $list3, $list2, $list6),
        @($list5, $list3, $list4, $list1), @($list5, $list3, $list4, $list2), @($list5, $list3, $list4, $list6),
        @($list5, $list3, $list6, $list1), @($list5, $list3, $list6, $list2), @($list5, $list3, $list6, $list4),
        @($list5, $list4, $list1, $list2), @($list5, $list4, $list1, $list3), @($list5, $list4, $list1, $list6),
        @($list5, $list4, $list2, $list1), @($list5, $list4, $list2, $list3), @($list5, $list4, $list2, $list6),
        @($list5, $list4, $list3, $list1), @($list5, $list4, $list3, $list2), @($list5, $list4, $list3, $list6),
        @($list5, $list4, $list6, $list1), @($list5, $list4, $list6, $list2), @($list5, $list4, $list6, $list3),
        @($list5, $list6, $list1, $list2), @($list5, $list6, $list1, $list3), @($list5, $list6, $list1, $list4),
        @($list5, $list6, $list2, $list1), @($list5, $list6, $list2, $list3), @($list5, $list6, $list2, $list4),
        @($list5, $list6, $list3, $list1), @($list5, $list6, $list3, $list2), @($list5, $list6, $list3, $list4),
        @($list5, $list6, $list4, $list1), @($list5, $list6, $list4, $list2), @($list5, $list6, $list4, $list3),
        @($list6, $list1, $list2, $list3), @($list6, $list1, $list2, $list4), @($list6, $list1, $list2, $list5),
        @($list6, $list1, $list3, $list2), @($list6, $list1, $list3, $list4), @($list6, $list1, $list3, $list5),
        @($list6, $list1, $list4, $list2), @($list6, $list1, $list4, $list3), @($list6, $list1, $list4, $list5),
        @($list6, $list1, $list5, $list2), @($list6, $list1, $list5, $list3), @($list6, $list1, $list5, $list4),
        @($list6, $list2, $list1, $list3), @($list6, $list2, $list1, $list4), @($list6, $list2, $list1, $list5),
        @($list6, $list2, $list3, $list1), @($list6, $list2, $list3, $list4), @($list6, $list2, $list3, $list5),
        @($list6, $list2, $list4, $list1), @($list6, $list2, $list4, $list3), @($list6, $list2, $list4, $list5),
        @($list6, $list2, $list5, $list1), @($list6, $list2, $list5, $list3), @($list6, $list2, $list5, $list4),
        @($list6, $list3, $list1, $list2), @($list6, $list3, $list1, $list4), @($list6, $list3, $list1, $list5),
        @($list6, $list3, $list2, $list1), @($list6, $list3, $list2, $list4), @($list6, $list3, $list2, $list5),
        @($list6, $list3, $list4, $list1), @($list6, $list3, $list4, $list2), @($list6, $list3, $list4, $list5),
        @($list6, $list3, $list5, $list1), @($list6, $list3, $list5, $list2), @($list6, $list3, $list5, $list4),
        @($list6, $list4, $list1, $list2), @($list6, $list4, $list1, $list3), @($list6, $list4, $list1, $list5),
        @($list6, $list4, $list2, $list1), @($list6, $list4, $list2, $list3), @($list6, $list4, $list2, $list5),
        @($list6, $list4, $list3, $list1), @($list6, $list4, $list3, $list2), @($list6, $list4, $list3, $list5),
        @($list6, $list4, $list5, $list1), @($list6, $list4, $list5, $list2), @($list6, $list4, $list5, $list3),
        @($list6, $list5, $list1, $list2), @($list6, $list5, $list1, $list3), @($list6, $list5, $list1, $list4),
        @($list6, $list5, $list2, $list1), @($list6, $list5, $list2, $list3), @($list6, $list5, $list2, $list4),
        @($list6, $list5, $list3, $list1), @($list6, $list5, $list3, $list2), @($list6, $list5, $list3, $list4),
        @($list6, $list5, $list4, $list1), @($list6, $list5, $list4, $list2), @($list6, $list5, $list4, $list3)
    )

    foreach ($list in $lists) {
        $expectedType = oracleType $list
        $expectedOutput = @(oracleOutput $list)
        $outputCount = $expectedOutput.Length

        $i = 0
        Group-ListItem -CartesianProduct $list | Assert-PipelineCount $outputCount | ForEach-Object {
            Assert-True ($_.Items -is $expectedType)
            Assert-True ($_.Items.Length -eq $expectedOutput[$i].Items.Length)

            $itemCount = $_.Items.Length
            for ($j = 0; $j -lt $itemCount; $j++) {
                if ($null -eq $_.Items[$j]) {
                    Assert-True ($_.Items[$j] -eq $expectedOutput[$i].Items[$j])
                } else {
                    Assert-True ($_.Items[$j].Equals($expectedOutput[$i].Items[$j]))
                }
            }

            $i++
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CoveringArray with nulls' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CoveringArray with lists of length 0' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CoveringArray with no lists' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CoveringArray with 1 list' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CoveringArray with 2 lists' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CoveringArray with 3 lists' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CoveringArray with 4 lists' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

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
    Write-Verbose -Message 'Test Group-ListItem with get-help -full' -Verbose:$headerVerbosity

    $err = try {$fullHelp = Get-Help Group-ListItem -Full} catch {$_}

    Assert-Null $err
    Assert-True ($fullHelp.Name -is [System.String])
    Assert-True ($fullHelp.Name.Equals('Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($fullHelp.description -is [System.Collections.ICollection])
    Assert-True ($fullHelp.description.Count -gt 0)
    Assert-NotNull $fullHelp.examples
    Assert-True (0 -lt @($fullHelp.examples.example).Count)
    Assert-True ('' -ne @($fullHelp.examples.example)[0].code)
}

& {
    Write-Verbose -Message 'Test Group-ListItem ParameterSet: Pair' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Group-ListItem).ParameterSets |
        Where-Object {'Pair'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $pairParam = $paramSet.Parameters |
        Where-Object {'Pair'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($pairParam.IsMandatory)
    Assert-True ($pairParam.ParameterType -eq [System.Collections.IList])
    Assert-False ($pairParam.ValueFromPipeline)
    Assert-False ($pairParam.ValueFromPipelineByPropertyName)
    Assert-False ($pairParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $pairParam.Position)
    Assert-True (0 -eq $pairParam.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Group-ListItem ParameterSet: Window' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Group-ListItem).ParameterSets |
        Where-Object {'Window'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $windowParam = $paramSet.Parameters |
        Where-Object {'Window'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $sizeParam = $paramSet.Parameters |
        Where-Object {'Size'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($windowParam.IsMandatory)
    Assert-True ($windowParam.ParameterType -eq [System.Collections.IList])
    Assert-False ($windowParam.ValueFromPipeline)
    Assert-False ($windowParam.ValueFromPipelineByPropertyName)
    Assert-False ($windowParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $windowParam.Position)
    Assert-True (0 -eq $windowParam.Aliases.Count)

    Assert-False ($sizeParam.IsMandatory)
    Assert-True ($sizeParam.ParameterType -eq [System.Int32])
    Assert-False ($sizeParam.ValueFromPipeline)
    Assert-False ($sizeParam.ValueFromPipelineByPropertyName)
    Assert-False ($sizeParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $sizeParam.Position)
    Assert-True (0 -eq $sizeParam.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Group-ListItem ParameterSet: Combine' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Group-ListItem).ParameterSets |
        Where-Object {'Combine'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $combineParam = $paramSet.Parameters |
        Where-Object {'Combine'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $sizeParam = $paramSet.Parameters |
        Where-Object {'Size'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($combineParam.IsMandatory)
    Assert-True ($combineParam.ParameterType -eq [System.Collections.IList])
    Assert-False ($combineParam.ValueFromPipeline)
    Assert-False ($combineParam.ValueFromPipelineByPropertyName)
    Assert-False ($combineParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $combineParam.Position)
    Assert-True (0 -eq $combineParam.Aliases.Count)

    Assert-False ($sizeParam.IsMandatory)
    Assert-True ($sizeParam.ParameterType -eq [System.Int32])
    Assert-False ($sizeParam.ValueFromPipeline)
    Assert-False ($sizeParam.ValueFromPipelineByPropertyName)
    Assert-False ($sizeParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $sizeParam.Position)
    Assert-True (0 -eq $sizeParam.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Group-ListItem ParameterSet: Permute' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Group-ListItem).ParameterSets |
        Where-Object {'Permute'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $permuteParam = $paramSet.Parameters |
        Where-Object {'Permute'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $sizeParam = $paramSet.Parameters |
        Where-Object {'Size'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($permuteParam.IsMandatory)
    Assert-True ($permuteParam.ParameterType -eq [System.Collections.IList])
    Assert-False ($permuteParam.ValueFromPipeline)
    Assert-False ($permuteParam.ValueFromPipelineByPropertyName)
    Assert-False ($permuteParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $permuteParam.Position)
    Assert-True (0 -eq $permuteParam.Aliases.Count)

    Assert-False ($sizeParam.IsMandatory)
    Assert-True ($sizeParam.ParameterType -eq [System.Int32])
    Assert-False ($sizeParam.ValueFromPipeline)
    Assert-False ($sizeParam.ValueFromPipelineByPropertyName)
    Assert-False ($sizeParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $sizeParam.Position)
    Assert-True (0 -eq $sizeParam.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Group-ListItem ParameterSet: Zip' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Group-ListItem).ParameterSets |
        Where-Object {'Zip'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $zipParam = $paramSet.Parameters |
        Where-Object {'Zip'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($zipParam.IsMandatory)
    Assert-True ($zipParam.ParameterType -eq [System.Collections.IList[]])
    Assert-False ($zipParam.ValueFromPipeline)
    Assert-False ($zipParam.ValueFromPipelineByPropertyName)
    Assert-False ($zipParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $zipParam.Position)
    Assert-True (0 -eq $zipParam.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Group-ListItem ParameterSet: CartesianProduct' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Group-ListItem).ParameterSets |
        Where-Object {'CartesianProduct'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $cartesianProductParam = $paramSet.Parameters |
        Where-Object {'CartesianProduct'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($cartesianProductParam.IsMandatory)
    Assert-True ($cartesianProductParam.ParameterType -eq [System.Collections.IList[]])
    Assert-False ($cartesianProductParam.ValueFromPipeline)
    Assert-False ($cartesianProductParam.ValueFromPipelineByPropertyName)
    Assert-False ($cartesianProductParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $cartesianProductParam.Position)
    Assert-True (0 -eq $cartesianProductParam.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Group-ListItem ParameterSet: CoveringArray' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Group-ListItem).ParameterSets |
        Where-Object {'CoveringArray'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $coveringArrayParam = $paramSet.Parameters |
        Where-Object {'CoveringArray'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $strengthParam = $paramSet.Parameters |
        Where-Object {'Strength'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($coveringArrayParam.IsMandatory)
    Assert-True ($coveringArrayParam.ParameterType -eq [System.Collections.IList[]])
    Assert-False ($coveringArrayParam.ValueFromPipeline)
    Assert-False ($coveringArrayParam.ValueFromPipelineByPropertyName)
    Assert-False ($coveringArrayParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $coveringArrayParam.Position)
    Assert-True (0 -eq $coveringArrayParam.Aliases.Count)

    Assert-False ($strengthParam.IsMandatory)
    Assert-True ($strengthParam.ParameterType -eq [System.Int32])
    Assert-False ($strengthParam.ValueFromPipeline)
    Assert-False ($strengthParam.ValueFromPipelineByPropertyName)
    Assert-False ($strengthParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $strengthParam.Position)
    Assert-True (0 -eq $strengthParam.Aliases.Count)
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
    $list2 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello', 'world'))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(3.14, 2.72))
    $lists = @(
        $list1,
        $list2,
        $list3
    )

    function oracleType($list)
    {
        if ($list.Equals($list3)) {
            [System.Double[]]
        } else {
            [System.Object[]]
        }
    }

    function areEqual($a, $b)
    {
        if ($null -eq $a) {
            $null -eq $b
        } else {
            $a.Equals($b)
        }
    }

    foreach ($list in $lists) {
        $expectedType = oracleType $list
        $actualOutput = New-Object -TypeName 'System.Collections.ArrayList'

        Group-ListItem -Pair $list -OutVariable actualOutput | Out-Null

        Assert-True ($actualOutput.Count -eq 1)
        @(0) |
            Assert-PipelineAll {param($row) $actualOutput[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $actualOutput[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $actualOutput[$row].Items.Length -eq 2} |
            Assert-PipelineAll {param($row) areEqual $actualOutput[$row].Items[0] $list[$row + 0]} |
            Assert-PipelineAll {param($row) areEqual $actualOutput[$row].Items[1] $list[$row + 1]} |
            Out-Null
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Pair with lists of length 3' -Verbose:$headerVerbosity

    $list1 = @(3.14, 2.72, 0.00)
    $list2 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello', $null, 'world'))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.Object]' -ArgumentList @(,[System.Object[]]@($null, 'hello', 3.14))
    $lists = @(
        $list1,
        $list2,
        $list3
    )

    function oracleType($list)
    {
        [System.Object[]]
    }

    function areEqual($a, $b)
    {
        if ($null -eq $a) {
            $null -eq $b
        } else {
            $a.Equals($b)
        }
    }

    foreach ($list in $lists) {
        $expectedType = oracleType $list
        $actualOutput = New-Object -TypeName 'System.Collections.ArrayList'

        Group-ListItem -Pair $list -OutVariable actualOutput | Out-Null

        Assert-True ($actualOutput.Count -eq 2)
        @(0, 1) |
            Assert-PipelineAll {param($row) $actualOutput[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $actualOutput[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $actualOutput[$row].Items.Length -eq 2} |
            Assert-PipelineAll {param($row) areEqual $actualOutput[$row].Items[0] $list[$row + 0]} |
            Assert-PipelineAll {param($row) areEqual $actualOutput[$row].Items[1] $list[$row + 1]} |
            Out-Null
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Pair with lists of length 4 or more' -Verbose:$headerVerbosity

    $list1 = @('a', 1, @(), ([System.Int32[]]@(1..5)))
    $list2 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello', @($null), 'world', 5))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.Int32]' -ArgumentList @(,[System.Int32[]]@(100, 200, 300, 400))
    $lists = @(
        $list1,
        $list2,
        $list3
    )

    function oracleType($list)
    {
        if ($list.Equals($list3)) {
            [System.Int32[]]
        } else {
            [System.Object[]]
        }
    }

    function areEqual($a, $b)
    {
        if ($null -eq $a) {
            $null -eq $b
        } else {
            return $a.Equals($b)
        }
    }

    foreach ($list in $lists) {
        $expectedType = oracleType $list
        $actualOutput = New-Object -TypeName 'System.Collections.ArrayList'

        Group-ListItem -Pair $list -OutVariable actualOutput | Out-Null

        Assert-True ($actualOutput.Count -eq 3)
        @(0, 1, 2) |
            Assert-PipelineAll {param($row) $actualOutput[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $actualOutput[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $actualOutput[$row].Items.Length -eq 2} |
            Assert-PipelineAll {param($row) areEqual $actualOutput[$row].Items[0] $list[$row + 0]} |
            Assert-PipelineAll {param($row) areEqual $actualOutput[$row].Items[1] $list[$row + 1]} |
            Out-Null
    }

    for ($size = 5; $size -lt 10; $size++) {
        $list = [System.Int32[]]@(1..$size)
        $expectedType = [System.Int32[]]
        $actualOutput = New-Object -TypeName 'System.Collections.ArrayList'

        Group-ListItem -Pair $list -OutVariable actualOutput | Out-Null

        Assert-True ($actualOutput.Count -eq ($size - 1))
        @(0..$($actualOutput.Count - 1)) |
            Assert-PipelineAll {param($row) $actualOutput[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $actualOutput[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $actualOutput[$row].Items.Length -eq 2} |
            Assert-PipelineAll {param($row) areEqual $actualOutput[$row].Items[0] $list[$row + 0]} |
            Assert-PipelineAll {param($row) areEqual $actualOutput[$row].Items[1] $list[$row + 1]} |
            Out-Null
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Window with nulls' -Verbose:$headerVerbosity

    $outputSize_  = New-Object -TypeName 'System.Collections.ArrayList'
    $outputSize0  = New-Object -TypeName 'System.Collections.ArrayList'
    $outputSize1  = New-Object -TypeName 'System.Collections.ArrayList'
    $outputSize1m = New-Object -TypeName 'System.Collections.ArrayList'
    $er_  = try {Group-ListItem -Window $null -OutVariable outputSize_ | Out-Null} catch {$_}
    $er0  = try {Group-ListItem -Window $null -OutVariable outputSize0 | Out-Null} catch {$_}
    $er1  = try {Group-ListItem -Window $null -OutVariable outputSize1 | Out-Null} catch {$_}
    $er1m = try {Group-ListItem -Window $null -OutVariable outputSize1m | Out-Null} catch {$_}

    @($outputSize_, $outputSize0, $outputSize1, $outputSize1m) |
        Assert-PipelineAll {param($output) $output.Count -eq 0} |
        Out-Null

    @($er_, $er0, $er1, $er1m) |
        Assert-PipelineAll {param($er) $er -is [System.Management.Automation.ErrorRecord]} |
        Assert-PipelineAll {param($er) $er.FullyQualifiedErrorId.Equals('ParameterArgumentValidationErrorNullNotAllowed,Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineAll {param($er) $er.Exception.ParameterName.Equals('Window', [System.StringComparison]::OrdinalIgnoreCase)} |
        Out-Null
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Window with lists of length 0' -Verbose:$headerVerbosity

    $list1 = @()
    $list2 = New-Object -TypeName 'System.Collections.ArrayList'
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.Double]'
    $lists = @(
        $list1,
        $list2,
        $list3
    )

    function oracleType($list)
    {
        if ($list.Equals($list3)) {
            [System.Double[]]
        } else {
            [System.Object[]]
        }
    }

    foreach ($list in $lists) {
        $expectedType = oracleType $list
        $outputSize_ = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize0 = New-Object -TypeName 'System.Collections.ArrayList'
        
        Group-ListItem -Window $list          -OutVariable outputSize_  | Out-Null
        Group-ListItem -Window $list -Size  0 -OutVariable outputSize0 | Out-Null
        Group-ListItem -Window $list -Size -2 | Assert-PipelineEmpty
        Group-ListItem -Window $list -Size -1 | Assert-PipelineEmpty
        Group-ListItem -Window $list -Size  1 | Assert-PipelineEmpty
        Group-ListItem -Window $list -Size  2 | Assert-PipelineEmpty

        Assert-True ($outputSize_.Count -eq 1)
        Assert-True ($outputSize0.Count -eq 1)

        @(0) |
            Assert-PipelineAll {param($row) $outputSize_[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize0[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize_[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize0[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize_[$row].Items.Length -eq 0} |
            Assert-PipelineAll {param($row) $outputSize0[$row].Items.Length -eq 0} |
            Out-Null
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Window with lists of length 1' -Verbose:$headerVerbosity

    $list1 = @($null)
    $list2 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello world'))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(3.14))
    $lists = @(
        $list1,
        $list2,
        $list3
    )

    function oracleType($list)
    {
        if ($list.Equals($list3)) {
            [System.Double[]]
        } else {
            [System.Object[]]
        }
    }

    function areEqual($a, $b)
    {
        if ($null -eq $a) {
            $null -eq $b
        } else {
            $a.Equals($b)
        }
    }

    foreach ($list in $lists) {
        $expectedType = oracleType $list
        $outputSize_ = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize0 = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize1 = New-Object -TypeName 'System.Collections.ArrayList'
        
        Group-ListItem -Window $list          -OutVariable outputSize_  | Out-Null
        Group-ListItem -Window $list -Size  0 -OutVariable outputSize0 | Out-Null
        Group-ListItem -Window $list -Size  1 -OutVariable outputSize1 | Out-Null
        Group-ListItem -Window $list -Size -2 | Assert-PipelineEmpty
        Group-ListItem -Window $list -Size -1 | Assert-PipelineEmpty
        Group-ListItem -Window $list -Size  2 | Assert-PipelineEmpty
        Group-ListItem -Window $list -Size  3 | Assert-PipelineEmpty

        Assert-True ($outputSize_.Count -eq 1)
        Assert-True ($outputSize0.Count -eq 1)
        Assert-True ($outputSize1.Count -eq 1)

        @(0) |
            Assert-PipelineAll {param($row) $outputSize0[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize0[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize0[$row].Items.Length -eq 0} |
            Out-Null

        @(0) |
            Assert-PipelineAll {param($row) $outputSize_[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize1[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize_[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize1[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize_[$row].Items.Length -eq 1} |
            Assert-PipelineAll {param($row) $outputSize1[$row].Items.Length -eq 1} |
            Assert-PipelineAll {param($row) Test-All @(0) {param($col) areEqual $outputSize_[$row].Items[$col] $list[$row + $col]}} |
            Assert-PipelineAll {param($row) Test-All @(0) {param($col) areEqual $outputSize1[$row].Items[$col] $list[$row + $col]}} |
            Out-Null
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Window with lists of length 2' -Verbose:$headerVerbosity

    $list1 = @($null, 5)
    $list2 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello', 'world'))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(3.14, 2.72))
    $lists = @(
        $list1,
        $list2,
        $list3
    )

    function oracleType($list)
    {
        if ($list.Equals($list3)) {
            [System.Double[]]
        } else {
            [System.Object[]]
        }
    }

    function areEqual($a, $b)
    {
        if ($null -eq $a) {
            $null -eq $b
        } else {
            $a.Equals($b)
        }
    }

    foreach ($list in $lists) {
        $expectedType = oracleType $list
        $outputSize_ = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize0 = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize1 = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize2 = New-Object -TypeName 'System.Collections.ArrayList'
        
        Group-ListItem -Window $list          -OutVariable outputSize_  | Out-Null
        Group-ListItem -Window $list -Size  0 -OutVariable outputSize0 | Out-Null
        Group-ListItem -Window $list -Size  1 -OutVariable outputSize1 | Out-Null
        Group-ListItem -Window $list -Size  2 -OutVariable outputSize2 | Out-Null
        Group-ListItem -Window $list -Size -2 | Assert-PipelineEmpty
        Group-ListItem -Window $list -Size -1 | Assert-PipelineEmpty
        Group-ListItem -Window $list -Size  3 | Assert-PipelineEmpty
        Group-ListItem -Window $list -Size  4 | Assert-PipelineEmpty

        Assert-True ($outputSize_.Count -eq 1)
        Assert-True ($outputSize0.Count -eq 1)
        Assert-True ($outputSize1.Count -eq 2)
        Assert-True ($outputSize2.Count -eq 1)

        @(0) |
            Assert-PipelineAll {param($row) $outputSize0[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize0[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize0[$row].Items.Length -eq 0} |
            Out-Null

        @(0, 1) |
            Assert-PipelineAll {param($row) $outputSize1[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize1[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize1[$row].Items.Length -eq 1} |
            Assert-PipelineAll {param($row) Test-All @(0) {param($col) areEqual $outputSize1[$row].Items[$col] $list[$row + $col]}} |
            Out-Null

        @(0) |
            Assert-PipelineAll {param($row) $outputSize_[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize2[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize_[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize2[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize_[$row].Items.Length -eq 2} |
            Assert-PipelineAll {param($row) $outputSize2[$row].Items.Length -eq 2} |
            Assert-PipelineAll {param($row) Test-All @(0, 1) {param($col) areEqual $outputSize_[$row].Items[$col] $list[$row + $col]}} |
            Assert-PipelineAll {param($row) Test-All @(0, 1) {param($col) areEqual $outputSize2[$row].Items[$col] $list[$row + $col]}} |
            Out-Null
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Window with lists of length 3' -Verbose:$headerVerbosity

    $list1 = @(3.14, 2.72, 0.00)
    $list2 = (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello', $null, 'world')))
    $list3 = (New-Object -TypeName 'System.Collections.Generic.List[System.Object]' -ArgumentList @(,[System.Object[]]@($null, 'hello', 3.14)))
    $lists = @(
        $list1,
        $list2,
        $list3
    )

    function oracleType($list)
    {
        [System.Object[]]
    }

    function areEqual($a, $b)
    {
        if ($null -eq $a) {
            $null -eq $b
        } else {
            $a.Equals($b)
        }
    }

    foreach ($list in $lists) {
        $expectedType = oracleType $list
        $outputSize_ = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize0 = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize1 = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize2 = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize3 = New-Object -TypeName 'System.Collections.ArrayList'
        
        Group-ListItem -Window $list          -OutVariable outputSize_  | Out-Null
        Group-ListItem -Window $list -Size  0 -OutVariable outputSize0 | Out-Null
        Group-ListItem -Window $list -Size  1 -OutVariable outputSize1 | Out-Null
        Group-ListItem -Window $list -Size  2 -OutVariable outputSize2 | Out-Null
        Group-ListItem -Window $list -Size  3 -OutVariable outputSize3 | Out-Null
        Group-ListItem -Window $list -Size -2 | Assert-PipelineEmpty
        Group-ListItem -Window $list -Size -1 | Assert-PipelineEmpty
        Group-ListItem -Window $list -Size  4 | Assert-PipelineEmpty
        Group-ListItem -Window $list -Size  5 | Assert-PipelineEmpty

        Assert-True ($outputSize_.Count -eq 1)
        Assert-True ($outputSize0.Count -eq 1)
        Assert-True ($outputSize1.Count -eq 3)
        Assert-True ($outputSize2.Count -eq 2)
        Assert-True ($outputSize3.Count -eq 1)

        @(0) |
            Assert-PipelineAll {param($row) $outputSize0[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize0[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize0[$row].Items.Length -eq 0} |
            Out-Null

        @(0, 1, 2) |
            Assert-PipelineAll {param($row) $outputSize1[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize1[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize1[$row].Items.Length -eq 1} |
            Assert-PipelineAll {param($row) Test-All @(0) {param($col) areEqual $outputSize1[$row].Items[$col] $list[$row + $col]}} |
            Out-Null

        @(0, 1) |
            Assert-PipelineAll {param($row) $outputSize2[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize2[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize2[$row].Items.Length -eq 2} |
            Assert-PipelineAll {param($row) Test-All @(0, 1) {param($col) areEqual $outputSize2[$row].Items[$col] $list[$row + $col]}} |
            Out-Null

        @(0) |
            Assert-PipelineAll {param($row) $outputSize_[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize3[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize_[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize3[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize_[$row].Items.Length -eq 3} |
            Assert-PipelineAll {param($row) $outputSize3[$row].Items.Length -eq 3} |
            Assert-PipelineAll {param($row) Test-All @(0, 1, 2) {param($col) areEqual $outputSize_[$row].Items[$col] $list[$row + $col]}} |
            Assert-PipelineAll {param($row) Test-All @(0, 1, 2) {param($col) areEqual $outputSize3[$row].Items[$col] $list[$row + $col]}} |
            Out-Null
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Window with lists of length 4 or more' -Verbose:$headerVerbosity

    $list1 = @('a', 1, @(), ([System.Int32[]]@(1..5)))
    $list2 = (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello', @($null), 'world', 5)))
    $list3 = (New-Object -TypeName 'System.Collections.Generic.List[System.Int32]' -ArgumentList @(,[System.Int32[]]@(100, 200, 300, 400)))
    $lists = @(
        $list1,
        $list2,
        $list3
    )

    function oracleType($list)
    {
        if ($list.Equals($list3)) {
            [System.Int32[]]
        } else {
            [System.Object[]]
        }
    }

    function areEqual($a, $b)
    {
        if ($null -eq $a) {
            $null -eq $b
        } else {
            $a.Equals($b)
        }
    }

    foreach ($list in $lists) {
        $expectedType = oracleType $list
        $outputSize_ = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize0 = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize1 = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize2 = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize3 = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize4 = New-Object -TypeName 'System.Collections.ArrayList'
        
        Group-ListItem -Window $list          -OutVariable outputSize_  | Out-Null
        Group-ListItem -Window $list -Size  0 -OutVariable outputSize0 | Out-Null
        Group-ListItem -Window $list -Size  1 -OutVariable outputSize1 | Out-Null
        Group-ListItem -Window $list -Size  2 -OutVariable outputSize2 | Out-Null
        Group-ListItem -Window $list -Size  3 -OutVariable outputSize3 | Out-Null
        Group-ListItem -Window $list -Size  4 -OutVariable outputSize4 | Out-Null
        Group-ListItem -Window $list -Size -2 | Assert-PipelineEmpty
        Group-ListItem -Window $list -Size -1 | Assert-PipelineEmpty
        Group-ListItem -Window $list -Size  5 | Assert-PipelineEmpty
        Group-ListItem -Window $list -Size  6 | Assert-PipelineEmpty

        Assert-True ($outputSize_.Count -eq 1)
        Assert-True ($outputSize0.Count -eq 1)
        Assert-True ($outputSize1.Count -eq 4)
        Assert-True ($outputSize2.Count -eq 3)
        Assert-True ($outputSize3.Count -eq 2)
        Assert-True ($outputSize4.Count -eq 1)

        @(0) |
            Assert-PipelineAll {param($row) $outputSize0[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize0[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize0[$row].Items.Length -eq 0} |
            Out-Null

        @(0, 1, 2, 3) |
            Assert-PipelineAll {param($row) $outputSize1[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize1[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize1[$row].Items.Length -eq 1} |
            Assert-PipelineAll {param($row) Test-All @(0) {param($col) areEqual $outputSize1[$row].Items[$col] $list[$row + $col]}} |
            Out-Null

        @(0, 1, 2) |
            Assert-PipelineAll {param($row) $outputSize2[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize2[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize2[$row].Items.Length -eq 2} |
            Assert-PipelineAll {param($row) Test-All @(0, 1) {param($col) areEqual $outputSize2[$row].Items[$col] $list[$row + $col]}} |
            Out-Null

        @(0, 1) |
            Assert-PipelineAll {param($row) $outputSize3[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize3[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize3[$row].Items.Length -eq 3} |
            Assert-PipelineAll {param($row) Test-All @(0, 1, 2) {param($col) areEqual $outputSize3[$row].Items[$col] $list[$row + $col]}} |
            Out-Null

        @(0) |
            Assert-PipelineAll {param($row) $outputSize_[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize4[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize_[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize4[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize_[$row].Items.Length -eq 4} |
            Assert-PipelineAll {param($row) $outputSize4[$row].Items.Length -eq 4} |
            Assert-PipelineAll {param($row) Test-All @(0, 1, 2, 3) {param($col) areEqual $outputSize_[$row].Items[$col] $list[$row + $col]}} |
            Assert-PipelineAll {param($row) Test-All @(0, 1, 2, 3) {param($col) areEqual $outputSize4[$row].Items[$col] $list[$row + $col]}} |
            Out-Null
    }

    for ($len = 5; $len -lt 10; $len++) {
        $list = [System.Int32[]]@(1..$len)
        $expectedType = [System.Int32[]]

        Group-ListItem -Window $list -Size -1 | Assert-PipelineEmpty
        Group-ListItem -Window $list -Size ($len + 1) | Assert-PipelineEmpty
        Group-ListItem -Window $list -Size 0 |
            Assert-PipelineAll {param($window) $window -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($window) $window.Items -is $expectedType} |
            Assert-PipelineAll {param($window) $window.Items.Length -eq 0} |
            Assert-PipelineSingle |
            Out-Null

        for ($size = 1; $size -le $len; $size++) {
            $outputSizeN = New-Object -TypeName 'System.Collections.ArrayList'
            Group-ListItem -Window $list -Size $size -OutVariable outputSizeN | Out-Null
            
            Assert-True ($outputSizeN.Count -eq ($len - $size + 1))
            @(0..$($outputSizeN.Count - 1)) |
                Assert-PipelineAll {param($row) $outputSizeN[$row] -isnot [System.Collections.IEnumerable]} |
                Assert-PipelineAll {param($row) $outputSizeN[$row].Items -is $expectedType} |
                Assert-PipelineAll {param($row) $outputSizeN[$row].Items.Length -eq $size} |
                Assert-PipelineAll {param($row) Test-All @(0..$($size - 1)) {param($col) areEqual $outputSizeN[$row].Items[$col] $list[$row + $col]}} |
                Out-Null
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Combine with nulls' -Verbose:$headerVerbosity

    $outputSize_  = New-Object -TypeName 'System.Collections.ArrayList'
    $outputSize0  = New-Object -TypeName 'System.Collections.ArrayList'
    $outputSize1  = New-Object -TypeName 'System.Collections.ArrayList'
    $outputSize1m = New-Object -TypeName 'System.Collections.ArrayList'
    $er_  = try {Group-ListItem -Combine $null          -OutVariable outputSize_ | Out-Null} catch {$_}
    $er0  = try {Group-ListItem -Combine $null -Size  0 -OutVariable outputSize0 | Out-Null} catch {$_}
    $er1  = try {Group-ListItem -Combine $null -Size  1 -OutVariable outputSize1 | Out-Null} catch {$_}
    $er1m = try {Group-ListItem -Combine $null -Size -1 -OutVariable outputSize1m | Out-Null} catch {$_}

    @($outputSize_, $outputSize0, $outputSize1, $outputSize1m) |
        Assert-PipelineAll {param($output) $output.Count -eq 0} |
        Out-Null

    @($er_, $er0, $er1, $er1m) |
        Assert-PipelineAll {param($er) $er -is [System.Management.Automation.ErrorRecord]} |
        Assert-PipelineAll {param($er) $er.FullyQualifiedErrorId.Equals('ParameterArgumentValidationErrorNullNotAllowed,Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineAll {param($er) $er.Exception.ParameterName.Equals('Combine', [System.StringComparison]::OrdinalIgnoreCase)} |
        Out-Null
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Combine with lists of length 0' -Verbose:$headerVerbosity

    $list1 = @()
    $list2 = New-Object -TypeName 'System.Collections.ArrayList'
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.Double]'
    $lists = @(
        $list1,
        $list2,
        $list3
    )

    function oracleType($list)
    {
        if ($list.Equals($list3)) {
            [System.Double[]]
        } else {
            [System.Object[]]
        }
    }

    foreach ($list in $lists) {
        $expectedType = oracleType $list
        $outputSize_ = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize0 = New-Object -TypeName 'System.Collections.ArrayList'

        Group-ListItem -Combine $list          -OutVariable outputSize_ | Out-Null
        Group-ListItem -Combine $list -Size  0 -OutVariable outputSize0 | Out-Null
        Group-ListItem -Combine $list -Size -2 | Assert-PipelineEmpty
        Group-ListItem -Combine $list -Size -1 | Assert-PipelineEmpty
        Group-ListItem -Combine $list -Size  1 | Assert-PipelineEmpty
        Group-ListItem -Combine $list -Size  2 | Assert-PipelineEmpty

        Assert-True ($outputSize_.Count -eq 1)
        Assert-True ($outputSize0.Count -eq 1)

        @(0) |
            Assert-PipelineAll {param($row) $outputSize_[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize0[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize_[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize0[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize_[$row].Items.Length -eq 0} |
            Assert-PipelineAll {param($row) $outputSize0[$row].Items.Length -eq 0} |
            Out-Null
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Combine with lists of length 1' -Verbose:$headerVerbosity

    $list1 = @($null)
    $list2 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello world'))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(3.14))
    $lists = @(
        $list1,
        $list2,
        $list3
    )

    function oracleType($list)
    {
        if ($list.Equals($list3)) {
            [System.Double[]]
        } else {
            [System.Object[]]
        }
    }

    function areEqual($a, $b)
    {
        if ($null -eq $a) {
            $null -eq $b
        } else {
            $a.Equals($b)
        }
    }

    foreach ($list in $lists) {
        $expectedType = oracleType $list
        $outputSize_ = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize0 = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize1 = New-Object -TypeName 'System.Collections.ArrayList'

        Group-ListItem -Combine $list          -OutVariable outputSize_ | Out-Null
        Group-ListItem -Combine $list -Size  0 -OutVariable outputSize0 | Out-Null
        Group-ListItem -Combine $list -Size  1 -OutVariable outputSize1 | Out-Null
        Group-ListItem -Combine $list -Size -2 | Assert-PipelineEmpty
        Group-ListItem -Combine $list -Size -1 | Assert-PipelineEmpty
        Group-ListItem -Combine $list -Size  2 | Assert-PipelineEmpty
        Group-ListItem -Combine $list -Size  3 | Assert-PipelineEmpty

        $expectedOutputSize0 = @(
            @{'Items' = @()}
        )
        $expectedOutputSize1 = @(
            @{'Items' = @(,$list[0])}
        )

        Assert-True ($outputSize_.Count -eq $expectedOutputSize1.Count)
        Assert-True ($outputSize0.Count -eq $expectedOutputSize0.Count)
        Assert-True ($outputSize1.Count -eq $expectedOutputSize1.Count)

        @(0) |
            Assert-PipelineAll {param($row) $outputSize0[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize0[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize0[$row].Items.Length -eq 0} |
            Assert-PipelineAll {param($row) Test-All @() {param($col) areEqual $outputSize0[$row].Items[$col] $expectedOutputSize0[$row].Items[$col]}} |
            Out-Null

        @(0) |
            Assert-PipelineAll {param($row) $outputSize_[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize1[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize_[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize1[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize_[$row].Items.Length -eq 1} |
            Assert-PipelineAll {param($row) $outputSize1[$row].Items.Length -eq 1} |
            Assert-PipelineAll {param($row) Test-All @(0) {param($col) areEqual $outputSize_[$row].Items[$col] $expectedOutputSize1[$row].Items[$col]}} |
            Assert-PipelineAll {param($row) Test-All @(0) {param($col) areEqual $outputSize1[$row].Items[$col] $expectedOutputSize1[$row].Items[$col]}} |
            Out-Null
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Combine with lists of length 2' -Verbose:$headerVerbosity

    $list1 = @($null, 5)
    $list2 = (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello', 'world')))
    $list3 = (New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(3.14, 2.72)))
    $lists = @(
        $list1,
        $list2,
        $list3
    )

    function oracleType($list)
    {
        if ($list.Equals($list3)) {
            [System.Double[]]
        } else {
            [System.Object[]]
        }
    }

    function areEqual($a, $b)
    {
        if ($null -eq $a) {
            $null -eq $b
        } else {
            $a.Equals($b)
        }
    }

    foreach ($list in $lists) {
        $expectedType = oracleType $list
        $outputSize_ = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize0 = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize1 = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize2 = New-Object -TypeName 'System.Collections.ArrayList'

        Group-ListItem -Combine $list          -OutVariable outputSize_ | Out-Null
        Group-ListItem -Combine $list -Size  0 -OutVariable outputSize0 | Out-Null
        Group-ListItem -Combine $list -Size  1 -OutVariable outputSize1 | Out-Null
        Group-ListItem -Combine $list -Size  2 -OutVariable outputSize2 | Out-Null
        Group-ListItem -Combine $list -Size -2 | Assert-PipelineEmpty
        Group-ListItem -Combine $list -Size -1 | Assert-PipelineEmpty
        Group-ListItem -Combine $list -Size  3 | Assert-PipelineEmpty
        Group-ListItem -Combine $list -Size  4 | Assert-PipelineEmpty

        $expectedOutputSize0 = @(
            @{'Items' = @()}
        )
        $expectedOutputSize1 = @(
            @{'Items' = @(,$list[0])},
            @{'Items' = @(,$list[1])}
        )
        $expectedOutputSize2 = @(
            @{'Items' = @($list[0], $list[1])}
        )

        Assert-True ($outputSize_.Count -eq $expectedOutputSize2.Count)
        Assert-True ($outputSize0.Count -eq $expectedOutputSize0.Count)
        Assert-True ($outputSize1.Count -eq $expectedOutputSize1.Count)
        Assert-True ($outputSize2.Count -eq $expectedOutputSize2.Count)

        @(0) |
            Assert-PipelineAll {param($row) $outputSize0[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize0[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize0[$row].Items.Length -eq 0} |
            Assert-PipelineAll {param($row) Test-All @() {param($col) areEqual $outputSize0[$row].Items[$col] $expectedOutputSize0[$row].Items[$col]}} |
            Out-Null

        @(0, 1) |
            Assert-PipelineAll {param($row) $outputSize1[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize1[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize1[$row].Items.Length -eq 1} |
            Assert-PipelineAll {param($row) Test-All @(0) {param($col) areEqual $outputSize1[$row].Items[$col] $expectedOutputSize1[$row].Items[$col]}} |
            Out-Null

        @(0) |
            Assert-PipelineAll {param($row) $outputSize_[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize2[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize_[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize2[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize_[$row].Items.Length -eq 2} |
            Assert-PipelineAll {param($row) $outputSize2[$row].Items.Length -eq 2} |
            Assert-PipelineAll {param($row) Test-All @(0, 1) {param($col) areEqual $outputSize_[$row].Items[$col] $expectedOutputSize2[$row].Items[$col]}} |
            Assert-PipelineAll {param($row) Test-All @(0, 1) {param($col) areEqual $outputSize2[$row].Items[$col] $expectedOutputSize2[$row].Items[$col]}} |
            Out-Null
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Combine with lists of length 3' -Verbose:$headerVerbosity

    $list1 = @(3.14, 2.72, 0.00)
    $list2 = (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello', $null, 'world')))
    $list3 = (New-Object -TypeName 'System.Collections.Generic.List[System.Object]' -ArgumentList @(,[System.Object[]]@($null, 'hello', 3.14)))
    $lists = @(
        $list1,
        $list2,
        $list3
    )

    function oracleType($list)
    {
        [System.Object[]]
    }

    function areEqual($a, $b)
    {
        if ($null -eq $a) {
            $null -eq $b
        } else {
            $a.Equals($b)
        }
    }

    foreach ($list in $lists) {
        $expectedType = oracleType $list
        $outputSize_ = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize0 = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize1 = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize2 = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize3 = New-Object -TypeName 'System.Collections.ArrayList'

        Group-ListItem -Combine $list          -OutVariable outputSize_ | Out-Null
        Group-ListItem -Combine $list -Size  0 -OutVariable outputSize0 | Out-Null
        Group-ListItem -Combine $list -Size  1 -OutVariable outputSize1 | Out-Null
        Group-ListItem -Combine $list -Size  2 -OutVariable outputSize2 | Out-Null
        Group-ListItem -Combine $list -Size  3 -OutVariable outputSize3 | Out-Null
        Group-ListItem -Combine $list -Size -2 | Assert-PipelineEmpty
        Group-ListItem -Combine $list -Size -1 | Assert-PipelineEmpty
        Group-ListItem -Combine $list -Size  4 | Assert-PipelineEmpty
        Group-ListItem -Combine $list -Size  5 | Assert-PipelineEmpty

        $expectedOutputSize0 = @(
            @{'Items' = @()}
        )
        $expectedOutputSize1 = @(
            @{'Items' = @(,$list[0])},
            @{'Items' = @(,$list[1])},
            @{'Items' = @(,$list[2])}
        )
        $expectedOutputSize2 = @(
            @{'Items' = @($list[0], $list[1])},
            @{'Items' = @($list[0], $list[2])},
            @{'Items' = @($list[1], $list[2])}
        )
        $expectedOutputSize3 = @(
            @{'Items' = @($list[0], $list[1], $list[2])}
        )

        Assert-True ($outputSize_.Count -eq $expectedOutputSize3.Count)
        Assert-True ($outputSize0.Count -eq $expectedOutputSize0.Count)
        Assert-True ($outputSize1.Count -eq $expectedOutputSize1.Count)
        Assert-True ($outputSize2.Count -eq $expectedOutputSize2.Count)
        Assert-True ($outputSize3.Count -eq $expectedOutputSize3.Count)

        @(0) |
            Assert-PipelineAll {param($row) $outputSize0[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize0[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize0[$row].Items.Length -eq 0} |
            Assert-PipelineAll {param($row) Test-All @() {param($col) areEqual $outputSize0[$row].Items[$col] $expectedOutputSize0[$row].Items[$col]}} |
            Out-Null

        @(0, 1, 2) |
            Assert-PipelineAll {param($row) $outputSize1[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize1[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize1[$row].Items.Length -eq 1} |
            Assert-PipelineAll {param($row) Test-All @(0) {param($col) areEqual $outputSize1[$row].Items[$col] $expectedOutputSize1[$row].Items[$col]}} |
            Out-Null

        @(0, 1, 2) |
            Assert-PipelineAll {param($row) $outputSize2[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize2[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize2[$row].Items.Length -eq 2} |
            Assert-PipelineAll {param($row) Test-All @(0, 1) {param($col) areEqual $outputSize2[$row].Items[$col] $expectedOutputSize2[$row].Items[$col]}} |
            Out-Null

        @(0) |
            Assert-PipelineAll {param($row) $outputSize_[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize3[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize_[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize3[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize_[$row].Items.Length -eq 3} |
            Assert-PipelineAll {param($row) $outputSize3[$row].Items.Length -eq 3} |
            Assert-PipelineAll {param($row) Test-All @(0, 1, 2) {param($col) areEqual $outputSize_[$row].Items[$col] $expectedOutputSize3[$row].Items[$col]}} |
            Assert-PipelineAll {param($row) Test-All @(0, 1, 2) {param($col) areEqual $outputSize3[$row].Items[$col] $expectedOutputSize3[$row].Items[$col]}} |
            Out-Null
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Combine with lists of length 4 or more' -Verbose:$headerVerbosity

    $list1 = @('a', 1, @(), ([System.Int32[]]@(1..5)))
    $list2 = (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello', @($null), 'world', 5)))
    $list3 = (New-Object -TypeName 'System.Collections.Generic.List[System.Int32]' -ArgumentList @(,[System.Int32[]]@(100, 200, 300, 400)))
    $lists = @(
        $list1,
        $list2,
        $list3
    )

    function oracleType($list)
    {
        if ($list.Equals($list3)) {
            [System.Int32[]]
        } else {
            [System.Object[]]
        }
    }

    function areEqual($a, $b)
    {
        if ($null -eq $a) {
            $null -eq $b
        } else {
            $a.Equals($b)
        }
    }

    foreach ($list in $lists) {
        $expectedType = oracleType $list
        $outputSize_ = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize0 = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize1 = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize2 = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize3 = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize4 = New-Object -TypeName 'System.Collections.ArrayList'

        Group-ListItem -Combine $list          -OutVariable outputSize_ | Out-Null
        Group-ListItem -Combine $list -Size  0 -OutVariable outputSize0 | Out-Null
        Group-ListItem -Combine $list -Size  1 -OutVariable outputSize1 | Out-Null
        Group-ListItem -Combine $list -Size  2 -OutVariable outputSize2 | Out-Null
        Group-ListItem -Combine $list -Size  3 -OutVariable outputSize3 | Out-Null
        Group-ListItem -Combine $list -Size  4 -OutVariable outputSize4 | Out-Null
        Group-ListItem -Combine $list -Size -2 | Assert-PipelineEmpty
        Group-ListItem -Combine $list -Size -1 | Assert-PipelineEmpty
        Group-ListItem -Combine $list -Size  5 | Assert-PipelineEmpty
        Group-ListItem -Combine $list -Size  6 | Assert-PipelineEmpty

        $expectedOutputSize0 = @(
            @{'Items' = @()}
        )
        $expectedOutputSize1 = @(
            @{'Items' = @(,$list[0])},
            @{'Items' = @(,$list[1])},
            @{'Items' = @(,$list[2])},
            @{'Items' = @(,$list[3])}
        )
        $expectedOutputSize2 = @(
            @{'Items' = @($list[0], $list[1])},
            @{'Items' = @($list[0], $list[2])},
            @{'Items' = @($list[0], $list[3])},
            @{'Items' = @($list[1], $list[2])},
            @{'Items' = @($list[1], $list[3])},
            @{'Items' = @($list[2], $list[3])}
        )
        $expectedOutputSize3 = @(
            @{'Items' = @($list[0], $list[1], $list[2])},
            @{'Items' = @($list[0], $list[1], $list[3])},
            @{'Items' = @($list[0], $list[2], $list[3])},
            @{'Items' = @($list[1], $list[2], $list[3])}
        )
        $expectedOutputSize4 = @(
            @{'Items' = @($list[0], $list[1], $list[2], $list[3])}
        )

        Assert-True ($outputSize_.Count -eq $expectedOutputSize4.Count)
        Assert-True ($outputSize0.Count -eq $expectedOutputSize0.Count)
        Assert-True ($outputSize1.Count -eq $expectedOutputSize1.Count)
        Assert-True ($outputSize2.Count -eq $expectedOutputSize2.Count)
        Assert-True ($outputSize3.Count -eq $expectedOutputSize3.Count)
        Assert-True ($outputSize4.Count -eq $expectedOutputSize4.Count)

        @(0) |
            Assert-PipelineAll {param($row) $outputSize0[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize0[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize0[$row].Items.Length -eq 0} |
            Assert-PipelineAll {param($row) Test-All @() {param($col) areEqual $outputSize0[$row].Items[$col] $expectedOutputSize0[$row].Items[$col]}} |
            Out-Null

        @(0, 1, 2, 3) |
            Assert-PipelineAll {param($row) $outputSize1[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize1[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize1[$row].Items.Length -eq 1} |
            Assert-PipelineAll {param($row) Test-All @(0) {param($col) areEqual $outputSize1[$row].Items[$col] $expectedOutputSize1[$row].Items[$col]}} |
            Out-Null

        @(0, 1, 2, 3, 4, 5) |
            Assert-PipelineAll {param($row) $outputSize2[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize2[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize2[$row].Items.Length -eq 2} |
            Assert-PipelineAll {param($row) Test-All @(0, 1) {param($col) areEqual $outputSize2[$row].Items[$col] $expectedOutputSize2[$row].Items[$col]}} |
            Out-Null

        @(0, 1, 2, 3) |
            Assert-PipelineAll {param($row) $outputSize3[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize3[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize3[$row].Items.Length -eq 3} |
            Assert-PipelineAll {param($row) Test-All @(0, 1, 2) {param($col) areEqual $outputSize3[$row].Items[$col] $expectedOutputSize3[$row].Items[$col]}} |
            Out-Null

        @(0) |
            Assert-PipelineAll {param($row) $outputSize_[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize4[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $outputSize_[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize4[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $outputSize_[$row].Items.Length -eq 4} |
            Assert-PipelineAll {param($row) $outputSize4[$row].Items.Length -eq 4} |
            Assert-PipelineAll {param($row) Test-All @(0, 1, 2, 3) {param($col) areEqual $outputSize_[$row].Items[$col] $expectedOutputSize4[$row].Items[$col]}} |
            Assert-PipelineAll {param($row) Test-All @(0, 1, 2, 3) {param($col) areEqual $outputSize4[$row].Items[$col] $expectedOutputSize4[$row].Items[$col]}} |
            Out-Null
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
            Group-ListItem -Combine $list -Size $k |
                Assert-PipelineAll {param($combin) $combin -isnot [System.Collections.IEnumerable]} |
                Assert-PipelineAll {param($combin) $combin.Items -is [System.Int32[]]} |
                Assert-PipelineAll {param($combin) $combin.Items.Length -eq $k} |
                Assert-PipelineCount (numCombin $list $k) |
                Out-Null
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
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
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
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
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
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
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
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
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
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
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
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
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
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
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
            Assert-True ($_ -isnot [System.Collections.IEnumerable])
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

    $noarg = New-Object 'System.Object'

    foreach ($strength in @($noarg, -1, 0, 1, 2, 3)) {
        $gliArgs = @{
            'Strength' = $strength
        }
        if ($noarg.Equals($strength)) {
            $gliArgs.Remove('Strength')
        }

        $out1 = New-Object -TypeName 'System.Collections.ArrayList'
        $out2 = New-Object -TypeName 'System.Collections.ArrayList'
        $out3 = New-Object -TypeName 'System.Collections.ArrayList'
        $out4 = New-Object -TypeName 'System.Collections.ArrayList'

        $er1 = try {Group-ListItem @gliArgs -CoveringArray $null -OutVariable out1 | Out-Null} catch {$_}
        $er2 = try {Group-ListItem @gliArgs -CoveringArray @($null) -OutVariable out2 | Out-Null} catch {$_}
        $er3 = try {Group-ListItem @gliArgs -CoveringArray (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList (,@(@(1,2,3), $null))) -OutVariable out3 | Out-Null} catch {$_}
        $er4 = try {Group-ListItem @gliArgs -CoveringArray (New-Object -TypeName 'System.Collections.Generic.List[System.Object]' -ArgumentList (,@($null, @(4,5,6)))) -OutVariable out4 | Out-Null} catch {$_}

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

        Assert-True $er1.Exception.ParameterName.Equals('CoveringArray', [System.StringComparison]::OrdinalIgnoreCase)
        Assert-True $er2.Exception.ParameterName.Equals('CoveringArray', [System.StringComparison]::OrdinalIgnoreCase)
        Assert-True $er3.Exception.ParameterName.Equals('CoveringArray', [System.StringComparison]::OrdinalIgnoreCase)
        Assert-True $er4.Exception.ParameterName.Equals('CoveringArray', [System.StringComparison]::OrdinalIgnoreCase)
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CoveringArray with lists of length 0' -Verbose:$headerVerbosity

    $noarg = New-Object 'System.Object'

    foreach ($strength in @($noarg, -1, 0, 1, 2, 3, 4, 5)) {
        $gliArgs = @{
            'Strength' = $strength
        }
        if ($noarg.Equals($strength)) {
            $gliArgs.Remove('Strength')
        }

        Group-ListItem @gliArgs -CoveringArray @(,@()) | Assert-PipelineEmpty

        Group-ListItem @gliArgs -CoveringArray @(@(), (New-Object -TypeName 'System.Collections.Generic.List[System.String]')) | Assert-PipelineEmpty
        Group-ListItem @gliArgs -CoveringArray @(@(), @($null)) | Assert-PipelineEmpty
        Group-ListItem @gliArgs -CoveringArray @(@($null), @()) | Assert-PipelineEmpty
        Group-ListItem @gliArgs -CoveringArray @(@(1,2), (New-Object -TypeName 'System.Collections.ArrayList')) | Assert-PipelineEmpty
        Group-ListItem @gliArgs -CoveringArray @(@(), (New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@(1,2)))) | Assert-PipelineEmpty

        Group-ListItem @gliArgs -CoveringArray @(@(), @(), @()) | Assert-PipelineEmpty
        Group-ListItem @gliArgs -CoveringArray @(@(), @($null), @(1,2)) | Assert-PipelineEmpty
        Group-ListItem @gliArgs -CoveringArray @(@(1,2), @(), @($null)) | Assert-PipelineEmpty
        Group-ListItem @gliArgs -CoveringArray @(@($null), @(1,2), @()) | Assert-PipelineEmpty

        Group-ListItem @gliArgs -CoveringArray @(@(), @(), @(), @()) | Assert-PipelineEmpty
        Group-ListItem @gliArgs -CoveringArray @(@(), @($null), @(1,2), @('a','b','c')) | Assert-PipelineEmpty
        Group-ListItem @gliArgs -CoveringArray @(@($null), @(), @(1,2), @('a','b','c')) | Assert-PipelineEmpty
        Group-ListItem @gliArgs -CoveringArray @(@($null), @(1,2), @(), @('a','b','c')) | Assert-PipelineEmpty
        Group-ListItem @gliArgs -CoveringArray @(@($null), @(1,2), @('a','b','c'), @()) | Assert-PipelineEmpty
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CoveringArray with no lists' -Verbose:$headerVerbosity

    $noarg = New-Object 'System.Object'

    foreach ($strength in @($noarg, -1, 0, 1)) {
        $gliArgs = @{
            'Strength' = $strength
        }
        if ($noarg.Equals($strength)) {
            $gliArgs.Remove('Strength')
        }

        Group-ListItem @gliArgs -CoveringArray @() | Assert-PipelineEmpty
        Group-ListItem @gliArgs -CoveringArray (New-Object -TypeName 'System.Collections.ArrayList') | Assert-PipelineEmpty
        Group-ListItem @gliArgs -CoveringArray (New-Object -TypeName 'System.Collections.Generic.List[System.Byte[]]') | Assert-PipelineEmpty
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CoveringArray with 1 list' -Verbose:$headerVerbosity

    #foreach list in ...
        #foreach strength in ...
            #covering array algorithm is deterministic
            #if strength < 1
                #no output
            #else
                #all values in list are found in at least one row in covering array
    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CoveringArray with 2 lists' -Verbose:$headerVerbosity

    #foreach list in ...
        #foreach strength in ...
            #covering array algorithm is deterministic
            #if strength < 1
                #no output
            #else if strength = 1
                #all values in both lists are found in at least one row in covering array
            #else
                #all combinations of values from both lists are found in at least one row in covering array
    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CoveringArray with 3 lists' -Verbose:$headerVerbosity

    #foreach list in ...
        #foreach strength in ...
            #covering array algorithm is deterministic
            #if strength < 1
                #no output
            #else if strength = 1
                #all values in three lists are found in at least one row in covering array
            #else if strength = 2
                #all combinations of values from any 2 lists are found in at least one row in covering array
            #else
                #all combinations of values from any 3 lists are found in at least one row in covering array
    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CoveringArray with 4 lists' -Verbose:$headerVerbosity

    #foreach list in ...
        #foreach strength in ...
            #covering array algorithm is deterministic
            #if strength < 1
                #no output
            #else if strength = 1
                #all values in three lists are found in at least one row in covering array
            #else if strength = 2
                #all combinations of values from any 2 lists are found in at least one row in covering array
            #else if strength = 3
                #all combinations of values from any 3 lists are found in at least one row in covering array
            #else
                #all combinations of values from any 4 lists are found in at least one row in covering array
    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

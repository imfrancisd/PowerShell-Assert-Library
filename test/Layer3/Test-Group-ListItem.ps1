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
    Write-Verbose -Message 'Test Group-ListItem -Zip with nulls' -Verbose:$headerVerbosity

    $e1 = try {$groups1 = Group-ListItem -Zip $null} catch {$_.Exception}
    $e2 = try {$groups2 = Group-ListItem -Zip @($null)} catch {$_.Exception}
    $e3 = try {$groups3 = Group-ListItem -Zip @(@(1,2,3), $null, @(4,5,6))} catch {$_.Exception}

    Assert-True ($e1 -is [System.Management.Automation.ParameterBindingException])
    Assert-True ($e2 -is [System.Management.Automation.ParameterBindingException])
    Assert-True ($e3 -is [System.Management.Automation.ParameterBindingException])

    Assert-True $e1.CommandInvocation.InvocationName.Equals('Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True $e2.CommandInvocation.InvocationName.Equals('Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True $e3.CommandInvocation.InvocationName.Equals('Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase)

    Assert-True $e1.ParameterName.Equals('Zip', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True $e2.ParameterName.Equals('Zip', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True $e3.ParameterName.Equals('Zip', [System.StringComparison]::OrdinalIgnoreCase)

    Assert-Null $groups1
    Assert-Null $groups2
    Assert-Null $groups3
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Zip with lists of length 0' -Verbose:$headerVerbosity

    Group-ListItem -Zip @(,@()) | Assert-PipelineEmpty

    Group-ListItem -Zip @(@(), (New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@()))) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@(), @($null)) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@($null), @()) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@(1,2), (New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@()))) | Assert-PipelineEmpty
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
    Group-ListItem -Zip (New-Object -TypeName 'System.Collections.Generic.List[System.Byte]' -ArgumentList @(,[System.Byte[]]@())) | Assert-PipelineEmpty
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Zip with 1 list' -Verbose:$headerVerbosity

    $groups1 = Group-ListItem -Zip @(,[System.String[]]@('a', 'b', 'c', 'd', 'e')) | Assert-PipelineCount -Equals 5 | ForEach-Object {
        Assert-True ($_.Items.GetType() -eq [System.String[]])
        Assert-True ($_.Items.Length -eq 1)
        $_
    }
    Assert-True ('a' -eq $groups1[0].Items[0])
    Assert-True ('b' -eq $groups1[1].Items[0])
    Assert-True ('c' -eq $groups1[2].Items[0])
    Assert-True ('d' -eq $groups1[3].Items[0])
    Assert-True ('e' -eq $groups1[4].Items[0])

    $objects = New-Object -TypeName 'System.Collections.Generic.List[System.Object]' -ArgumentList @(,@('a', $null, @(),@(1,2,3,$null), 'e'))
    $groups2 = Group-ListItem -Zip @(,$objects) | Assert-PipelineCount -Equals 5 | ForEach-Object {
        Assert-True ($_.Items.GetType() -eq [System.Object[]])
        Assert-True ($_.Items.Length -eq 1)
        $_
    }
    Assert-True ('a' -eq $groups2[0].Items[0])
    Assert-True ($null -eq $groups2[1].Items[0])
    Assert-True ([System.Object]::ReferenceEquals($objects[2], $groups2[2].Items[0]))
    Assert-True ([System.Object]::ReferenceEquals($objects[3], $groups2[3].Items[0]))
    Assert-True ('e' -eq $groups2[4].Items[0])

    for ($i = 1; $i -lt 10; $i++) {
        $list = [System.Int32[]]@($($i)..$($i + $i - 1))
        Assert-True ($list.Count -eq $i)

        $count = 0
        Group-ListItem -Zip @(, $list) | Assert-PipelineCount -Equals ($i) | ForEach-Object {
            Assert-True ($_.Items.GetType() -eq [System.Int32[]])
            Assert-True ($_.Items.Length -eq 1)
            Assert-True ($_.Items[0] -eq $list[$count % $i])
            $count++
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Zip with 2 lists' -Verbose:$headerVerbosity

    $list1 = [System.String[]]@('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k')
    $list2 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('do', 're', 'mi', 'fa', 'so', 'la', 'ti', 'do'))
    $groups1 = Group-ListItem -Zip @($list1, $list2) | Assert-PipelineCount -Equals 8 | ForEach-Object {
        Assert-True ($_.Items.GetType() -eq [System.String[]])
        Assert-True ($_.Items.Length -eq 2)
        $_
    }

    for ($i = 0; $i -lt 8; $i++) {
        Assert-True ([System.Object]::ReferenceEquals($groups1[$i].Items[0], $list1[$i]))
        Assert-True ([System.Object]::ReferenceEquals($groups1[$i].Items[1], $list2[$i]))
    }

    $list1 = New-Object -TypeName 'System.Collections.Generic.List[System.Object]' -ArgumentList @(,[System.Object[]]@('do', @(), 'mi', 'fa', $null, 'la', @(), 'do'))
    $list2 = [System.Object[]]@('hello', @(3.14, 5, $null), $null, 'world', '!', 10, 0, $null, 3, 1, 4, 1, 5, 9)
    $groups2 = Group-ListItem -Zip @($list1, $list2) | Assert-PipelineCount -Equals 8 | ForEach-Object {
        Assert-True ($_.Items.GetType() -eq [System.Object[]])
        Assert-True ($_.Items.Length -eq 2)
        $_
    }

    for ($i = 0; $i -lt 8; $i++) {
        Assert-True ([System.Object]::ReferenceEquals($groups2[$i].Items[0], $list1[$i]))
        Assert-True ([System.Object]::ReferenceEquals($groups2[$i].Items[1], $list2[$i]))
    }

    for ($iSize = 0; $iSize -lt 10; $iSize++) {
        if ($iSize -eq 0) {
            $list1 = [System.Int32[]]@()
        } else {
            $list1 = [System.Int32[]]@($iSize..$($iSize + $iSize - 1))
        }
        Assert-True ($list1.Length -eq $iSize)

        for ($jSize = 0; $jSize -lt 10; $jSize++) {
            if ($jSize -eq 0) {
                $list2 = New-Object -TypeName 'System.Collections.Generic.List[System.Int32]'
            } else {
                $list2 = New-Object -TypeName 'System.Collections.Generic.List[System.Int32]' -ArgumentList @(,[System.Int32[]]@($($iSize*100)..$($iSize*100 + $jSize - 1)))
            }
            Assert-True ($list2.Count -eq $jSize)

            $count = 0
            Group-ListItem -Zip @($list1, $list2) | Assert-PipelineCount -Equals @($iSize, $jSize | Sort-Object)[0] | ForEach-Object {
                Assert-True ($_.Items.GetType() -eq [System.Int32[]])
                Assert-True ($_.Items.Length -eq 2)
                Assert-True ($_.Items[0] -eq $list1[$count])
                Assert-True ($_.Items[1] -eq $list2[$count])
                $count++
            }
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Zip with 3 lists' -Verbose:$headerVerbosity

    $list1 = [System.String[]]@('a', 'b', 'c', 'd', 'e', 'f')
    $list2 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('do', 're', 'mi', 'fa', 'so', 'la', 'ti', 'do'))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('1', '2', '3', '4', '5', '6', '7'))
    $groups1 = Group-ListItem -Zip @($list1, $list2, $list3) | Assert-PipelineCount -Equals 6 | ForEach-Object {
        Assert-True ($_.Items.GetType() -eq [System.String[]])
        Assert-True ($_.Items.Length -eq 3)
        $_
    }

    for ($i = 0; $i -lt 6; $i++) {
        Assert-True ([System.Object]::ReferenceEquals($groups1[$i].Items[0], $list1[$i]))
        Assert-True ([System.Object]::ReferenceEquals($groups1[$i].Items[1], $list2[$i]))
        Assert-True ([System.Object]::ReferenceEquals($groups1[$i].Items[2], $list3[$i]))
    }

    $list1 = [System.Object[]]@('hello', @(3.14, 5, $null), $null, 'world', '!', 10)
    $list2 = New-Object -TypeName 'System.Collections.Generic.List[System.Object]' -ArgumentList @(,[System.Object[]]@('do', @(), 'mi', 'fa', $null, 'la', @(), 'do'))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('1', '2', '3', '4', '5', '6', '7'))
    $groups2 = Group-ListItem -Zip @($list1, $list2, $list3) | Assert-PipelineCount -Equals 6 | ForEach-Object {
        Assert-True ($_.Items.GetType() -eq [System.Object[]])
        Assert-True ($_.Items.Length -eq 3)
        $_
    }

    for ($i = 0; $i -lt 6; $i++) {
        Assert-True ([System.Object]::ReferenceEquals($groups2[$i].Items[0], $list1[$i]))
        Assert-True ([System.Object]::ReferenceEquals($groups2[$i].Items[1], $list2[$i]))
        Assert-True ([System.Object]::ReferenceEquals($groups2[$i].Items[2], $list3[$i]))
    }

    for ($iSize = 0; $iSize -lt 5; $iSize++) {
        if ($iSize -eq 0) {
            $list1 = [System.Int32[]]@()
        } else {
            $list1 = [System.Int32[]]@($iSize..$($iSize + $iSize - 1))
        }
        Assert-True ($list1.Length -eq $iSize)

        for ($jSize = 0; $jSize -lt 5; $jSize++) {
            if ($jSize -eq 0) {
                $list2 = New-Object -TypeName 'System.Collections.Generic.List[System.Int32]'
            } else {
                $list2 = New-Object -TypeName 'System.Collections.Generic.List[System.Int32]' -ArgumentList @(,[System.Int32[]]@($($iSize*100)..$($iSize*100 + $jSize - 1)))
            }
            Assert-True ($list2.Count -eq $jSize)

            for ($kSize = 0; $kSize -lt 5; $kSize++) {
                if ($kSize -eq 0) {
                    $list3 = [System.Int32[]]@()
                } else {
                    $list3 = [System.Int32[]]@($($iSize + 50)..$($iSize + 50 + $kSize - 1))
                }
                Assert-True ($list3.Length -eq $kSize)

                $count = 0
                Group-ListItem -Zip @($list1, $list2, $list3) | Assert-PipelineCount -Equals @($iSize, $jSize, $kSize | Sort-Object)[0] | ForEach-Object {
                    Assert-True ($_.Items.GetType() -eq [System.Int32[]])
                    Assert-True ($_.Items.Length -eq 3)
                    Assert-True ($_.Items[0] -eq $list1[$count])
                    Assert-True ($_.Items[1] -eq $list2[$count])
                    Assert-True ($_.Items[2] -eq $list3[$count])
                    $count++
                }
            }
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Zip with 4 lists' -Verbose:$headerVerbosity

    $list1 = [System.String[]]@('hello', 'world', 'how', 'are', 'you')
    $list2 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('1', '2', '3', '4'))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('do', 're', 'mi', 'fa', 'so', 'la', 'ti', 'do'))
    $list4 = [System.String[]]@('a', 'b', 'c', 'd', 'e', 'f')
    $groups1 = Group-ListItem -Zip @($list1, $list2, $list3, $list4) | Assert-PipelineCount -Equals 4 | ForEach-Object {
        Assert-True ($_.Items.GetType() -eq [System.String[]])
        Assert-True ($_.Items.Length -eq 4)
        $_
    }

    for ($i = 0; $i -lt 4; $i++) {
        Assert-True ([System.Object]::ReferenceEquals($groups1[$i].Items[0], $list1[$i]))
        Assert-True ([System.Object]::ReferenceEquals($groups1[$i].Items[1], $list2[$i]))
        Assert-True ([System.Object]::ReferenceEquals($groups1[$i].Items[2], $list3[$i]))
        Assert-True ([System.Object]::ReferenceEquals($groups1[$i].Items[3], $list4[$i]))
    }

    $list1 = [System.Object[]]@('hello', @(3.14, 5, $null), $null, 'world', '!')
    $list2 = New-Object -TypeName 'System.Collections.Generic.List[System.Object]' -ArgumentList @(,[System.Object[]]@('1', $null, @(), '4'))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('do', 're', 'mi', 'fa', 'so', 'la', 'ti', 'do'))
    $list4 = [System.String[]]@('a', 'b', 'c', 'd', 'e', 'f')
    $groups2 = Group-ListItem -Zip @($list1, $list2, $list3, $list4) | Assert-PipelineCount -Equals 4 | ForEach-Object {
        Assert-True ($_.Items.GetType() -eq [System.Object[]])
        Assert-True ($_.Items.Length -eq 4)
        $_
    }

    for ($i = 0; $i -lt 4; $i++) {
        Assert-True ([System.Object]::ReferenceEquals($groups2[$i].Items[0], $list1[$i]))
        Assert-True ([System.Object]::ReferenceEquals($groups2[$i].Items[1], $list2[$i]))
        Assert-True ([System.Object]::ReferenceEquals($groups2[$i].Items[2], $list3[$i]))
        Assert-True ([System.Object]::ReferenceEquals($groups2[$i].Items[3], $list4[$i]))
    }

    for ($iSize = 0; $iSize -lt 5; $iSize++) {
        if ($iSize -eq 0) {
            $list1 = [System.Int32[]]@()
        } else {
            $list1 = [System.Int32[]]@($iSize..$($iSize + $iSize - 1))
        }
        Assert-True ($list1.Length -eq $iSize)

        for ($jSize = 0; $jSize -lt 5; $jSize++) {
            if ($jSize -eq 0) {
                $list2 = New-Object -TypeName 'System.Collections.Generic.List[System.Int32]'
            } else {
                $list2 = New-Object -TypeName 'System.Collections.Generic.List[System.Int32]' -ArgumentList @(,[System.Int32[]]@($($iSize*100)..$($iSize*100 + $jSize - 1)))
            }
            Assert-True ($list2.Count -eq $jSize)

            for ($kSize = 0; $kSize -lt 5; $kSize++) {
                if ($kSize -eq 0) {
                    $list3 = [System.Int32[]]@()
                } else {
                    $list3 = [System.Int32[]]@($($iSize + 50)..$($iSize + 50 + $kSize - 1))
                }
                Assert-True ($list3.Length -eq $kSize)

                for ($lSize = 0; $lSize -lt 5; $lSize++) {
                    if ($lSize -eq 0) {
                        $list4 = [System.Int32[]]@()
                    } else {
                        $list4 = [System.Int32[]]@($($iSize * -10)..$($iSize * -10 + $lSize - 1))
                    }
                    Assert-True ($list4.Length -eq $lSize)

                    $count = 0
                    Group-ListItem -Zip @($list1, $list2, $list3, $list4) | Assert-PipelineCount -Equals @($iSize, $jSize, $kSize, $lSize | Sort-Object)[0] | ForEach-Object {
                        Assert-True ($_.Items.GetType() -eq [System.Int32[]])
                        Assert-True ($_.Items.Length -eq 4)
                        Assert-True ($_.Items[0] -eq $list1[$count])
                        Assert-True ($_.Items[1] -eq $list2[$count])
                        Assert-True ($_.Items[2] -eq $list3[$count])
                        Assert-True ($_.Items[3] -eq $list4[$count])
                        $count++
                    }
                }
            }
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Pair with nulls' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Pair with lists of length 0' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Pair with lists of length 1' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Pair with lists of length 2' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Pair with lists of length 3' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Pair with lists of length 4 or more' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Window with nulls' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Window with lists of length 0' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Window with lists of length 1' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Window with lists of length 2' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Window with lists of length 3' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Window with lists of length 4 or more' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Combine with nulls' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Combine with lists of length 0' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Combine with lists of length 1' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Combine with lists of length 2' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Combine with lists of length 3' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Combine with lists of length 4 or more' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Permute with nulls' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Permute with lists of length 0' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Permute with lists of length 1' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Permute with lists of length 2' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Permute with lists of length 3' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Permute with lists of length 4 or more' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CartesianProduct with nulls' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CartesianProduct with lists of length 0' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CartesianProduct with no lists' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CartesianProduct with 1 list' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CartesianProduct with 2 lists' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CartesianProduct with 3 lists' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CartesianProduct with 4 lists' -Verbose:$headerVerbosity

    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
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

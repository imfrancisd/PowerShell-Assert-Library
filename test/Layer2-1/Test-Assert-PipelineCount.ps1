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
    Write-Verbose -Message 'Test Assert-PipelineCount with get-help -full' -Verbose:$headerVerbosity

    $err = try {$fullHelp = Get-Help Assert-PipelineCount -Full} catch {$_}

    Assert-Null $err
    Assert-True ($fullHelp.Name -is [System.String])
    Assert-True ($fullHelp.Name.Equals('Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($fullHelp.description -is [System.Collections.ICollection])
    Assert-True ($fullHelp.description.Count -gt 0)
    Assert-NotNull $fullHelp.examples
    Assert-True (0 -lt @($fullHelp.examples.example).Count)
    Assert-True ('' -ne @($fullHelp.examples.example)[0].code)
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount ParameterSet: Equals' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Assert-PipelineCount).ParameterSets |
        Where-Object {'Equals'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
    Assert-NotNull $paramSet

    $inputObject = $paramSet.Parameters |
        Where-Object {'InputObject'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
    Assert-NotNull $inputObject

    $equalsParam = $paramSet.Parameters |
        Where-Object {'Equals'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
    Assert-NotNull $equalsParam

    Assert-True ($inputObject.IsMandatory)
    Assert-True ($inputObject.ParameterType -eq [System.Object])
    Assert-True ($inputObject.ValueFromPipeline)
    Assert-False ($inputObject.ValueFromPipelineByPropertyName)
    Assert-False ($inputObject.ValueFromRemainingArguments)
    Assert-True (0 -gt $inputObject.Position)
    Assert-True (0 -eq $inputObject.Aliases.Count)

    Assert-True ($equalsParam.IsMandatory)
    Assert-True ($equalsParam.ParameterType -eq [System.Int64])
    Assert-False ($equalsParam.ValueFromPipeline)
    Assert-False ($equalsParam.ValueFromPipelineByPropertyName)
    Assert-False ($equalsParam.ValueFromRemainingArguments)
    Assert-True (0 -eq $equalsParam.Position)
    Assert-True (0 -eq $equalsParam.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount ParameterSet: Minimum' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Assert-PipelineCount).ParameterSets |
        Where-Object {'Minimum'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
    Assert-NotNull $paramSet

    $inputObject = $paramSet.Parameters |
        Where-Object {'InputObject'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
    Assert-NotNull $inputObject

    $minimumParam = $paramSet.Parameters |
        Where-Object {'Minimum'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
    Assert-NotNull $minimumParam

    Assert-True ($inputObject.IsMandatory)
    Assert-True ($inputObject.ParameterType -eq [System.Object])
    Assert-True ($inputObject.ValueFromPipeline)
    Assert-False ($inputObject.ValueFromPipelineByPropertyName)
    Assert-False ($inputObject.ValueFromRemainingArguments)
    Assert-True (0 -gt $inputObject.Position)
    Assert-True (0 -eq $inputObject.Aliases.Count)

    Assert-True ($minimumParam.IsMandatory)
    Assert-True ($minimumParam.ParameterType -eq [System.Int64])
    Assert-False ($minimumParam.ValueFromPipeline)
    Assert-False ($minimumParam.ValueFromPipelineByPropertyName)
    Assert-False ($minimumParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $minimumParam.Position)
    Assert-True (0 -eq $minimumParam.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount ParameterSet: Maximum' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Assert-PipelineCount).ParameterSets |
        Where-Object {'Maximum'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
    Assert-NotNull $paramSet

    $inputObject = $paramSet.Parameters |
        Where-Object {'InputObject'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
    Assert-NotNull $inputObject

    $maximumParam = $paramSet.Parameters |
        Where-Object {'Maximum'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
    Assert-NotNull $maximumParam

    Assert-True ($inputObject.IsMandatory)
    Assert-True ($inputObject.ParameterType -eq [System.Object])
    Assert-True ($inputObject.ValueFromPipeline)
    Assert-False ($inputObject.ValueFromPipelineByPropertyName)
    Assert-False ($inputObject.ValueFromRemainingArguments)
    Assert-True (0 -gt $inputObject.Position)
    Assert-True (0 -eq $inputObject.Aliases.Count)

    Assert-True ($maximumParam.IsMandatory)
    Assert-True ($maximumParam.ParameterType -eq [System.Int64])
    Assert-False ($maximumParam.ValueFromPipeline)
    Assert-False ($maximumParam.ValueFromPipelineByPropertyName)
    Assert-False ($maximumParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $maximumParam.Position)
    Assert-True (0 -eq $maximumParam.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Equals with Boolean $true' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {$true | Assert-PipelineCount 1 -OutVariable out1 | Out-Null} catch {$_}
    $er2 = try {$true | Assert-PipelineCount -Equals 1 -OutVariable out2 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 1)
    Assert-True ($out2.Count -eq 1)
    Assert-True $out1[0]
    Assert-True $out2[0]
    Assert-Null $er1
    Assert-Null $er2

    $out3 = New-Object -TypeName 'System.Collections.ArrayList'
    $out4 = New-Object -TypeName 'System.Collections.ArrayList'
    $er3 = try {$true | Assert-PipelineCount 0 -OutVariable out3 | Out-Null} catch {$_}
    $er4 = try {$true | Assert-PipelineCount -Equals 0 -OutVariable out4 | Out-Null} catch {$_}

    Assert-True ($out3.Count -eq 0)
    Assert-True ($out4.Count -eq 0)
    Assert-True ($er3 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er4 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er3.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er4.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))

    $out5 = New-Object -TypeName 'System.Collections.ArrayList'
    $out6 = New-Object -TypeName 'System.Collections.ArrayList'
    $er5 = try {$true | Assert-PipelineCount 2 -OutVariable out5 | Out-Null} catch {$_}
    $er6 = try {$true | Assert-PipelineCount -Equals 2 -OutVariable out6 | Out-Null} catch {$_}

    Assert-True ($out5.Count -eq 1)
    Assert-True ($out6.Count -eq 1)
    Assert-True $out5[0]
    Assert-True $out6[0]
    Assert-True ($er5 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er6 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er5.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er6.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Equals with Boolean $false' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {$false | Assert-PipelineCount 1 -OutVariable out1 | Out-Null} catch {$_}
    $er2 = try {$false | Assert-PipelineCount -Equals 1 -OutVariable out2 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 1)
    Assert-True ($out2.Count -eq 1)
    Assert-False $out1[0]
    Assert-False $out2[0]
    Assert-Null $er1
    Assert-Null $er2

    $out3 = New-Object -TypeName 'System.Collections.ArrayList'
    $out4 = New-Object -TypeName 'System.Collections.ArrayList'
    $er3 = try {$false | Assert-PipelineCount 0 -OutVariable out3 | Out-Null} catch {$_}
    $er4 = try {$false | Assert-PipelineCount -Equals 0 -OutVariable out4 | Out-Null} catch {$_}

    Assert-True ($out3.Count -eq 0)
    Assert-True ($out4.Count -eq 0)
    Assert-True ($er3 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er4 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er3.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er4.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))

    $out5 = New-Object -TypeName 'System.Collections.ArrayList'
    $out6 = New-Object -TypeName 'System.Collections.ArrayList'
    $er5 = try {$false | Assert-PipelineCount 2 -OutVariable out5 | Out-Null} catch {$_}
    $er6 = try {$false | Assert-PipelineCount -Equals 2 -OutVariable out6 | Out-Null} catch {$_}

    Assert-True ($out5.Count -eq 1)
    Assert-True ($out6.Count -eq 1)
    Assert-False $out5[0]
    Assert-False $out6[0]
    Assert-True ($er5 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er6 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er5.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er6.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Equals with $null' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {$null | Assert-PipelineCount 1 -OutVariable out1 | Out-Null} catch {$_}
    $er2 = try {$null | Assert-PipelineCount -Equals 1 -OutVariable out2 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 1)
    Assert-True ($out2.Count -eq 1)
    Assert-Null $out1[0]
    Assert-Null $out2[0]
    Assert-Null $er1
    Assert-Null $er2

    $out3 = New-Object -TypeName 'System.Collections.ArrayList'
    $out4 = New-Object -TypeName 'System.Collections.ArrayList'
    $er3 = try {$null | Assert-PipelineCount 0 -OutVariable out3 | Out-Null} catch {$_}
    $er4 = try {$null | Assert-PipelineCount -Equals 0 -OutVariable out4 | Out-Null} catch {$_}

    Assert-True ($out3.Count -eq 0)
    Assert-True ($out4.Count -eq 0)
    Assert-True ($er3 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er4 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er3.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er4.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))

    $out5 = New-Object -TypeName 'System.Collections.ArrayList'
    $out6 = New-Object -TypeName 'System.Collections.ArrayList'
    $er5 = try {$null | Assert-PipelineCount 2 -OutVariable out5 | Out-Null} catch {$_}
    $er6 = try {$null | Assert-PipelineCount -Equals 2 -OutVariable out6 | Out-Null} catch {$_}

    Assert-True ($out5.Count -eq 1)
    Assert-True ($out6.Count -eq 1)
    Assert-Null $out5[0]
    Assert-Null $out6[0]
    Assert-True ($er5 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er6 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er5.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er6.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Equals with Non-Booleans that are convertible to $true' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanTrue) {
        $out1 = New-Object -TypeName 'System.Collections.ArrayList'
        $out2 = New-Object -TypeName 'System.Collections.ArrayList'
        $er1 = try {,$item | Assert-PipelineCount 1 -OutVariable out1 | Out-Null} catch {$_}
        $er2 = try {,$item | Assert-PipelineCount -Equals 1 -OutVariable out2 | Out-Null} catch {$_}

        Assert-True ($out1.Count -eq 1)
        Assert-True ($out2.Count -eq 1)
        Assert-True ($out1[0].Equals($item))
        Assert-True ($out2[0].Equals($item))
        Assert-Null $er1
        Assert-Null $er2

        $out3 = New-Object -TypeName 'System.Collections.ArrayList'
        $out4 = New-Object -TypeName 'System.Collections.ArrayList'
        $er3 = try {,$item | Assert-PipelineCount 0 -OutVariable out3 | Out-Null} catch {$_}
        $er4 = try {,$item | Assert-PipelineCount -Equals 0 -OutVariable out4 | Out-Null} catch {$_}

        Assert-True ($out3.Count -eq 0)
        Assert-True ($out4.Count -eq 0)
        Assert-True ($er3 -is [System.Management.Automation.ErrorRecord])
        Assert-True ($er4 -is [System.Management.Automation.ErrorRecord])
        Assert-True ($er3.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($er4.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))

        $out5 = New-Object -TypeName 'System.Collections.ArrayList'
        $out6 = New-Object -TypeName 'System.Collections.ArrayList'
        $er5 = try {,$item | Assert-PipelineCount 2 -OutVariable out5 | Out-Null} catch {$_}
        $er6 = try {,$item | Assert-PipelineCount -Equals 2 -OutVariable out6 | Out-Null} catch {$_}

        Assert-True ($out5.Count -eq 1)
        Assert-True ($out6.Count -eq 1)
        Assert-True ($out5[0].Equals($item))
        Assert-True ($out6[0].Equals($item))
        Assert-True ($er5 -is [System.Management.Automation.ErrorRecord])
        Assert-True ($er6 -is [System.Management.Automation.ErrorRecord])
        Assert-True ($er5.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($er6.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
    }
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Equals with Non-Booleans that are convertible to $false' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanFalse) {
        $out1 = New-Object -TypeName 'System.Collections.ArrayList'
        $out2 = New-Object -TypeName 'System.Collections.ArrayList'
        $er1 = try {,$item | Assert-PipelineCount 1 -OutVariable out1 | Out-Null} catch {$_}
        $er2 = try {,$item | Assert-PipelineCount -Equals 1 -OutVariable out2 | Out-Null} catch {$_}

        Assert-True ($out1.Count -eq 1)
        Assert-True ($out2.Count -eq 1)
        Assert-True ($out1[0].Equals($item))
        Assert-True ($out2[0].Equals($item))
        Assert-Null $er1
        Assert-Null $er2

        $out3 = New-Object -TypeName 'System.Collections.ArrayList'
        $out4 = New-Object -TypeName 'System.Collections.ArrayList'
        $er3 = try {,$item | Assert-PipelineCount 0 -OutVariable out3 | Out-Null} catch {$_}
        $er4 = try {,$item | Assert-PipelineCount -Equals 0 -OutVariable out4 | Out-Null} catch {$_}

        Assert-True ($out3.Count -eq 0)
        Assert-True ($out4.Count -eq 0)
        Assert-True ($er3 -is [System.Management.Automation.ErrorRecord])
        Assert-True ($er4 -is [System.Management.Automation.ErrorRecord])
        Assert-True ($er3.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($er4.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))

        $out5 = New-Object -TypeName 'System.Collections.ArrayList'
        $out6 = New-Object -TypeName 'System.Collections.ArrayList'
        $er5 = try {,$item | Assert-PipelineCount 2 -OutVariable out5 | Out-Null} catch {$_}
        $er6 = try {,$item | Assert-PipelineCount -Equals 2 -OutVariable out6 | Out-Null} catch {$_}

        Assert-True ($out5.Count -eq 1)
        Assert-True ($out6.Count -eq 1)
        Assert-True ($out5[0].Equals($item))
        Assert-True ($out6[0].Equals($item))
        Assert-True ($er5 -is [System.Management.Automation.ErrorRecord])
        Assert-True ($er6 -is [System.Management.Automation.ErrorRecord])
        Assert-True ($er5.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($er6.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
    }
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Equals with pipelines that contain zero objects' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {@() | Assert-PipelineCount 0 -OutVariable out1 | Out-Null} catch {$_}
    $er2 = try {@() | Assert-PipelineCount -Equals 0 -OutVariable out2 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 0)
    Assert-True ($out2.Count -eq 0)
    Assert-Null $er1
    Assert-Null $er2

    $out3 = New-Object -TypeName 'System.Collections.ArrayList'
    $out4 = New-Object -TypeName 'System.Collections.ArrayList'
    $er3 = try {& {@()} | Assert-PipelineCount 1 -OutVariable out3 | Out-Null} catch {$_}
    $er4 = try {& {@()} | Assert-PipelineCount -Equals 1 -OutVariable out4 | Out-Null} catch {$_}

    Assert-True ($out3.Count -eq 0)
    Assert-True ($out4.Count -eq 0)
    Assert-True ($er3 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er4 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er3.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er4.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))

    function f1 {}
    $out5 = New-Object -TypeName 'System.Collections.ArrayList'
    $out6 = New-Object -TypeName 'System.Collections.ArrayList'
    $er5 = try {f1 | Assert-PipelineCount (-1) -OutVariable out5 | Out-Null} catch {$_}
    $er6 = try {f1 | Assert-PipelineCount -Equals (-1) -OutVariable out6 | Out-Null} catch {$_}

    Assert-True ($out5.Count -eq 0)
    Assert-True ($out6.Count -eq 0)
    Assert-True ($er5 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er6 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er5.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er6.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Equals with a pipeline that contains many objects' -Verbose:$headerVerbosity

    $items = @(101..110)
    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {$items | Assert-PipelineCount 10 -OutVariable out1 | Out-Null} catch {$_}
    $er2 = try {$items | Assert-PipelineCount -Equals 10 -OutVariable out2 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq $items.Length)
    Assert-True ($out2.Count -eq $items.Length)
    for ($i = 0; $i -lt $out1.Count; $i++) {
        Assert-True ($out1[$i] -eq $items[$i])
        Assert-True ($out2[$i] -eq $items[$i])
    }
    Assert-Null $er1
    Assert-Null $er2

    $items = @(101..110)
    $out3 = New-Object -TypeName 'System.Collections.ArrayList'
    $out4 = New-Object -TypeName 'System.Collections.ArrayList'
    $er3 = try {$items | Assert-PipelineCount 11 -OutVariable out3 | Out-Null} catch {$_}
    $er4 = try {$items | Assert-PipelineCount -Equals 11 -OutVariable out4 | Out-Null} catch {$_}

    Assert-True ($out3.Count -eq $items.Length)
    Assert-True ($out4.Count -eq $items.Length)
    for ($i = 0; $i -lt $out3.Count; $i++) {
        Assert-True ($out3[$i] -eq $items[$i])
        Assert-True ($out4[$i] -eq $items[$i])
    }
    Assert-True ($er3 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er4 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er3.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er4.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))

    $items = @(101..110)
    $out5 = New-Object -TypeName 'System.Collections.ArrayList'
    $out6 = New-Object -TypeName 'System.Collections.ArrayList'
    $er5 = try {$items | Assert-PipelineCount 9 -OutVariable out5 | Out-Null} catch {$_}
    $er6 = try {$items | Assert-PipelineCount -Equals 9 -OutVariable out6 | Out-Null} catch {$_}

    Assert-True ($out5.Count -eq 9)
    Assert-True ($out6.Count -eq 9)
    for ($i = 0; $i -lt $out5.Count; $i++) {
        Assert-True ($out5[$i] -eq $items[$i])
        Assert-True ($out6[$i] -eq $items[$i])
    }
    Assert-True ($er5 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er6 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er5.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er6.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Minimum with Boolean $true' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {$true | Assert-PipelineCount -Minimum 1 -OutVariable out1 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 1)
    Assert-True $out1[0]
    Assert-Null $er1

    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $er2 = try {$true | Assert-PipelineCount -Minimum 0 -OutVariable out2 | Out-Null} catch {$_}

    Assert-True ($out2.Count -eq 1)
    Assert-True $out2[0]
    Assert-Null $er2

    $out3 = New-Object -TypeName 'System.Collections.ArrayList'
    $er3 = try {$true | Assert-PipelineCount -Minimum 2 -OutVariable out3 | Out-Null} catch {$_}

    Assert-True ($out3.Count -eq 1)
    Assert-True $out3[0]
    Assert-True ($er3 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er3.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Minimum with Boolean $false' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {$false | Assert-PipelineCount -Minimum 1 -OutVariable out1 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 1)
    Assert-False $out1[0]
    Assert-Null $er1

    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $er2 = try {$false | Assert-PipelineCount -Minimum 0 -OutVariable out2 | Out-Null} catch {$_}

    Assert-True ($out2.Count -eq 1)
    Assert-False $out2[0]
    Assert-Null $er2

    $out3 = New-Object -TypeName 'System.Collections.ArrayList'
    $er3 = try {$false | Assert-PipelineCount -Minimum 2 -OutVariable out3 | Out-Null} catch {$_}

    Assert-True ($out3.Count -eq 1)
    Assert-False $out3[0]
    Assert-True ($er3 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er3.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Minimum with $null' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {$null | Assert-PipelineCount -Minimum 1 -OutVariable out1 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 1)
    Assert-Null $out1[0]
    Assert-Null $er1

    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $er2 = try {$null | Assert-PipelineCount -Minimum 0 -OutVariable out2 | Out-Null} catch {$_}

    Assert-True ($out2.Count -eq 1)
    Assert-Null $out2[0]
    Assert-Null $er2

    $out3 = New-Object -TypeName 'System.Collections.ArrayList'
    $er3 = try {$null | Assert-PipelineCount -Minimum 2 -OutVariable out3 | Out-Null} catch {$_}

    Assert-True ($out3.Count -eq 1)
    Assert-Null $out3[0]
    Assert-True ($er3 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er3.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Minimum with Non-Booleans that are convertible to $true' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanTrue) {
        $out1 = New-Object -TypeName 'System.Collections.ArrayList'
        $er1 = try {,$item | Assert-PipelineCount -Minimum 1 -OutVariable out1 | Out-Null} catch {$_}

        Assert-True ($out1.Count -eq 1)
        Assert-True ($out1[0].Equals($item))
        Assert-Null $er1

        $out2 = New-Object -TypeName 'System.Collections.ArrayList'
        $er2 = try {,$item | Assert-PipelineCount -Minimum 0 -OutVariable out2 | Out-Null} catch {$_}

        Assert-True ($out2.Count -eq 1)
        Assert-True ($out2[0].Equals($item))
        Assert-Null $er2

        $out3 = New-Object -TypeName 'System.Collections.ArrayList'
        $er3 = try {,$item | Assert-PipelineCount -Minimum 2 -OutVariable out3 | Out-Null} catch {$_}

        Assert-True ($out3.Count -eq 1)
        Assert-True ($out3[0].Equals($item))
        Assert-True ($er3 -is [System.Management.Automation.ErrorRecord])
        Assert-True ($er3.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
    }
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Minimum with Non-Booleans that are convertible to $false' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanFalse) {
        $out1 = New-Object -TypeName 'System.Collections.ArrayList'
        $er1 = try {,$item | Assert-PipelineCount -Minimum 1 -OutVariable out1 | Out-Null} catch {$_}

        Assert-True ($out1.Count -eq 1)
        Assert-True ($out1[0].Equals($item))
        Assert-Null $er1

        $out2 = New-Object -TypeName 'System.Collections.ArrayList'
        $er2 = try {,$item | Assert-PipelineCount -Minimum 0 -OutVariable out2 | Out-Null} catch {$_}

        Assert-True ($out2.Count -eq 1)
        Assert-True ($out2[0].Equals($item))
        Assert-Null $er2

        $out3 = New-Object -TypeName 'System.Collections.ArrayList'
        $er3 = try {,$item | Assert-PipelineCount -Minimum 2 -OutVariable out3 | Out-Null} catch {$_}

        Assert-True ($out3.Count -eq 1)
        Assert-True ($out3[0].Equals($item))
        Assert-True ($er3 -is [System.Management.Automation.ErrorRecord])
        Assert-True ($er3.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
    }
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Minimum with pipelines that contain zero objects' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {@() | Assert-PipelineCount -Minimum 0 -OutVariable out1 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 0)
    Assert-Null $er1

    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $er2 = try {& {@()} | Assert-PipelineCount -Minimum 1 -OutVariable out2 | Out-Null} catch {$_}

    Assert-True ($out2.Count -eq 0)
    Assert-True ($er2 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er2.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))

    function f1 {}
    $out3 = New-Object -TypeName 'System.Collections.ArrayList'
    $er3 = try {f1 | Assert-PipelineCount -Minimum (-1) -OutVariable out3 | Out-Null} catch {$_}

    Assert-True ($out3.Count -eq 0)
    Assert-Null $er3
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Minimum with a pipeline that contains many objects' -Verbose:$headerVerbosity

    $items = @(101..110)
    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {$items | Assert-PipelineCount -Minimum 10 -OutVariable out1 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq $items.Length)
    for ($i = 0; $i -lt $out1.Count; $i++) {
        Assert-True ($out1[$i] -eq $items[$i])
    }
    Assert-Null $er1

    $items = @(101..110)
    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $er2 = try {$items | Assert-PipelineCount -Minimum 11 -OutVariable out2 | Out-Null} catch {$_}

    Assert-True ($out2.Count -eq $items.Length)
    for ($i = 0; $i -lt $out2.Count; $i++) {
        Assert-True ($out2[$i] -eq $items[$i])
    }
    Assert-True ($er2 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er2.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))

    $items = @(101..110)
    $out3 = New-Object -TypeName 'System.Collections.ArrayList'
    $er3 = try {$items | Assert-PipelineCount -Minimum 9 -OutVariable out3 | Out-Null} catch {$_}

    Assert-True ($out3.Count -eq $items.Length)
    for ($i = 0; $i -lt $out3.Count; $i++) {
        Assert-True ($out3[$i] -eq $items[$i])
    }
    Assert-Null $er3
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Maximum with Boolean $true' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {$true | Assert-PipelineCount -Maximum 1 -OutVariable out1 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 1)
    Assert-True $out1[0]
    Assert-Null $er1

    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $er2 = try {$true | Assert-PipelineCount -Maximum 0 -OutVariable out2 | Out-Null} catch {$_}

    Assert-True ($out2.Count -eq 0)
    Assert-True ($er2 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er2.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))

    $out3 = New-Object -TypeName 'System.Collections.ArrayList'
    $er3 = try {$true | Assert-PipelineCount -Maximum 2 -OutVariable out3 | Out-Null} catch {$_}

    Assert-True ($out3.Count -eq 1)
    Assert-True $out3[0]
    Assert-Null $er3
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Maximum with Boolean $false' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {$false | Assert-PipelineCount -Maximum 1 -OutVariable out1 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 1)
    Assert-False $out1[0]
    Assert-Null $er1

    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $er2 = try {$false | Assert-PipelineCount -Maximum 0 -OutVariable out2 | Out-Null} catch {$_}

    Assert-True ($out2.Count -eq 0)
    Assert-True ($er2 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er2.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))

    $out3 = New-Object -TypeName 'System.Collections.ArrayList'
    $er3 = try {$false | Assert-PipelineCount -Maximum 2 -OutVariable out3 | Out-Null} catch {$_}

    Assert-True ($out3.Count -eq 1)
    Assert-False $out3[0]
    Assert-Null $er3
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Maximum with $null' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {$null | Assert-PipelineCount -Maximum 1 -OutVariable out1 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 1)
    Assert-Null $out1[0]
    Assert-Null $er1

    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $er2 = try {$null | Assert-PipelineCount -Maximum 0 -OutVariable out2 | Out-Null} catch {$_}

    Assert-True ($out2.Count -eq 0)
    Assert-True ($er2 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er2.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))

    $out3 = New-Object -TypeName 'System.Collections.ArrayList'
    $er3 = try {$null | Assert-PipelineCount -Maximum 2 -OutVariable out3 | Out-Null} catch {$_}

    Assert-True ($out3.Count -eq 1)
    Assert-Null $out3[0]
    Assert-Null $er3
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Maximum with Non-Booleans that are convertible to $true' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanTrue) {
        $out1 = New-Object -TypeName 'System.Collections.ArrayList'
        $er1 = try {,$item | Assert-PipelineCount -Maximum 1 -OutVariable out1 | Out-Null} catch {$_}

        Assert-True ($out1.Count -eq 1)
        Assert-True ($out1[0].Equals($item))
        Assert-Null $er1

        $out2 = New-Object -TypeName 'System.Collections.ArrayList'
        $er2 = try {,$item | Assert-PipelineCount -Maximum 0 -OutVariable out2 | Out-Null} catch {$_}

        Assert-True ($out2.Count -eq 0)
        Assert-True ($er2 -is [System.Management.Automation.ErrorRecord])
        Assert-True ($er2.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))

        $out3 = New-Object -TypeName 'System.Collections.ArrayList'
        $er3 = try {,$item | Assert-PipelineCount -Maximum 2 -OutVariable out3 | Out-Null} catch {$_}

        Assert-True ($out3.Count -eq 1)
        Assert-True ($out3[0].Equals($item))
        Assert-Null $er3
    }
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Maximum with Non-Booleans that are convertible to $false' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanFalse) {
        $out1 = New-Object -TypeName 'System.Collections.ArrayList'
        $er1 = try {,$item | Assert-PipelineCount -Maximum 1 -OutVariable out1 | Out-Null} catch {$_}

        Assert-True ($out1.Count -eq 1)
        Assert-True ($out1[0].Equals($item))
        Assert-Null $er1

        $out2 = New-Object -TypeName 'System.Collections.ArrayList'
        $er2 = try {,$item | Assert-PipelineCount -Maximum 0 -OutVariable out2 | Out-Null} catch {$_}

        Assert-True ($out2.Count -eq 0)
        Assert-True ($er2 -is [System.Management.Automation.ErrorRecord])
        Assert-True ($er2.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))

        $out3 = New-Object -TypeName 'System.Collections.ArrayList'
        $er3 = try {,$item | Assert-PipelineCount -Maximum 2 -OutVariable out3 | Out-Null} catch {$_}

        Assert-True ($out3.Count -eq 1)
        Assert-True ($out3[0].Equals($item))
        Assert-Null $er3
    }
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Maximum with pipelines that contain zero objects' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {@() | Assert-PipelineCount -Maximum 0 -OutVariable out1 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 0)
    Assert-Null $er1

    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $er2 = try {& {@()} | Assert-PipelineCount -Maximum 1 -OutVariable out2 | Out-Null} catch {$_}

    Assert-True ($out2.Count -eq 0)
    Assert-Null $er2

    function f1 {}
    $out3 = New-Object -TypeName 'System.Collections.ArrayList'
    $er3 = try {f1 | Assert-PipelineCount -Maximum (-1) -OutVariable out3 | Out-Null} catch {$_}

    Assert-True ($out3.Count -eq 0)
    Assert-True ($er3 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er3.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount -Maximum with a pipeline that contains many objects' -Verbose:$headerVerbosity

    $items = @(101..110)
    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {$items | Assert-PipelineCount -Maximum 10 -OutVariable out1 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq $items.Length)
    for ($i = 0; $i -lt $out1.Count; $i++) {
        Assert-True ($out1[$i] -eq $items[$i])
    }
    Assert-Null $er1

    $items = @(101..110)
    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $er2 = try {$items | Assert-PipelineCount -Maximum 11 -OutVariable out2 | Out-Null} catch {$_}

    Assert-True ($out2.Count -eq $items.Length)
    for ($i = 0; $i -lt $out2.Count; $i++) {
        Assert-True ($out2[$i] -eq $items[$i])
    }
    Assert-Null $er2

    $items = @(101..110)
    $out3 = New-Object -TypeName 'System.Collections.ArrayList'
    $er3 = try {$items | Assert-PipelineCount -Maximum 9 -OutVariable out3 | Out-Null} catch {$_}

    Assert-True ($out3.Count -eq 9)
    for ($i = 0; $i -lt $out3.Count; $i++) {
        Assert-True ($out3[$i] -eq $items[$i])
    }
    Assert-True ($er3 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er3.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Assert-PipelineCount with a non-pipeline input' -Verbose:$headerVerbosity

    $er1 = try {Assert-PipelineCount -InputObject $true -Equals 1 | Out-Null} catch {$_}
    $er2 = try {Assert-PipelineCount -InputObject $false -Minimum 1 | Out-Null} catch {$_}
    $er3 = try {Assert-PipelineCount -InputObject $null -Maximum 1| Out-Null} catch {$_}
    $er4 = try {Assert-PipelineCount -InputObject @() -Minimum 1| Out-Null} catch {$_}
    $er5 = try {Assert-PipelineCount -InputObject @(0) -Maximum 0 | Out-Null} catch {$_}

    $errorMessage = 'Assert-PipelineCount must take its input from the pipeline.'

    Assert-True ($er1 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er2 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er3 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er4 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er5 -is [System.Management.Automation.ErrorRecord])

    Assert-True ($er1.FullyQualifiedErrorId.Equals('PipelineArgumentOnly,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er2.FullyQualifiedErrorId.Equals('PipelineArgumentOnly,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er3.FullyQualifiedErrorId.Equals('PipelineArgumentOnly,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er4.FullyQualifiedErrorId.Equals('PipelineArgumentOnly,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er5.FullyQualifiedErrorId.Equals('PipelineArgumentOnly,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
}

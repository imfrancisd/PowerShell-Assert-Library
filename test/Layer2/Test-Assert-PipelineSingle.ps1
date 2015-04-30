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
    Write-Verbose -Message 'Test Assert-PipelineSingle with get-help -full' -Verbose:$headerVerbosity

    $err = try {$fullHelp = Get-Help Assert-PipelineSingle -Full} catch {$_}

    Assert-Null $err
    Assert-True ($fullHelp.Name -is [System.String])
    Assert-True ($fullHelp.Name.Equals('Assert-PipelineSingle', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($fullHelp.description -is [System.Collections.ICollection])
    Assert-True ($fullHelp.description.Count -gt 0)
    Assert-NotNull $fullHelp.examples
    Assert-True (0 -lt @($fullHelp.examples.example).Count)
    Assert-True ('' -ne @($fullHelp.examples.example)[0].code)
}

& {
    Write-Verbose -Message 'Test Assert-PipelineSingle parameters' -Verbose:$headerVerbosity

    $paramSets = @((Get-Command -Name Assert-PipelineSingle).ParameterSets)
    Assert-True (1 -eq $paramSets.Count)

    $inputObject = $paramSets[0].Parameters |
        Where-Object {'InputObject'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
    Assert-NotNull $inputObject

    Assert-True ($inputObject.IsMandatory)
    Assert-True ($inputObject.ParameterType -eq [System.Object])
    Assert-True ($inputObject.ValueFromPipeline)
    Assert-False ($inputObject.ValueFromPipelineByPropertyName)
    Assert-False ($inputObject.ValueFromRemainingArguments)
    Assert-True (0 -eq $inputObject.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Assert-PipelineSingle with Boolean $true' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {$true | Assert-PipelineSingle -OutVariable out1 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 1)
    Assert-True ($out1[0])
    Assert-Null $er1
}

& {
    Write-Verbose -Message 'Test Assert-PipelineSingle with Boolean $false' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {$false | Assert-PipelineSingle -OutVariable out1 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 1)
    Assert-False ($out1[0])
    Assert-Null $er1
}

& {
    Write-Verbose -Message 'Test Assert-PipelineSingle with $null' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {$null | Assert-PipelineSingle -OutVariable out1 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 1)
    Assert-Null ($out1[0])
    Assert-Null $er1
}

& {
    Write-Verbose -Message 'Test Assert-PipelineSingle with Non-Booleans that are convertible to $true' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanTrue) {
        $out1 = New-Object -TypeName 'System.Collections.ArrayList'
        $er1 = try {,$item | Assert-PipelineSingle -OutVariable out1 | Out-Null} catch {$_}

        Assert-True ($out1.Count -eq 1)
        Assert-True ($out1[0].Equals($item))
        Assert-Null $er1
    }
}

& {
    Write-Verbose -Message 'Test Assert-PipelineSingle with Non-Booleans that are convertible to $false' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanFalse) {
        $out1 = New-Object -TypeName 'System.Collections.ArrayList'
        $er1 = try {,$item | Assert-PipelineSingle -OutVariable out1 | Out-Null} catch {$_}

        Assert-True ($out1.Count -eq 1)
        Assert-True ($out1[0].Equals($item))
        Assert-Null $er1
    }
}

& {
    Write-Verbose -Message 'Test Assert-PipelineSingle with pipelines that contain zero objects' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {@() | Assert-PipelineSingle -OutVariable out1 | Out-Null} catch {$_}

    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $er2 = try {& {@()} | Assert-PipelineSingle -OutVariable out2 | Out-Null} catch {$_}

    function f1 {}
    $out3 = New-Object -TypeName 'System.Collections.ArrayList'
    $er3 = try {f1 | Assert-PipelineSingle -OutVariable out3 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 0)
    Assert-True ($out2.Count -eq 0)
    Assert-True ($out3.Count -eq 0)

    Assert-True ($er1 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er2 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er3 -is [System.Management.Automation.ErrorRecord])

    Assert-True ($er1.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineSingle', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er2.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineSingle', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er3.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineSingle', [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Assert-PipelineSingle with a pipeline that contains many objects' -Verbose:$headerVerbosity

    $items = @(101..110)
    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {$items | Assert-PipelineSingle -OutVariable out1 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 1)
    Assert-True ($out1[0] -eq $items[0])
    Assert-True ($er1.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineSingle', [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Assert-PipelineSingle with a non-pipeline input' -Verbose:$headerVerbosity

    foreach ($item in @($true, $false, $null, @(), @(0))) {
        $out1 = New-Object -TypeName 'System.Collections.ArrayList'
        $er1 = try {Assert-PipelineSingle -InputObject $item -OutVariable out1 | Out-Null} catch {$_}

        Assert-True ($out1.Count -eq 0)
        Assert-True ($er1 -is [System.Management.Automation.ErrorRecord])
        Assert-True ($er1.FullyQualifiedErrorId.Equals('PipelineArgumentOnly,Assert-PipelineSingle', [System.StringComparison]::OrdinalIgnoreCase))
    }
}

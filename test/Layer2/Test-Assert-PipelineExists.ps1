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
$emptyCollections = @(
    @(), [System.Int32[]]@(), [System.String[]]@(), @{},
    (New-Object -TypeName 'System.Collections.ArrayList'),
    (New-Object -TypeName 'System.Collections.Generic.List[System.String]'),
    (New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary')
)

& {
    Write-Verbose -Message 'Test Assert-PipelineExists with get-help -full' -Verbose:$headerVerbosity

    $err = try {$fullHelp = Get-Help Assert-PipelineExists -Full} catch {$_}

    Assert-Null $err
    Assert-True ($fullHelp.Name -is [System.String])
    Assert-True ($fullHelp.Name.Equals('Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($fullHelp.description -is [System.Collections.ICollection])
    Assert-True ($fullHelp.description.Count -gt 0)
    Assert-NotNull $fullHelp.examples
    Assert-True (0 -lt @($fullHelp.examples.example).Count)
    Assert-True ('' -ne @($fullHelp.examples.example)[0].code)
}

& {
    Write-Verbose -Message 'Test Assert-PipelineExists parameters' -Verbose:$headerVerbosity

    $paramSets = @((Get-Command -Name Assert-PipelineExists).ParameterSets)
    Assert-True (1 -eq $paramSets.Count)

    $inputObject = $paramSets[0].Parameters |
        Where-Object {'InputObject'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
    Assert-NotNull $inputObject

    $predicateParam = $paramSets[0].Parameters |
        Where-Object {'Predicate'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
    Assert-NotNull $predicateParam

    Assert-True ($inputObject.IsMandatory)
    Assert-True ($inputObject.ParameterType -eq [System.Object])
    Assert-True ($inputObject.ValueFromPipeline)
    Assert-False ($inputObject.ValueFromPipelineByPropertyName)
    Assert-False ($inputObject.ValueFromRemainingArguments)
    Assert-True (0 -gt $inputObject.Position)
    Assert-True (0 -eq $inputObject.Aliases.Count)

    Assert-True ($predicateParam.IsMandatory)
    Assert-False ($predicateParam.ValueFromPipeline)
    Assert-False ($predicateParam.ValueFromPipelineByPropertyName)
    Assert-False ($predicateParam.ValueFromRemainingArguments)
    Assert-True (0 -eq $predicateParam.Position)
    Assert-True (0 -eq $predicateParam.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Assert-PipelineExists with empty pipelines' -Verbose:$headerVerbosity

    foreach ($emptyCollection in $emptyCollections) {
        $out1 = New-Object -TypeName 'System.Collections.ArrayList'
        $out2 = New-Object -TypeName 'System.Collections.ArrayList'
        $out3 = New-Object -TypeName 'System.Collections.ArrayList'
        $out4 = New-Object -TypeName 'System.Collections.ArrayList'

        $er1 = try {$emptyCollection.GetEnumerator() | Assert-PipelineExists {$true} -OutVariable out1 | Out-Null} catch {$_}
        $er2 = try {$emptyCollection.GetEnumerator() | Assert-PipelineExists {$false} -OutVariable out2 | Out-Null} catch {$_}
        $er3 = try {$emptyCollection.GetEnumerator() | Assert-PipelineExists {param($a) ,$a} -OutVariable out3 | Out-Null} catch {$_}
        $er4 = try {$emptyCollection.GetEnumerator() | Assert-PipelineExists {throw 'Bad predicate'} -OutVariable out4 | Out-Null} catch {$_}

        Assert-True ($out1.Count -eq 0)
        Assert-True ($out2.Count -eq 0)
        Assert-True ($out3.Count -eq 0)
        Assert-True ($out4.Count -eq 0)

        Assert-True ($er1 -is [System.Management.Automation.ErrorRecord])
        Assert-True ($er2 -is [System.Management.Automation.ErrorRecord])
        Assert-True ($er3 -is [System.Management.Automation.ErrorRecord])
        Assert-True ($er4 -is [System.Management.Automation.ErrorRecord])

        Assert-True ($er1.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($er2.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($er3.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($er4.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
    }
}

& {
    Write-Verbose -Message 'Test Assert-PipelineExists with non-pipeline input' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $out3 = New-Object -TypeName 'System.Collections.ArrayList'

    $er1 = try {Assert-PipelineExists -InputObject @(1..10) {$true} -OutVariable out1 | Out-Null} catch {$_}
    $er2 = try {Assert-PipelineExists -InputObject @(1..10) {$false} -OutVariable out2 | Out-Null} catch {$_}
    $er3 = try {Assert-PipelineExists -InputObject @(1..10) {param($a) ,$a} -OutVariable out3 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 0)
    Assert-True ($out2.Count -eq 0)
    Assert-True ($out3.Count -eq 0)

    Assert-True ($er1 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er2 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er3 -is [System.Management.Automation.ErrorRecord])

    Assert-True ($er1.FullyQualifiedErrorId.Equals('PipelineArgumentOnly,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er2.FullyQualifiedErrorId.Equals('PipelineArgumentOnly,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er3.FullyQualifiedErrorId.Equals('PipelineArgumentOnly,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))

    Assert-True ($er1.Exception -is [System.ArgumentException])
    Assert-True ($er2.Exception -is [System.ArgumentException])
    Assert-True ($er3.Exception -is [System.ArgumentException])

    Assert-True ($er1.Exception.ParamName.Equals('InputObject', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er2.Exception.ParamName.Equals('InputObject', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er3.Exception.ParamName.Equals('InputObject', [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Assert-PipelineExists with $null predicate' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $out3 = New-Object -TypeName 'System.Collections.ArrayList'

    $er1 = try {@() | Assert-PipelineExists $null -OutVariable out1 | Out-Null} catch {$_}
    $er2 = try {@(1) | Assert-PipelineExists $null -OutVariable out2 | Out-Null} catch {$_}
    $er3 = try {@('a', 'b') | Assert-PipelineExists $null -OutVariable out3 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 0)
    Assert-True ($out2.Count -eq 0)
    Assert-True ($out3.Count -eq 0)

    Assert-True ($er1 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er2 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er3 -is [System.Management.Automation.ErrorRecord])

    Assert-True ($er1.FullyQualifiedErrorId.Equals('ParameterArgumentValidationErrorNullNotAllowed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er2.FullyQualifiedErrorId.Equals('ParameterArgumentValidationErrorNullNotAllowed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er3.FullyQualifiedErrorId.Equals('ParameterArgumentValidationErrorNullNotAllowed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))

    Assert-True ($er1.Exception.ParameterName.Equals('Predicate', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er2.Exception.ParameterName.Equals('Predicate', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er3.Exception.ParameterName.Equals('Predicate', [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Assert-PipelineExists with predicate that throws an error' -Verbose:$headerVerbosity

    $items = @('1', '2', '3')

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $out3 = New-Object -TypeName 'System.Collections.ArrayList'
    $out4 = New-Object -TypeName 'System.Collections.ArrayList'

    $er1 = try {$items | Assert-PipelineExists {param($a) if ($a -eq '1') {throw 'Bad predicate 1'} else {$false}} -OutVariable out1 | Out-Null} catch {$_}
    $er2 = try {$items | Assert-PipelineExists {param($a) if ($a -eq '2') {throw 'Bad predicate 2'} else {$false}} -OutVariable out2 | Out-Null} catch {$_}
    $er3 = try {$items | Assert-PipelineExists {param($a) if ($a -eq '3') {throw 'Bad predicate 3'} else {$false}} -OutVariable out3 | Out-Null} catch {$_}
    $er4 = try {$items | Assert-PipelineExists {param($a) if ($a -eq '4') {throw 'Bad predicate 4'} else {$false}} -OutVariable out4 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 0)
    Assert-True ($out2.Count -eq 1)
    Assert-True ([System.Object]::ReferenceEquals($out2[0], $items[0]))
    Assert-True ($out3.Count -eq 2)
    Assert-True ([System.Object]::ReferenceEquals($out3[0], $items[0]))
    Assert-True ([System.Object]::ReferenceEquals($out3[1], $items[1]))
    Assert-True ($out4.Count -eq 3)
    Assert-True ([System.Object]::ReferenceEquals($out4[0], $items[0]))
    Assert-True ([System.Object]::ReferenceEquals($out4[1], $items[1]))
    Assert-True ([System.Object]::ReferenceEquals($out4[2], $items[2]))

    Assert-True ($er1 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er2 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er3 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er4 -is [System.Management.Automation.ErrorRecord])

    Assert-True ($er1.FullyQualifiedErrorId.Equals('PredicateFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er2.FullyQualifiedErrorId.Equals('PredicateFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er3.FullyQualifiedErrorId.Equals('PredicateFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er4.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))

    Assert-True ($er1.Exception -is [System.InvalidOperationException])
    Assert-True ($er2.Exception -is [System.InvalidOperationException])
    Assert-True ($er3.Exception -is [System.InvalidOperationException])

    Assert-NotNull ($er1.Exception.InnerException)
    Assert-NotNull ($er2.Exception.InnerException)
    Assert-NotNull ($er3.Exception.InnerException)

    Assert-True ($er1.Exception.InnerException.Message.Equals('Bad predicate 1', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er2.Exception.InnerException.Message.Equals('Bad predicate 2', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er3.Exception.InnerException.Message.Equals('Bad predicate 3', [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Assert-PipelineExists with collections containing $null' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $out3 = New-Object -TypeName 'System.Collections.ArrayList'

    $er1 = try {@($null) | Assert-PipelineExists {param($a) $null -eq $a} -OutVariable out1 | Out-Null} catch {$_}
    $er2 = try {@(1, $null) | Assert-PipelineExists {param($a) $null -eq $a} -OutVariable out2 | Out-Null} catch {$_}
    $er3 = try {@('a', 'b', $null, 'c') | Assert-PipelineExists {param($a) $null -eq $a} -OutVariable out3 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 1)
    Assert-True ($null -eq $out1[0])
    Assert-True ($out2.Count -eq 2)
    Assert-True (1     -eq $out2[0])
    Assert-True ($null -eq $out2[1])
    Assert-True ($out3.Count -eq 4)
    Assert-True ('a'   -eq $out3[0])
    Assert-True ('b'   -eq $out3[1])
    Assert-True ($null -eq $out3[2])
    Assert-True ('c'   -eq $out3[3])

    Assert-Null $er1
    Assert-Null $er2
    Assert-Null $er3
}

& {
    Write-Verbose -Message 'Test $null | Assert-PipelineExists  {param($a) ,$a}' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {$null | Assert-PipelineExists {param($a) ,$a} -OutVariable out1 | Out-Null} catch {$_}
    Assert-True ($out1.Count -eq 1)
    Assert-Null $out1[0]
    Assert-True ($er1 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er1.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test $true | Assert-PipelineExists {param($a) ,$a}' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {$true | Assert-PipelineExists {param($a) ,$a} -OutVariable out1 | Out-Null} catch {$_}
    Assert-True ($out1.Count -eq 1)
    Assert-True $out1[0]
    Assert-Null $er1
}

& {
    Write-Verbose -Message 'Test $false | Assert-PipelineExists {param($a) ,$a}' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {$false | Assert-PipelineExists {param($a) ,$a} -OutVariable out1 | Out-Null} catch {$_}
    Assert-True ($out1.Count -eq 1)
    Assert-False $out1[0]
    Assert-True ($er1 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er1.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test @(,$nonBooleanTrue) | Assert-PipelineExists {param($a) ,$a}' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanTrue) {
        $collection = @(,$item)
        Assert-True ($collection.Count -eq 1)

        $out1 = New-Object -TypeName 'System.Collections.ArrayList'
        $er1 = try {$collection | Assert-PipelineExists {param($a) ,$a} -OutVariable out1 | Out-Null} catch {$_}
        Assert-True ($out1.Count -eq 1)
        Assert-True ([System.Object]::Equals($collection[0], $out1[0]))
        Assert-True ($er1 -is [System.Management.Automation.ErrorRecord])
        Assert-True ($er1.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
    }
}

& {
    Write-Verbose -Message 'Test @(,$nonBooleanFalse) | Assert-PipelineExists {param($a) ,$a}' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanFalse) {
        $collection = @(,$item)
        Assert-True ($collection.Count -eq 1)

        $out1 = New-Object -TypeName 'System.Collections.ArrayList'
        $er1 = try {$collection | Assert-PipelineExists {param($a) ,$a} -OutVariable out1 | Out-Null} catch {$_}
        Assert-True ($out1.Count -eq 1)
        Assert-True ([System.Object]::Equals($collection[0], $out1[0]))
        Assert-True ($er1 -is [System.Management.Automation.ErrorRecord])
        Assert-True ($er1.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
    }
}

& {
    Write-Verbose -Message 'Test Assert-PipelineExists early pass' -Verbose:$headerVerbosity

    $dictionary = New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary'
    $dictionary.Add('a', 1)
    $dictionary.Add('b', 2)
    $dictionary.Add('c', 3)
    $dictionary.Add('d', 4)
    $dictionary.Add('e', 5)

    foreach ($i in @(1..5)) {
        $numPredicateCalls = 0
        $predicate = {
            param($entry)

            $numPredicateCalls = Get-Variable -Name 'numPredicateCalls' -Scope 1
            $numPredicateCalls.Value = $numPredicateCalls.Value + 1

            return $entry.Value -eq $i
        }

        $out1 = New-Object -TypeName 'System.Collections.ArrayList'
        $er1 = try {$dictionary.GetEnumerator() | Assert-PipelineExists $predicate -OutVariable out1 | Out-Null} catch {$_}

        Assert-True ($out1.Count -eq 5)
        Assert-Null $er1

        Assert-True ($i -eq $numPredicateCalls)
    }
}

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
    Write-Verbose -Message 'Test Test-Exists with get-help -full' -Verbose:$headerVerbosity

    $err = try {$fullHelp = Get-Help Test-Exists -Full} catch {$_}

    Assert-Null $err
    Assert-True ($fullHelp.Name -is [System.String])
    Assert-True ($fullHelp.Name.Equals('Test-Exists', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($fullHelp.description -is [System.Collections.ICollection])
    Assert-True ($fullHelp.description.Count -gt 0)
    Assert-NotNull $fullHelp.examples
    Assert-True (0 -lt @($fullHelp.examples.example).Count)
    Assert-True ('' -ne @($fullHelp.examples.example)[0].code)
}

& {
    Write-Verbose -Message 'Test Test-Exists parameters' -Verbose:$headerVerbosity

    $paramSets = @((Get-Command -Name Test-Exists).ParameterSets)
    Assert-True (1 -eq $paramSets.Count)

    $collectionParam = $paramSets[0].Parameters |
        Where-Object {'Collection'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
    Assert-NotNull $collectionParam

    $predicateParam = $paramSets[0].Parameters |
        Where-Object {'Predicate'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
    Assert-NotNull $predicateParam

    Assert-True ($collectionParam.IsMandatory)
    Assert-True ($collectionParam.ParameterType -eq [System.Object])
    Assert-False ($collectionParam.ValueFromPipeline)
    Assert-False ($collectionParam.ValueFromPipelineByPropertyName)
    Assert-False ($collectionParam.ValueFromRemainingArguments)
    Assert-True (0 -eq $collectionParam.Position)
    Assert-True (0 -eq $collectionParam.Aliases.Count)

    Assert-True ($predicateParam.IsMandatory)
    Assert-True ($predicateParam.ParameterType -eq [System.Management.Automation.ScriptBlock])
    Assert-False ($predicateParam.ValueFromPipeline)
    Assert-False ($predicateParam.ValueFromPipelineByPropertyName)
    Assert-False ($predicateParam.ValueFromRemainingArguments)
    Assert-True (1 -eq $predicateParam.Position)
    Assert-True (0 -eq $predicateParam.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Test-Exists with empty collections' -Verbose:$headerVerbosity

    foreach ($emptyCollection in $emptyCollections) {
        $out1 = New-Object -TypeName 'System.Collections.ArrayList'
        $out2 = New-Object -TypeName 'System.Collections.ArrayList'
        $out3 = New-Object -TypeName 'System.Collections.ArrayList'
        $out4 = New-Object -TypeName 'System.Collections.ArrayList'

        $er1 = try {Test-Exists $emptyCollection {$true} -OutVariable out1 | Out-Null} catch {$_}
        $er2 = try {Test-Exists $emptyCollection {$false} -OutVariable out2 | Out-Null} catch {$_}
        $er3 = try {Test-Exists $emptyCollection {param($a) ,$a} -OutVariable out3 | Out-Null} catch {$_}
        $er4 = try {Test-Exists $emptyCollection {throw 'Bad predicate'} -OutVariable out4 | Out-Null} catch {$_}

        Assert-True ($out1.Count -eq 1)
        Assert-True ($out2.Count -eq 1)
        Assert-True ($out3.Count -eq 1)
        Assert-True ($out4.Count -eq 1)

        Assert-False ($out1[0])
        Assert-False ($out2[0])
        Assert-False ($out3[0])
        Assert-False ($out4[0])

        Assert-Null ($er1)
        Assert-Null ($er2)
        Assert-Null ($er3)
        Assert-Null ($er4)
    }
}

& {
    Write-Verbose -Message 'Test Test-Exists with $null collection' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $out3 = New-Object -TypeName 'System.Collections.ArrayList'

    $er1 = try {Test-Exists $null {$true} -OutVariable out1 | Out-Null} catch {$_}
    $er2 = try {Test-Exists $null {$false} -OutVariable out2 | Out-Null} catch {$_}
    $er3 = try {Test-Exists $null {param($a) ,$a} -OutVariable out3 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 1)
    Assert-True ($out2.Count -eq 1)
    Assert-True ($out3.Count -eq 1)

    Assert-Null ($out1[0])
    Assert-Null ($out2[0])
    Assert-Null ($out3[0])

    Assert-Null ($er1)
    Assert-Null ($er2)
    Assert-Null ($er3)
}

& {
    Write-Verbose -Message 'Test Test-Exists with non-collection' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $out3 = New-Object -TypeName 'System.Collections.ArrayList'

    $er1 = try {Test-Exists 1 {$true} -OutVariable out1 | Out-Null} catch {$_}
    $er2 = try {Test-Exists 'hi' {$true} -OutVariable out2 | Out-Null} catch {$_}
    $er3 = try {Test-Exists ([System.DateTime]::Now) {$true} -OutVariable out3 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 1)
    Assert-True ($out2.Count -eq 1)
    Assert-True ($out3.Count -eq 1)

    Assert-Null ($out1[0])
    Assert-Null ($out2[0])
    Assert-Null ($out3[0])

    Assert-Null ($er1)
    Assert-Null ($er2)
    Assert-Null ($er3)
}

& {
    Write-Verbose -Message 'Test Test-Exists with $null predicate' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $out3 = New-Object -TypeName 'System.Collections.ArrayList'

    $er1 = try {Test-Exists @() $null -OutVariable out1 | Out-Null} catch {$_}
    $er2 = try {Test-Exists @(1) $null -OutVariable out2 | Out-Null} catch {$_}
    $er3 = try {Test-Exists @('a', 'b') $null -OutVariable out3 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 0)
    Assert-True ($out2.Count -eq 0)
    Assert-True ($out3.Count -eq 0)

    Assert-True ($er1 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er2 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er3 -is [System.Management.Automation.ErrorRecord])

    Assert-True ($er1.FullyQualifiedErrorId.Equals('ParameterArgumentValidationErrorNullNotAllowed,Test-Exists', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er2.FullyQualifiedErrorId.Equals('ParameterArgumentValidationErrorNullNotAllowed,Test-Exists', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er3.FullyQualifiedErrorId.Equals('ParameterArgumentValidationErrorNullNotAllowed,Test-Exists', [System.StringComparison]::OrdinalIgnoreCase))

    Assert-True ($er1.Exception.ParameterName.Equals('Predicate', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er2.Exception.ParameterName.Equals('Predicate', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er3.Exception.ParameterName.Equals('Predicate', [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Exists with predicate that throws an error' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $out3 = New-Object -TypeName 'System.Collections.ArrayList'
    $out4 = New-Object -TypeName 'System.Collections.ArrayList'

    $er1 = try {Test-Exists @(1, 2, 3) {param($a) if ($a -ge 1) {throw 'Bad predicate 1'} else {$false}} -OutVariable out1 | Out-Null} catch {$_}
    $er2 = try {Test-Exists @(1, 2, 3) {param($a) if ($a -ge 2) {throw 'Bad predicate 2'} else {$false}} -OutVariable out2 | Out-Null} catch {$_}
    $er3 = try {Test-Exists @(1, 2, 3) {param($a) if ($a -ge 3) {throw 'Bad predicate 3'} else {$false}} -OutVariable out3 | Out-Null} catch {$_}
    $er4 = try {Test-Exists @(1, 2, 3) {param($a) if ($a -ge 4) {throw 'Bad predicate 4'} else {$false}} -OutVariable out4 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 0)
    Assert-True ($out2.Count -eq 0)
    Assert-True ($out3.Count -eq 0)
    Assert-True ($out4.Count -eq 1)

    Assert-False ($out4[0])

    Assert-True ($er1 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er2 -is [System.Management.Automation.ErrorRecord])
    Assert-True ($er3 -is [System.Management.Automation.ErrorRecord])
    Assert-Null ($er4)

    Assert-True ($er1.FullyQualifiedErrorId.Equals('PredicateFailed,Test-Exists', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er2.FullyQualifiedErrorId.Equals('PredicateFailed,Test-Exists', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($er3.FullyQualifiedErrorId.Equals('PredicateFailed,Test-Exists', [System.StringComparison]::OrdinalIgnoreCase))

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
    Write-Verbose -Message 'Test Test-Exists with collections containing $null' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $out3 = New-Object -TypeName 'System.Collections.ArrayList'

    $er1 = try {Test-Exists @($null) {param($a) $null -eq $a} -OutVariable out1 | Out-Null} catch {$_}
    $er2 = try {Test-Exists @(1, $null) {param($a) $null -eq $a} -OutVariable out2 | Out-Null} catch {$_}
    $er3 = try {Test-Exists @('a', 'b', $null, 'c') {param($a) $null -eq $a} -OutVariable out3 | Out-Null} catch {$_}

    Assert-True ($out1.Count -eq 1)
    Assert-True ($out2.Count -eq 1)
    Assert-True ($out3.Count -eq 1)

    Assert-True ($out1[0])
    Assert-True ($out2[0])
    Assert-True ($out3[0])

    Assert-Null $er1
    Assert-Null $er2
    Assert-Null $er3
}

& {
    Write-Verbose -Message 'Test Test-Exists @(,$null) {param($a) ,$a}' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {Test-Exists @(,$null) {param($a) ,$a} -OutVariable out1 | Out-Null} catch {$_}
    Assert-True ($out1.Count -eq 1)
    Assert-False ($out1[0])
    Assert-Null ($er1)
}

& {
    Write-Verbose -Message 'Test Test-Exists @(,$true) {param($a) ,$a}' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {Test-Exists @(,$true) {param($a) ,$a} -OutVariable out1 | Out-Null} catch {$_}
    Assert-True ($out1.Count -eq 1)
    Assert-True ($out1[0])
    Assert-Null $er1
}

& {
    Write-Verbose -Message 'Test Test-Exists @(,$false) {param($a) ,$a}' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {Test-Exists @(,$false) {param($a) ,$a} -OutVariable out1 | Out-Null} catch {$_}
    Assert-True ($out1.Count -eq 1)
    Assert-False ($out1[0])
    Assert-Null ($er1)
}

& {
    Write-Verbose -Message 'Test Test-Exists @(,$nonBooleanTrue) {param($a) ,$a}' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanTrue) {
        $collection = @(,$item)
        Assert-True ($collection.Count -eq 1)

        $out1 = New-Object -TypeName 'System.Collections.ArrayList'
        $er1 = try {Test-Exists $collection {param($a) ,$a} -OutVariable out1 | Out-Null} catch {$_}
        Assert-True ($out1.Count -eq 1)
        Assert-False ($out1[0])
        Assert-Null ($er1)
    }
}

& {
    Write-Verbose -Message 'Test Test-Exists @(,$nonBooleanFalse) {param($a) ,$a}' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanFalse) {
        $collection = @(,$item)
        Assert-True ($collection.Count -eq 1)

        $out1 = New-Object -TypeName 'System.Collections.ArrayList'
        $er1 = try {Test-Exists $collection {param($a) ,$a} -OutVariable out1 | Out-Null} catch {$_}
        Assert-True ($out1.Count -eq 1)
        Assert-False ($out1[0])
        Assert-Null ($er1)
    }
}

& {
    Write-Verbose -Message 'Test Test-Exists early pass' -Verbose:$headerVerbosity

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
        $er1 = try {Test-Exists $dictionary $predicate -OutVariable out1 | Out-Null} catch {$_}

        Assert-True ($out1.Count -eq 1)
        Assert-True ($out1[0])
        Assert-Null $er1

        Assert-True ($i -eq $numPredicateCalls)
    }
}
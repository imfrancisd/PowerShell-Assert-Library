#requires -version 2

<#
.Synopsis
Test the Assert-PipelineExists cmdlet.
.Description
Test the Assert-PipelineExists cmdlet.
.Inputs
None
.Outputs
None
.Notes
=====================================================================


#Use an ArrayList as a logger.
#The log entries will be in $simpleLogger.
#
$simpleLogger = new-object -typename system.collections.arraylist
.\Test-Assert-PipelineExists.ps1 -logger $simpleLogger


=====================================================================


#Use a custom object as a logger.
#The log entries will be in $customLogger.Entries.
#
$customLogger = new-object -typename psobject -property @{
    Entries = new-object -typename system.collections.arraylist
} |
add-member scriptmethod Add {
    param($logEntry)

    #Add entry.
    $this.Entries.Add($logEntry) | out-null

    #Limit the number of entries in the logger to 10.
    if ($this.Entries.Count -gt 10) {
        $this.Entries.RemoveAt(0)
    }
} -passthru
.\Test-Assert-PipelineExists.ps1 -logger $customLogger


=====================================================================


Log Entry Structure
===================
All log entries will have the same structure.
A log entry will not change after it is added to the logger.

[pscustomobject]@{
    File = #String (full path)
    Test = #String (test description)
    Pass = #Boolean (test result, $null if inconclusive)
    Data = @{
        err = #ErrorRecord from command that takes in and creates out
        out = #IList (generated from -OutVariable parameter)
        in  = #IDictionary (for parameter names/values
              #list of args, if any, will be in entry with key '')
    }
    Time = @{
        start = #DateTime UTC (test log entry creation time)
        stop  = #DateTime UTC (test log entry log time)
        span  = #TimeSpan (test duration)
    }
}


=====================================================================
#>
[CmdletBinding()]
Param(
    #A data structure with an "Add" method that will be used to log tests.
    #
    #The data structure can be a simple ArrayList or a complicated custom object.
    #The advantage of using a custom object is that you have full control over the logging behavior such as limiting the number of log entries.
    #
    #See the Notes section for more details and examples.
    $Logger = $null,

    #Suppress all verbose messages.
    #
    #The default is to suppress some verbose messages.
    #Use the -Verbose switch (and turn off this switch) to display all verbose messages.
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



$TestScriptFilePath = $MyInvocation.MyCommand.Path
$TestScriptStopWatch = New-Object -TypeName 'System.Diagnostics.Stopwatch'

function newTestLogEntry
{
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $testDescription
    )

    if ([System.Int32]$headerVerbosity) {
        $VerbosePreference = $headerVerbosity
        Write-Verbose -Message $testDescription
    }

    $logEntry = New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
        File = $TestScriptFilePath
        Test = $testDescription
        Pass = $null
        Data = @{err = $null; out = $null; in = $null;}
        Time = @{start = [System.DateTime]::UtcNow; stop = $null; span = $null;}
    }

    $TestScriptStopWatch.Reset()
    $TestScriptStopWatch.Start()
    return $logEntry
}

function commitTestLogEntry
{
    param(
        [parameter(Mandatory = $true)]
        $logEntry,
        
        [parameter(Mandatory = $false)]
        [System.Boolean]
        $pass
    )

    $logEntry.Pass = if ($PSBoundParameters.ContainsKey('pass')) {$pass} else {$null}
    $TestScriptStopWatch.Stop()
    $logEntry.Time.span = $TestScriptStopWatch.Elapsed
    $logEntry.Time.stop = [System.DateTime]::UtcNow

    if ($null -ne $Logger) {
        [System.Void]$Logger.Add($logEntry)
    }
}



$nonBooleanFalse = @(
    0, '', @($null), @(0), @(''), @($false), @(), @(,@())
)
$nonBooleanTrue = @(
    1, 'True', 'False', @(1), @('True'), @('False'), @($true), @(,@(1)), @(,@($true))
)
$nonCollections = @(
    $true, $false, $null, 0, 1, 'hi', ([System.DateTime]::Now)
)
$predicates = @{
    True     = {param($a) $true}
    False    = {param($a) $false}
    Identity = {param($a) ,$a}
    Error    = {param($a) throw 'Error predicate'}
}



& {
    $test = newTestLogEntry 'Assert-PipelineExists help'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{name = 'Assert-PipelineExists'}
        $test.Data.err = try {Get-Help -Name $test.Data.in.name -Full -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err
        Assert-True ($test.Data.out.Count -eq 1)
        Assert-True ($test.Data.out[0].Name -is [System.String])
        Assert-True ($test.Data.out[0].Name.Equals('Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out[0].description -is [System.Collections.ICollection])
        Assert-True ($test.Data.out[0].description.Count -gt 0)
        Assert-NotNull $test.Data.out[0].examples
        Assert-True (0 -lt @($test.Data.out[0].examples.example).Count)
        Assert-True ('' -ne @($test.Data.out[0].examples.example)[0].code)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-PipelineExists parameters'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{name = 'Assert-PipelineExists'}
        $test.Data.err = try {Get-Command -Name $test.Data.in.name -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err

        $paramSets = @($test.Data.out[0].ParameterSets)
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
        Assert-True ($predicateParam.ParameterType -eq [System.Management.Automation.ScriptBlock])
        Assert-False ($predicateParam.ValueFromPipeline)
        Assert-False ($predicateParam.ValueFromPipelineByPropertyName)
        Assert-False ($predicateParam.ValueFromRemainingArguments)
        Assert-True (0 -eq $predicateParam.Position)
        Assert-True (0 -eq $predicateParam.Aliases.Count)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $testDescription = 'Assert-PipelineExists with non-pipeline input'
    $predicates = @($predicates.psbase.Values)

    for ($i = 0; $i -lt $predicates.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @(1..3); predicate = $predicates[$i];}
            $test.Data.err = try {Assert-PipelineExists -InputObject $test.Data.in.inputObject $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
            Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('PipelineArgumentOnly,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
            Assert-True ($test.Data.out.Count -eq 0)

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }

    if ($i -eq 0) {
        commitTestLogEntry (newTestLogEntry $testDescription)
        throw New-Object 'System.Exception' -ArgumentList @("No data for $testDescription")
    }
}

& {
    $testDescription = 'Assert-PipelineExists with null predicate'
    $collections = @($null, @(), @(1), @('is the', 'loneliest number'), @("three's", 'company', 'too'))

    for ($i = 0; $i -lt $collections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @($collections[$i]); predicate = $null;}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineExists $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
            Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('ParameterArgumentValidationErrorNullNotAllowed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
            Assert-True ($test.Data.err.Exception.ParameterName.Equals('Predicate', [System.StringComparison]::OrdinalIgnoreCase))
            Assert-True ($test.Data.out.Count -eq 0)

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }

    if ($i -eq 0) {
        commitTestLogEntry (newTestLogEntry $testDescription)
        throw New-Object 'System.Exception' -ArgumentList @("No data for $testDescription")
    }
}

& {
    $testDescription = 'Assert-PipelineExists with pipeline containing nothing'
    $predicates = @($predicates.psbase.Values)

    for ($i = 0; $i -lt $predicates.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @(); predicate = $predicates[$i];}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineExists $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
            Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
            Assert-True ($test.Data.out.Count -eq 0)

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }

    if ($i -eq 0) {
        commitTestLogEntry (newTestLogEntry $testDescription)
        throw New-Object 'System.Exception' -ArgumentList @("No data for $testDescription")
    }
}

& {
    $testDescription = 'Assert-PipelineExists with pipeline containing scalar and true predicate'

    for ($i = 0; $i -lt $nonCollections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @($nonCollections[$i]); predicate = $predicates.True;}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineExists $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null ($test.Data.err)
            Assert-True ($test.Data.out.Count -eq 1)
            Assert-True ($test.Data.in.inputObject[0] -eq $test.Data.out[0])

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }

    if ($i -eq 0) {
        commitTestLogEntry (newTestLogEntry $testDescription)
        throw New-Object 'System.Exception' -ArgumentList @("No data for $testDescription")
    }
}

& {
    $testDescription = 'Assert-PipelineExists with pipeline containing scalar and false predicate'

    for ($i = 0; $i -lt $nonCollections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @($nonCollections[$i]); predicate = $predicates.False;}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineExists $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
            Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
            Assert-True ($test.Data.out.Count -eq 1)
            Assert-True ($test.Data.in.inputObject[0] -eq $test.Data.out[0])

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }

    if ($i -eq 0) {
        commitTestLogEntry (newTestLogEntry $testDescription)
        throw New-Object 'System.Exception' -ArgumentList @("No data for $testDescription")
    }
}

& {
    $testDescription = 'Assert-PipelineExists with pipeline containing scalar and identity predicate'

    for ($i = 0; $i -lt $nonCollections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @($nonCollections[$i]); predicate = $predicates.Identity;}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineExists $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            if (Test-True $test.Data.in.inputObject[0]) {
                Assert-Null ($test.Data.err)
            } else {
                Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
            }
            Assert-True ($test.Data.out.Count -eq 1)
            Assert-True ($test.Data.in.inputObject[0] -eq $test.Data.out[0])

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }

    if ($i -eq 0) {
        commitTestLogEntry (newTestLogEntry $testDescription)
        throw New-Object 'System.Exception' -ArgumentList @("No data for $testDescription")
    }
}

& {
    $testDescription = 'Assert-PipelineExists with pipeline containing scalar and error predicate'

    for ($i = 0; $i -lt $nonCollections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @($nonCollections[$i]); predicate = $predicates.Error;}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineExists $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
            Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('PredicateFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
            Assert-True ($test.Data.out.Count -eq 0)

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }

    if ($i -eq 0) {
        commitTestLogEntry (newTestLogEntry $testDescription)
        throw New-Object 'System.Exception' -ArgumentList @("No data for $testDescription")
    }
}

& {
    $testDescription = 'Assert-PipelineExists with pipeline containing Non-Boolean that is convertible to $true'

    for ($i = 0; $i -lt $nonBooleanTrue.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @(,$nonBooleanTrue[$i]); predicate = $predicates.Identity;}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineExists $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
            Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
            Assert-True ($test.Data.out.Count -eq 1)
            Assert-True ($test.Data.in.inputObject[0].Equals($test.Data.out[0]))

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }

    if ($i -eq 0) {
        commitTestLogEntry (newTestLogEntry $testDescription)
        throw New-Object 'System.Exception' -ArgumentList @("No data for $testDescription")
    }
}

& {
    $testDescription = 'Assert-PipelineExists with pipeline containing Non-Boolean that is convertible to $false'

    for ($i = 0; $i -lt $nonBooleanFalse.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @(,$nonBooleanFalse[$i]); predicate = $predicates.Identity;}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineExists $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
            Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
            Assert-True ($test.Data.out.Count -eq 1)
            Assert-True ($test.Data.in.inputObject[0].Equals($test.Data.out[0]))

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }

    if ($i -eq 0) {
        commitTestLogEntry (newTestLogEntry $testDescription)
        throw New-Object 'System.Exception' -ArgumentList @("No data for $testDescription")
    }
}

& {
    $testDescription = 'Assert-PipelineExists with pipeline containing multiple items'

    $items = @(
        'hello', 0, 1.0, $true, $false, @(), @('hi', $null, 'world'), @{}, (New-Object -TypeName 'System.Collections.ArrayList')
    )

    for ($i = 0; $i -lt $items.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @($items[0..$i]); predicate = $predicates.False;}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineExists $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
            Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
            Assert-True ($test.Data.out.Count -eq $test.Data.in.inputObject.Count)
            Assert-All @(0..$i) {param($index) $test.Data.in.inputObject[$index].Equals($test.Data.out[$index])}

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }

    if ($i -eq 0) {
        commitTestLogEntry (newTestLogEntry $testDescription)
        throw New-Object 'System.Exception' -ArgumentList @("No data for $testDescription")
    }
}

& {
    $test = newTestLogEntry 'Assert-PipelineExists with a predicate that throws on the first element'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{inputObject = @(1, 2, 3, 4); predicate = {param($a) if ($a -eq 1) {throw "Bad predicate $a"} else {$false}};}
        $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineExists $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('PredicateFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.err.Exception -is [System.InvalidOperationException])
        Assert-NotNull ($test.Data.err.Exception.InnerException)
        Assert-True ($test.Data.err.Exception.InnerException.Message.Equals('Bad predicate 1', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-PipelineExists with a predicate that throws on the second element'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{inputObject = @(1, 2, 3, 4); predicate = {param($a) if ($a -eq 2) {throw "Bad predicate $a"} else {$false}};}
        $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineExists $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('PredicateFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.err.Exception -is [System.InvalidOperationException])
        Assert-NotNull ($test.Data.err.Exception.InnerException)
        Assert-True ($test.Data.err.Exception.InnerException.Message.Equals('Bad predicate 2', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 1)
        Assert-All @(0..0) {param($index) $test.Data.in.inputObject[$index].Equals($test.Data.out[$index])}

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-PipelineExists with a predicate that throws on the third element'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{inputObject = @(1, 2, 3, 4); predicate = {param($a) if ($a -eq 3) {throw "Bad predicate $a"} else {$false}};}
        $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineExists $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('PredicateFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.err.Exception -is [System.InvalidOperationException])
        Assert-NotNull ($test.Data.err.Exception.InnerException)
        Assert-True ($test.Data.err.Exception.InnerException.Message.Equals('Bad predicate 3', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 2)
        Assert-All @(0..1) {param($index) $test.Data.in.inputObject[$index].Equals($test.Data.out[$index])}

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-PipelineExists with a predicate that throws on the fourth element'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{inputObject = @(1, 2, 3, 4); predicate = {param($a) if ($a -eq 4) {throw "Bad predicate $a"} else {$false}};}
        $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineExists $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('PredicateFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.err.Exception -is [System.InvalidOperationException])
        Assert-NotNull ($test.Data.err.Exception.InnerException)
        Assert-True ($test.Data.err.Exception.InnerException.Message.Equals('Bad predicate 4', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 3)
        Assert-All @(0..2) {param($index) $test.Data.in.inputObject[$index].Equals($test.Data.out[$index])}

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-PipelineExists with a predicate that throws on the fifth element'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{inputObject = @(1, 2, 3, 4); predicate = {param($a) if ($a -eq 5) {throw "Bad predicate $a"} else {$false}};}
        $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineExists $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 4)
        Assert-All @(0..3) {param($index) $test.Data.in.inputObject[$index].Equals($test.Data.out[$index])}

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $dictionary = New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary'
    $dictionary.Add('a', 1)
    $dictionary.Add('b', 2)
    $dictionary.Add('c', 3)
    $dictionary.Add('d', 4)
    $dictionary.Add('e', 5)

    foreach ($i in @(1..5)) {
        $test = newTestLogEntry 'Assert-PipelineExists early pass'
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in = @{
                inputObject    = @($dictionary.GetEnumerator())
                expectedCalls  = $i
                remainingCalls = $i
                predicate = {
                    param($entry)

                    $test.Data.in.remainingCalls--
                    $entry.Value -eq $i
                }
            }
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineExists $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null ($test.Data.err)
            Assert-True ($test.Data.out.Count -eq 5)
            Assert-All @(0..4) {param($index) $test.Data.in.inputObject[$index].Equals($test.Data.out[$index])}
            Assert-True (0 -eq $test.Data.in.remainingCalls)

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }
}

& {
    $dictionary = New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary'
    $dictionary.Add('a', 1)
    $dictionary.Add('b', 2)
    $dictionary.Add('c', 3)
    $dictionary.Add('d', 4)
    $dictionary.Add('e', 5)

    $test = newTestLogEntry 'Assert-PipelineExists with a predicate that contains "break" outside of a loop'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in = @{
            inputObject    = @($dictionary.GetEnumerator())
            expectedCalls  = 5
            remainingCalls = 5
            predicate = {
                param($entry)

                $test.Data.in.remainingCalls--
                $false
                break
            }
        }

        do {
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineExists $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        } while ($false)

        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineExists', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 5)
        Assert-All @(0..4) {param($index) $test.Data.in.inputObject[$index].Equals($test.Data.out[$index])}
        Assert-True (0 -eq $test.Data.in.remainingCalls)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

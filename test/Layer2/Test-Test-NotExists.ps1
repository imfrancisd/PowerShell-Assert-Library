#requires -version 2

<#
.Synopsis
Test the Test-NotExists cmdlet.
.Description
Test the Test-NotExists cmdlet.
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
.\Test-Test-NotExists.ps1 -logger $simpleLogger


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
.\Test-Test-NotExists.ps1 -logger $customLogger


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
$emptyCollections = @(
    @(), [System.Int32[]]@(), [System.String[]]@(), @{},
    (New-Object -TypeName 'System.Collections.ArrayList'),
    (New-Object -TypeName 'System.Collections.Generic.List[System.String]'),
    (New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary')
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
    $test = newTestLogEntry 'Test-NotExists help'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{name = 'Test-NotExists'}
        $test.Data.err = try {Get-Help -Name $test.Data.in.name -Full -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err
        Assert-True ($test.Data.out.Count -eq 1)
        Assert-True ($test.Data.out[0].Name -is [System.String])
        Assert-True ($test.Data.out[0].Name.Equals('Test-NotExists', [System.StringComparison]::OrdinalIgnoreCase))
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
    $test = newTestLogEntry 'Test-NotExists parameters'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{name = 'Test-NotExists'}
        $test.Data.err = try {Get-Command -Name $test.Data.in.name -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err

        $paramSets = @($test.Data.out[0].ParameterSets)
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

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Test-NotExists with singleton containing $true'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{collection = @($true); predicate = $predicates.Identity;}
        $test.Data.err = try {Test-NotExists $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err
        Assert-True ($test.Data.out.Count -eq 1)
        Assert-False $test.Data.out[0]

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Test-NotExists with singleton containing $false'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{collection = @($false); predicate = $predicates.Identity;}
        $test.Data.err = try {Test-NotExists $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err
        Assert-True ($test.Data.out.Count -eq 1)
        Assert-True $test.Data.out[0]
        
        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Test-NotExists with singleton containing $null'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{collection = @($null); predicate = $predicates.Identity;}
        $test.Data.err = try {Test-NotExists $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err
        Assert-True ($test.Data.out.Count -eq 1)
        Assert-True $test.Data.out[0]

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $testDescription = 'Test-NotExists with singleton containing Non-Boolean that is convertible to $true'

    for ($i = 0; $i -lt $nonBooleanTrue.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = @(,$nonBooleanTrue[$i]); predicate = $predicates.Identity;}
            $test.Data.err = try {Test-NotExists $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null $test.Data.err
            Assert-True ($test.Data.out.Count -eq 1)
            Assert-True $test.Data.out[0]

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
    $testDescription = 'Test-NotExists with singleton containing Non-Boolean that is convertible to $false'

    for ($i = 0; $i -lt $nonBooleanFalse.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = @(,$nonBooleanFalse[$i]); predicate = $predicates.Identity;}
            $test.Data.err = try {Test-NotExists $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null $test.Data.err
            Assert-True ($test.Data.out.Count -eq 1)
            Assert-True $test.Data.out[0]

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
    $testDescription = 'Test-NotExists with null predicate'
    $collections = @($null, @(), @(1), @('is the', 'loneliest number'), @("three's", 'company', 'too'))

    for ($i = 0; $i -lt $collections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = $collections[$i]; predicate = $null;}
            $test.Data.err = try {Test-NotExists $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
            Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('ParameterArgumentValidationErrorNullNotAllowed,Test-NotExists', [System.StringComparison]::OrdinalIgnoreCase))
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
    $testDescription = 'Test-NotExists with null collection'
    $predicates = @($predicates.psbase.Values)

    for ($i = 0; $i -lt $predicates.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = $null; predicate = $predicates[$i];}
            $test.Data.err = try {Test-NotExists $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null $test.Data.err
            Assert-True ($test.Data.out.Count -eq 1)
            Assert-Null $test.Data.out[0]

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
    $testDescription = 'Test-NotExists with collections containing null'
    $collections = @(@($null), @(1, $null), @('a', 'b', $null, 'c'), @($null, $null, $null, $null, $null))

    for ($i = 0; $i -lt $collections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = $collections[$i]; predicate = $predicates.False;}
            $test.Data.err = try {Test-NotExists $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null $test.Data.err
            Assert-True ($test.Data.out.Count -eq 1)
            Assert-True $test.Data.out[0]

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
    $testDescription = 'Test-NotExists with empty collection and true predicate'

    for ($i = 0; $i -lt $emptyCollections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = $emptyCollections[$i]; predicate = $predicates.True;}
            $test.Data.err = try {Test-NotExists $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null $test.Data.err
            Assert-True ($test.Data.out.Count -eq 1)
            Assert-True $test.Data.out[0]

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
    $testDescription = 'Test-NotExists with empty collection and false predicate'

    for ($i = 0; $i -lt $emptyCollections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = $emptyCollections[$i]; predicate = $predicates.False;}
            $test.Data.err = try {Test-NotExists $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null $test.Data.err
            Assert-True ($test.Data.out.Count -eq 1)
            Assert-True $test.Data.out[0]

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
    $testDescription = 'Test-NotExists with empty collection and identity predicate'

    for ($i = 0; $i -lt $emptyCollections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = $emptyCollections[$i]; predicate = $predicates.Identity;}
            $test.Data.err = try {Test-NotExists $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null $test.Data.err
            Assert-True ($test.Data.out.Count -eq 1)
            Assert-True $test.Data.out[0]

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
    $testDescription = 'Test-NotExists with empty collection and error predicate'

    for ($i = 0; $i -lt $emptyCollections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = $emptyCollections[$i]; predicate = $predicates.Error;}
            $test.Data.err = try {Test-NotExists $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null $test.Data.err
            Assert-True ($test.Data.out.Count -eq 1)
            Assert-True $test.Data.out[0]

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
    $testDescription = 'Test-NotExists with scalar and true predicate'

    for ($i = 0; $i -lt $nonCollections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = $nonCollections[$i]; predicate = $predicates.True;}
            $test.Data.err = try {Test-NotExists $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null $test.Data.err
            Assert-True ($test.Data.out.Count -eq 1)
            Assert-Null $test.Data.out[0]

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
    $testDescription = 'Test-NotExists with scalar and false predicate'

    for ($i = 0; $i -lt $nonCollections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = $nonCollections[$i]; predicate = $predicates.False;}
            $test.Data.err = try {Test-NotExists $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null $test.Data.err
            Assert-True ($test.Data.out.Count -eq 1)
            Assert-Null $test.Data.out[0]

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
    $testDescription = 'Test-NotExists with scalar and identity predicate'

    for ($i = 0; $i -lt $nonCollections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = $nonCollections[$i]; predicate = $predicates.Identity;}
            $test.Data.err = try {Test-NotExists $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null $test.Data.err
            Assert-True ($test.Data.out.Count -eq 1)
            Assert-Null $test.Data.out[0]

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
    $testDescription = 'Test-NotExists with scalar and error predicate'

    for ($i = 0; $i -lt $nonCollections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = $nonCollections[$i]; predicate = $predicates.Error;}
            $test.Data.err = try {Test-NotExists $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null $test.Data.err
            Assert-True ($test.Data.out.Count -eq 1)
            Assert-Null $test.Data.out[0]

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
    $test = newTestLogEntry 'Test-NotExists with quadruple and a predicate that throws on the first element'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{collection = @(1, 2, 3, 4); predicate = {param($a) if ($a -eq 1) {throw "Bad predicate $a"} else {$false}};}
        $test.Data.err = try {Test-NotExists $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('PredicateFailed,Test-NotExists', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.err.Exception -is [System.InvalidOperationException])
        Assert-NotNull ($test.Data.err.Exception.InnerException)
        Assert-True ($test.Data.err.Exception.InnerException.Message.Equals('Bad predicate 1', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Test-NotExists with quadruple and a predicate that throws on the second element'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{collection = @(1, 2, 3, 4); predicate = {param($a) if ($a -eq 2) {throw "Bad predicate $a"} else {$false}};}
        $test.Data.err = try {Test-NotExists $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('PredicateFailed,Test-NotExists', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.err.Exception -is [System.InvalidOperationException])
        Assert-NotNull ($test.Data.err.Exception.InnerException)
        Assert-True ($test.Data.err.Exception.InnerException.Message.Equals('Bad predicate 2', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Test-NotExists with quadruple and a predicate that throws on the third element'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{collection = @(1, 2, 3, 4); predicate = {param($a) if ($a -eq 3) {throw "Bad predicate $a"} else {$false}};}
        $test.Data.err = try {Test-NotExists $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('PredicateFailed,Test-NotExists', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.err.Exception -is [System.InvalidOperationException])
        Assert-NotNull ($test.Data.err.Exception.InnerException)
        Assert-True ($test.Data.err.Exception.InnerException.Message.Equals('Bad predicate 3', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Test-NotExists with quadruple and a predicate that throws on the fourth element'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{collection = @(1, 2, 3, 4); predicate = {param($a) if ($a -eq 4) {throw "Bad predicate $a"} else {$false}};}
        $test.Data.err = try {Test-NotExists $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('PredicateFailed,Test-NotExists', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.err.Exception -is [System.InvalidOperationException])
        Assert-NotNull ($test.Data.err.Exception.InnerException)
        Assert-True ($test.Data.err.Exception.InnerException.Message.Equals('Bad predicate 4', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Test-NotExists with quadruple and a predicate that throws on the fifth element'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{collection = @(1, 2, 3, 4); predicate = {param($a) if ($a -eq 5) {throw "Bad predicate $a"} else {$false}};}
        $test.Data.err = try {Test-NotExists $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err
        Assert-True ($test.Data.out.Count -eq 1)
        Assert-True $test.Data.out[0]

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
        $test = newTestLogEntry 'Test-NotExists early fail'
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in = @{
                collection     = $dictionary
                expectedCalls  = $i
                remainingCalls = $i
                predicate = {
                    param($entry)

                    $test.Data.in.remainingCalls--
                    $entry.Value -eq $i
                }
            }
            $test.Data.err = try {Test-NotExists $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null $test.Data.err
            Assert-True ($test.Data.out.Count -eq 1)
            Assert-False $test.Data.out[0]
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

    $test = newTestLogEntry 'Test-NotExists with a predicate that contains "break" outside of a loop'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in = @{
            collection     = $dictionary
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
            $test.Data.err = try {Test-NotExists $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        } while ($false)

        $test.Data.out = $out

        Assert-Null $test.Data.err
        Assert-True ($test.Data.out.Count -eq 1)
        Assert-True $test.Data.out[0]
        Assert-True (0 -eq $test.Data.in.remainingCalls)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

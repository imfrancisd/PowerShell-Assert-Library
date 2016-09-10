#requires -version 2

<#
.Synopsis
Test the Assert-NotExists cmdlet.
.Description
Test the Assert-NotExists cmdlet.
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
.\Test-Assert-NotExists-Multiple.ps1 -logger $simpleLogger


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
.\Test-Assert-NotExists-Multiple.ps1 -logger $customLogger


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
    $test = newTestLogEntry 'Assert-NotExists -Quantity Multiple with singleton containing $true'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{collection = @($true); predicate = $predicates.Identity;}
        $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null ($test.Data.err)
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-NotExists -Quantity Multiple with singleton containing $false'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{collection = @($false); predicate = $predicates.Identity;}
        $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err
        Assert-True ($test.Data.out.Count -eq 0)
        
        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-NotExists -Quantity Multiple with singleton containing $null'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{collection = @($null); predicate = $predicates.Identity;}
        $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $testDescription = 'Assert-NotExists -Quantity Multiple with singleton containing Non-Boolean that is convertible to $true'

    for ($i = 0; $i -lt $nonBooleanTrue.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = @(,$nonBooleanTrue[$i]); predicate = $predicates.Identity;}
            $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null $test.Data.err
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
    $testDescription = 'Assert-NotExists -Quantity Multiple with singleton containing Non-Boolean that is convertible to $false'

    for ($i = 0; $i -lt $nonBooleanFalse.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = @(,$nonBooleanFalse[$i]); predicate = $predicates.Identity;}
            $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null $test.Data.err
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
    $test = newTestLogEntry 'Assert-NotExists -Quantity Multiple with tuple containing $true'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{collection = @($true, $true); predicate = $predicates.Identity;}
        $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-NotExists', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-NotExists -Quantity Multiple with tuple containing $false'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{collection = @($false, $false); predicate = $predicates.Identity;}
        $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err
        Assert-True ($test.Data.out.Count -eq 0)
        
        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-NotExists -Quantity Multiple with tuple containing $null'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{collection = @($null, $null); predicate = $predicates.Identity;}
        $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $testDescription = 'Assert-NotExists -Quantity Multiple with tuple containing Non-Boolean that is convertible to $true'

    for ($i = 0; $i -lt $nonBooleanTrue.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = @($nonBooleanTrue[$i], $nonBooleanTrue[$i]); predicate = $predicates.Identity;}
            $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null $test.Data.err
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
    $testDescription = 'Assert-NotExists -Quantity Multiple with tuple containing Non-Boolean that is convertible to $false'

    for ($i = 0; $i -lt $nonBooleanFalse.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = @($nonBooleanFalse[$i], $nonBooleanFalse[$i]); predicate = $predicates.Identity;}
            $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null $test.Data.err
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
    $testDescription = 'Assert-NotExists -Quantity Multiple with null predicate'
    $collections = @($null, @(), @(1), @('is the', 'loneliest number'), @("three's", 'company', 'too'))

    for ($i = 0; $i -lt $collections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = $collections[$i]; predicate = $null;}
            $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
            Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('ParameterArgumentValidationErrorNullNotAllowed,Assert-NotExists', [System.StringComparison]::OrdinalIgnoreCase))
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
    $testDescription = 'Assert-NotExists -Quantity Multiple with null collection'
    $predicates = @($predicates.psbase.Values)

    for ($i = 0; $i -lt $predicates.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = $null; predicate = $predicates[$i];}
            $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
            Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-NotExists', [System.StringComparison]::OrdinalIgnoreCase))
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
    $testDescription = 'Assert-NotExists -Quantity Multiple with collections containing null'
    $collections = @(@($null), @(1, $null), @('a', 'b', $null, 'c'), @($null, $null, $null, $null, $null))

    for ($i = 0; $i -lt $collections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = $collections[$i]; predicate = $predicates.False;}
            $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null $test.Data.err
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
    $testDescription = 'Assert-NotExists -Quantity Multiple with empty collection and true predicate'

    for ($i = 0; $i -lt $emptyCollections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = $emptyCollections[$i]; predicate = $predicates.True;}
            $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null $test.Data.err
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
    $testDescription = 'Assert-NotExists -Quantity Multiple with empty collection and false predicate'

    for ($i = 0; $i -lt $emptyCollections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = $emptyCollections[$i]; predicate = $predicates.False;}
            $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null $test.Data.err
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
    $testDescription = 'Assert-NotExists -Quantity Multiple with empty collection and identity predicate'

    for ($i = 0; $i -lt $emptyCollections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = $emptyCollections[$i]; predicate = $predicates.Identity;}
            $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null $test.Data.err
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
    $testDescription = 'Assert-NotExists -Quantity Multiple with empty collection and error predicate'

    for ($i = 0; $i -lt $emptyCollections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = $emptyCollections[$i]; predicate = $predicates.Error;}
            $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null $test.Data.err
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
    $testDescription = 'Assert-NotExists -Quantity Multiple with scalar and true predicate'

    for ($i = 0; $i -lt $nonCollections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = $nonCollections[$i]; predicate = $predicates.True;}
            $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
            Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-NotExists', [System.StringComparison]::OrdinalIgnoreCase))
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
    $testDescription = 'Assert-NotExists -Quantity Multiple with scalar and false predicate'

    for ($i = 0; $i -lt $nonCollections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = $nonCollections[$i]; predicate = $predicates.False;}
            $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
            Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-NotExists', [System.StringComparison]::OrdinalIgnoreCase))
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
    $testDescription = 'Assert-NotExists -Quantity Multiple with scalar and identity predicate'

    for ($i = 0; $i -lt $nonCollections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = $nonCollections[$i]; predicate = $predicates.Identity;}
            $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
            Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-NotExists', [System.StringComparison]::OrdinalIgnoreCase))
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
    $testDescription = 'Assert-NotExists -Quantity Multiple with scalar and error predicate'

    for ($i = 0; $i -lt $nonCollections.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{collection = $nonCollections[$i]; predicate = $predicates.Error;}
            $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
            Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-NotExists', [System.StringComparison]::OrdinalIgnoreCase))
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
    $test = newTestLogEntry 'Assert-NotExists -Quantity Multiple with quadruple and a predicate that throws on the first element'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{collection = @(1, 2, 3, 4); predicate = {param($a) if ($a -eq 1) {throw "Bad predicate $a"} else {$false}};}
        $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('PredicateFailed,Assert-NotExists', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.err.Exception -is [System.InvalidOperationException])
        Assert-NotNull ($test.Data.err.Exception.InnerException)
        Assert-True ($test.Data.err.Exception.InnerException.Message.Equals('Bad predicate 1', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-NotExists -Quantity Multiple with quadruple and a predicate that throws on the second element'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{collection = @(1, 2, 3, 4); predicate = {param($a) if ($a -eq 2) {throw "Bad predicate $a"} else {$false}};}
        $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('PredicateFailed,Assert-NotExists', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.err.Exception -is [System.InvalidOperationException])
        Assert-NotNull ($test.Data.err.Exception.InnerException)
        Assert-True ($test.Data.err.Exception.InnerException.Message.Equals('Bad predicate 2', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-NotExists -Quantity Multiple with quadruple and a predicate that throws on the third element'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{collection = @(1, 2, 3, 4); predicate = {param($a) if ($a -eq 3) {throw "Bad predicate $a"} else {$false}};}
        $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('PredicateFailed,Assert-NotExists', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.err.Exception -is [System.InvalidOperationException])
        Assert-NotNull ($test.Data.err.Exception.InnerException)
        Assert-True ($test.Data.err.Exception.InnerException.Message.Equals('Bad predicate 3', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-NotExists -Quantity Multiple with quadruple and a predicate that throws on the fourth element'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{collection = @(1, 2, 3, 4); predicate = {param($a) if ($a -eq 4) {throw "Bad predicate $a"} else {$false}};}
        $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('PredicateFailed,Assert-NotExists', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.err.Exception -is [System.InvalidOperationException])
        Assert-NotNull ($test.Data.err.Exception.InnerException)
        Assert-True ($test.Data.err.Exception.InnerException.Message.Equals('Bad predicate 4', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-NotExists -Quantity Multiple with quadruple and a predicate that throws on the fifth element'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{collection = @(1, 2, 3, 4); predicate = {param($a) if ($a -eq 5) {throw "Bad predicate $a"} else {$false}};}
        $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $numbers = @(1..5)

    foreach ($i in @(0, 6, -1)) {
        $test = newTestLogEntry 'Assert-NotExists -Quantity Multiple normal pass'
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in = @{
                inputObject    = $numbers
                expectedCalls  = $numbers.Length
                remainingCalls = $numbers.Length
                predicate = {
                    param($n)

                    $test.Data.in.remainingCalls--
                    $n -eq $i
                }
            }
            $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.inputObject $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null ($test.Data.err)
            Assert-True ($test.Data.out.Count -eq 0)
            Assert-True (0 -eq $test.Data.in.remainingCalls)

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }
}

& {
    $numbers = @(1, 2, 3, 4, 1, 2, 3, 4)

    foreach ($i in @(1..4)) {
        $test = newTestLogEntry 'Assert-NotExists -Quantity Multiple early fail'
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in = @{
                inputObject    = $numbers
                expectedCalls  = $i + 4
                remainingCalls = $i + 4
                predicate = {
                    param($n)

                    $test.Data.in.remainingCalls--
                    $n -eq $i
                }
            }
            $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.inputObject $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
            Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-NotExists', [System.StringComparison]::OrdinalIgnoreCase))
            Assert-True ($test.Data.out.Count -eq 0)
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

    $test = newTestLogEntry 'Assert-NotExists -Quantity Multiple with a predicate that contains "break" outside of a loop'
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
            $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        } while ($false)

        $test.Data.out = $out

        Assert-Null $test.Data.err
        Assert-True ($test.Data.out.Count -eq 0)
        Assert-True (0 -eq $test.Data.in.remainingCalls)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-NotExists -Quantity Multiple with an arraylist that has its .NET members overriden'
    $pass = $false

    try {
        $badArrayList = new-object system.collections.arraylist -argumentlist (,@(0, 1, 2, 3, 2, 1, 0))
        Add-Member -InputObject $badArrayList -MemberType ScriptMethod -Name GetEnumerator -Value {,(new-object system.collections.arraylist).GetEnumerator()} -Force
        Add-Member -InputObject $badArrayList -MemberType ScriptMethod -Name Clone -Value {,(new-object system.collections.arraylist)} -Force
        Add-Member -InputObject $badArrayList -MemberType ScriptMethod -Name Contains -Value {$false} -Force
        Add-Member -InputObject $badArrayList -MemberType ScriptMethod -Name CopyTo -Value {return} -Force
        Add-Member -InputObject $badArrayList -MemberType ScriptMethod -Name ForEach -Value {return} -Force
        Add-Member -InputObject $badArrayList -MemberType ScriptMethod -Name GetRange -Value {if (0 -ne $args[0] -or 0 -ne $args[1]) {throw} else {,(new-object system.collections.arraylist)}} -Force
        Add-Member -InputObject $badArrayList -MemberType ScriptMethod -Name IndexOf -Value {-1} -Force
        Add-Member -InputObject $badArrayList -MemberType ScriptMethod -Name LastIndexOf -Value {-1} -Force
        Add-Member -InputObject $badArrayList -MemberType ScriptMethod -Name ToArray -Value {,@()} -Force
        Add-Member -InputObject $badArrayList -MemberType ScriptMethod -Name Where -Value {return} -Force
        Add-Member -InputObject $badArrayList -MemberType NoteProperty -Name Count -Value 0 -Force
        Add-Member -InputObject $badArrayList -MemberType NoteProperty -Name Values -Value @() -Force

        $test.Data.out = $out = @()
        $test.Data.in = @{
            collection     = $badArrayList
            examinedValues   = new-object system.collections.arraylist
            expectedCalls  = 7
            remainingCalls = 7
            predicate = {
                param($n)

                $test.Data.in.remainingCalls--
                $test.Data.in.examinedValues.Add($n) | out-null
                $false
            }
        }
        $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err
        Assert-True ($test.Data.out.Count -eq 0)
        Assert-True (0 -eq $test.Data.in.remainingCalls)

        Assert-True (7 -eq $test.Data.in.examinedValues.Count)
        Assert-True (0 -eq $test.Data.in.examinedValues[0])
        Assert-True (1 -eq $test.Data.in.examinedValues[1])
        Assert-True (2 -eq $test.Data.in.examinedValues[2])
        Assert-True (3 -eq $test.Data.in.examinedValues[3])
        Assert-True (2 -eq $test.Data.in.examinedValues[4])
        Assert-True (1 -eq $test.Data.in.examinedValues[5])
        Assert-True (0 -eq $test.Data.in.examinedValues[6])

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-NotExists -Quantity Multiple with a hashtable that has its .NET members overriden'
    $pass = $false

    try {
        $badHashtable = @{
            count = 0
            keys = @()
            psadapted = @{}.psadapted
            psbase = @{}.psbase
            psextended = @{}.psextended
            psobject = @{}.psobject
            values = @()
        }
        Add-Member -InputObject $badHashtable -MemberType ScriptMethod -Name GetEnumerator -Value {,@{}.GetEnumerator()} -Force
        Add-Member -InputObject $badHashtable -MemberType ScriptMethod -Name Contains -Value {$false} -Force
        Add-Member -InputObject $badHashtable -MemberType ScriptMethod -Name ContainsKey -Value {$false} -Force
        Add-Member -InputObject $badHashtable -MemberType ScriptMethod -Name ContainsValue -Value {$false} -Force
        Add-Member -InputObject $badHashtable -MemberType NoteProperty -Name Count -Value 0 -Force
        Add-Member -InputObject $badHashtable -MemberType NoteProperty -Name Keys -Value @() -Force
        Add-Member -InputObject $badHashtable -MemberType NoteProperty -Name Values -Value @() -Force

        $test.Data.out = $out = @()
        $test.Data.in = @{
            collection     = $badHashtable
            examinedKeys   = new-object system.collections.arraylist
            expectedCalls  = 7
            remainingCalls = 7
            predicate = {
                param($entry)

                $test.Data.in.remainingCalls--
                $test.Data.in.examinedKeys.Add($entry.Key) | out-null
                $false
            }
        }
        $test.Data.err = try {Assert-NotExists -Quantity Multiple $test.Data.in.collection $test.Data.in.predicate -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err
        Assert-True ($test.Data.out.Count -eq 0)
        Assert-True (0 -eq $test.Data.in.remainingCalls)

        $test.Data.in.examinedKeys = @($test.Data.in.examinedKeys | Sort-Object)

        Assert-True (7 -eq $test.Data.in.examinedKeys.Length)
        Assert-True ('count' -eq $test.Data.in.examinedKeys[0])
        Assert-True ('keys' -eq $test.Data.in.examinedKeys[1])
        Assert-True ('psadapted' -eq $test.Data.in.examinedKeys[2])
        Assert-True ('psbase' -eq $test.Data.in.examinedKeys[3])
        Assert-True ('psextended' -eq $test.Data.in.examinedKeys[4])
        Assert-True ('psobject' -eq $test.Data.in.examinedKeys[5])
        Assert-True ('values' -eq $test.Data.in.examinedKeys[6])

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

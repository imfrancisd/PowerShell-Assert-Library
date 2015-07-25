#requires -version 2

<#
.Synopsis
Test the Assert-NotNull cmdlet.
.Description
Test the Assert-NotNull cmdlet.
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
.\Test-Assert-NotNull.ps1 -logger $simpleLogger


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
.\Test-Assert-NotNull.ps1 -logger $customLogger


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



& {
    $testDescription = 'Assert-NotNull help'

    $test = newTestLogEntry $testDescription
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{name = 'Assert-NotNull'}
        $test.Data.err = try {Get-Help -Name $test.Data.in.name -Full -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        $pass =
            (Test-Null $test.Data.err) -and
            ($test.Data.out.Count -eq 1) -and
            ($test.Data.out[0].Name -is [System.String]) -and
            ($test.Data.out[0].Name.Equals('Assert-NotNull', [System.StringComparison]::OrdinalIgnoreCase)) -and
            ($test.Data.out[0].description -is [System.Collections.ICollection]) -and
            ($test.Data.out[0].description.Count -gt 0) -and
            (Test-NotNull $test.Data.out[0].examples) -and
            (0 -lt @($test.Data.out[0].examples.example).Count) -and
            ('' -ne @($test.Data.out[0].examples.example)[0].code)

        if (-not $pass) {
            throw New-Object 'System.Exception' -ArgumentList @("Failed $testDescription")
        }
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $testDescription = 'Assert-NotNull parameters'

    $test = newTestLogEntry $testDescription
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{name = 'Assert-NotNull'}
        $test.Data.err = try {Get-Command -Name $test.Data.in.name -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        if (Test-NotNull $test.Data.err) {
            throw New-Object 'System.Exception' -ArgumentList @("Failed $testDescription")
        }

        $paramSets = @($test.Data.out[0].ParameterSets)
        if (1 -ne $paramSets.Count) {
            throw New-Object 'System.Exception' -ArgumentList @("Failed $testDescription")
        }

        $valueParam = $paramSets[0].Parameters |
            Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        if (Test-Null $valueParam) {
            throw New-Object 'System.Exception' -ArgumentList @("Failed $testDescription")
        }

        $pass =
            ($valueParam.IsMandatory) -and
            ($valueParam.ParameterType -eq [System.Object]) -and
            (-not $valueParam.ValueFromPipeline) -and
            (-not $valueParam.ValueFromPipelineByPropertyName) -and
            (-not $valueParam.ValueFromRemainingArguments) -and
            (0 -eq $valueParam.Position) -and
            (0 -eq $valueParam.Aliases.Count)

        if (-not $pass) {
            throw New-Object 'System.Exception' -ArgumentList @("Failed $testDescription")
        }
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $testDescription = 'Assert-NotNull with Boolean $true'

    $test = newTestLogEntry $testDescription
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{value = $true}
        $test.Data.err = try {Assert-NotNull $test.Data.in.value -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        $pass =
            (Test-Null $test.Data.err) -and
            ($test.Data.out.Count -eq 0)

        if (-not $pass) {
            throw New-Object 'System.Exception' -ArgumentList @("Failed $testDescription")
        }
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $testDescription = 'Assert-NotNull with Boolean $false'

    $test = newTestLogEntry $testDescription
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{value = $false}
        $test.Data.err = try {Assert-NotNull $test.Data.in.value -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        $pass =
            (Test-Null $test.Data.err) -and
            ($test.Data.out.Count -eq 0)

        if (-not $pass) {
            throw New-Object 'System.Exception' -ArgumentList @("Failed $testDescription")
        }
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $testDescription = 'Assert-NotNull with $null'

    $test = newTestLogEntry $testDescription
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{value = $null}
        $test.Data.err = try {Assert-NotNull $test.Data.in.value -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        $pass =
            ($test.Data.err -is [System.Management.Automation.ErrorRecord]) -and
            ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-NotNull', [System.StringComparison]::OrdinalIgnoreCase)) -and
            ($test.Data.out.Count -eq 0)

        if (-not $pass) {
            throw New-Object 'System.Exception' -ArgumentList @("Failed $testDescription")
        }
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $testDescription = 'Assert-NotNull with Non-Boolean that is convertible to $true'

    for ($i = 0; $i -lt $nonBooleanTrue.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{value = $nonBooleanTrue[$i]}
            $test.Data.err = try {Assert-NotNull $test.Data.in.value -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            $pass =
                (Test-Null $test.Data.err) -and
                ($test.Data.out.Count -eq 0)

            if (-not $pass) {
                throw New-Object 'System.Exception' -ArgumentList @("Failed $testDescription")
            }
        }
        finally {commitTestLogEntry $test $pass}
    }

    if ($i -eq 0) {
        commitTestLogEntry (newTestLogEntry $testDescription)
        throw New-Object 'System.Exception' -ArgumentList @("No data for $testDescription")
    }
}

& {
    $testDescription = 'Assert-NotNull with Non-Boolean that is convertible to $false'

    for ($i = 0; $i -lt $nonBooleanFalse.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{value = $nonBooleanFalse[$i]}
            $test.Data.err = try {Assert-NotNull $test.Data.in.value -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            $pass =
                (Test-Null $test.Data.err) -and
                ($test.Data.out.Count -eq 0)

            if (-not $pass) {
                throw New-Object 'System.Exception' -ArgumentList @("Failed $testDescription")
            }
        }
        finally {commitTestLogEntry $test $pass}
    }

    if ($i -eq 0) {
        commitTestLogEntry (newTestLogEntry $testDescription)
        throw New-Object 'System.Exception' -ArgumentList @("No data for $testDescription")
    }
}

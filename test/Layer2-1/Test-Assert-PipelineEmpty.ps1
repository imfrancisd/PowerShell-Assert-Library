#requires -version 2

<#
.Synopsis
Test the Assert-PipelineEmpty cmdlet.
.Description
Test the Assert-PipelineEmpty cmdlet.
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
.\Test-Assert-PipelineEmpty.ps1 -logger $simpleLogger


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
.\Test-Assert-PipelineEmpty.ps1 -logger $customLogger


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
    $test = newTestLogEntry 'Assert-PipelineEmpty help'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{name = 'Assert-PipelineEmpty'}
        $test.Data.err = try {Get-Help -Name $test.Data.in.name -Full -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err
        Assert-True ($test.Data.out.Count -eq 1)
        Assert-True ($test.Data.out[0].Name -is [System.String])
        Assert-True ($test.Data.out[0].Name.Equals('Assert-PipelineEmpty', [System.StringComparison]::OrdinalIgnoreCase))
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
    $test = newTestLogEntry 'Assert-PipelineEmpty parameters'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{name = 'Assert-PipelineEmpty'}
        $test.Data.err = try {Get-Command -Name $test.Data.in.name -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err

        $paramSets = @($test.Data.out[0].ParameterSets)
        Assert-True (1 -eq $paramSets.Count)

        $inputObject = $paramSets[0].Parameters |
            Where-Object {'InputObject'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $inputObject

        Assert-True ($inputObject.IsMandatory)
        Assert-True ($inputObject.ParameterType -eq [System.Object])
        Assert-True ($inputObject.ValueFromPipeline)
        Assert-False ($inputObject.ValueFromPipelineByPropertyName)
        Assert-False ($inputObject.ValueFromRemainingArguments)
        
        #Cannot force named parameters for single parameter functions in PowerShell 2. Maybe.
        #Assert-True (0 -gt $inputObject.Position)

        Assert-True (0 -eq $inputObject.Aliases.Count)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-PipelineEmpty with non-pipeline input'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{inputObject = @(1..3);}
        $test.Data.err = try {Assert-PipelineEmpty -InputObject $test.Data.in.inputObject -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('PipelineArgumentOnly,Assert-PipelineEmpty', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-PipelineEmpty with pipeline containing nothing'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{inputObject = @();}
        $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineEmpty -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-PipelineEmpty with pipeline containing $true'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{inputObject = @($true);}
        $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineEmpty -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineEmpty', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-PipelineEmpty with pipeline containing $false'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{inputObject = @($false);}
        $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineEmpty -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineEmpty', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-PipelineEmpty with pipeline containing $null'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{inputObject = @($null);}
        $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineEmpty -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineEmpty', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $testDescription = 'Assert-PipelineEmpty with pipeline containing Non-Boolean that is convertible to $true'

    for ($i = 0; $i -lt $nonBooleanTrue.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @(,$nonBooleanTrue[$i]);}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineEmpty -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
            Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineEmpty', [System.StringComparison]::OrdinalIgnoreCase))
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
    $testDescription = 'Assert-PipelineEmpty with pipeline containing Non-Boolean that is convertible to $false'

    for ($i = 0; $i -lt $nonBooleanFalse.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @(,$nonBooleanFalse[$i]);}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineEmpty -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
            Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineEmpty', [System.StringComparison]::OrdinalIgnoreCase))
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
    $testDescription = 'Assert-PipelineEmpty with pipeline containing multiple items'

    $items = @(
        'hello', 0, 1.0, $true, $false, @(), @('hi', $null, 'world'), @{}, (New-Object -TypeName 'System.Collections.ArrayList')
    )

    for ($i = 0; $i -lt $items.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @($items[0..$i]);}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineEmpty -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
            Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineEmpty', [System.StringComparison]::OrdinalIgnoreCase))
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

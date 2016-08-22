#requires -version 2

<#
.Synopsis
Test the Assert-PipelineCount cmdlet.
.Description
Test the Assert-PipelineCount cmdlet.
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
.\Test-Assert-PipelineCount.ps1 -logger $simpleLogger


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
.\Test-Assert-PipelineCount.ps1 -logger $customLogger


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
    $test = newTestLogEntry 'Assert-PipelineCount help'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{name = 'Assert-PipelineCount'}
        $test.Data.err = try {Get-Help -Name $test.Data.in.name -Full -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err
        Assert-True ($test.Data.out.Count -eq 1)
        Assert-True ($test.Data.out[0].Name -is [System.String])
        Assert-True ($test.Data.out[0].Name.Equals('Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
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
    $test = newTestLogEntry 'Assert-PipelineCount parameters'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{name = 'Assert-PipelineCount'; paramSet = 'Equals'}
        $test.Data.err = try {Get-Command -Name $test.Data.in.name -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err

        $paramSet = $test.Data.out[0].ParameterSets |
            Where-Object {$test.Data.in.paramSet.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
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
        Assert-True (1 -eq $equalsParam.Aliases.Count)
        Assert-True ('eq'.Equals($equalsParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-PipelineCount parameters'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{name = 'Assert-PipelineCount'; paramSet = 'NotEquals'}
        $test.Data.err = try {Get-Command -Name $test.Data.in.name -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err

        $paramSet = $test.Data.out[0].ParameterSets |
            Where-Object {$test.Data.in.paramSet.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $paramSet

        $inputObject = $paramSet.Parameters |
            Where-Object {'InputObject'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $inputObject

        $notEqualsParam = $paramSet.Parameters |
            Where-Object {'NotEquals'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $notEqualsParam

        Assert-True ($inputObject.IsMandatory)
        Assert-True ($inputObject.ParameterType -eq [System.Object])
        Assert-True ($inputObject.ValueFromPipeline)
        Assert-False ($inputObject.ValueFromPipelineByPropertyName)
        Assert-False ($inputObject.ValueFromRemainingArguments)
        Assert-True (0 -gt $inputObject.Position)
        Assert-True (0 -eq $inputObject.Aliases.Count)

        Assert-True ($notEqualsParam.IsMandatory)
        Assert-True ($notEqualsParam.ParameterType -eq [System.Int64])
        Assert-False ($notEqualsParam.ValueFromPipeline)
        Assert-False ($notEqualsParam.ValueFromPipelineByPropertyName)
        Assert-False ($notEqualsParam.ValueFromRemainingArguments)
        Assert-True (0 -gt $notEqualsParam.Position)
        Assert-True (1 -eq $notEqualsParam.Aliases.Count)
        Assert-True ('ne'.Equals($notEqualsParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-PipelineCount parameters'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{name = 'Assert-PipelineCount'; paramSet = 'Minimum'}
        $test.Data.err = try {Get-Command -Name $test.Data.in.name -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err

        $paramSet = $test.Data.out[0].ParameterSets |
            Where-Object {$test.Data.in.paramSet.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $paramSet

        $inputObject = $paramSet.Parameters |
            Where-Object {'InputObject'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $inputObject

        $minParam = $paramSet.Parameters |
            Where-Object {'Minimum'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $minParam

        Assert-True ($inputObject.IsMandatory)
        Assert-True ($inputObject.ParameterType -eq [System.Object])
        Assert-True ($inputObject.ValueFromPipeline)
        Assert-False ($inputObject.ValueFromPipelineByPropertyName)
        Assert-False ($inputObject.ValueFromRemainingArguments)
        Assert-True (0 -gt $inputObject.Position)
        Assert-True (0 -eq $inputObject.Aliases.Count)

        Assert-True ($minParam.IsMandatory)
        Assert-True ($minParam.ParameterType -eq [System.Int64])
        Assert-False ($minParam.ValueFromPipeline)
        Assert-False ($minParam.ValueFromPipelineByPropertyName)
        Assert-False ($minParam.ValueFromRemainingArguments)
        Assert-True (0 -gt $minParam.Position)
        Assert-True (1 -eq $minParam.Aliases.Count)
        Assert-True ('min'.Equals($minParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-PipelineCount parameters'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{name = 'Assert-PipelineCount'; paramSet = 'Maximum'}
        $test.Data.err = try {Get-Command -Name $test.Data.in.name -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err

        $paramSet = $test.Data.out[0].ParameterSets |
            Where-Object {$test.Data.in.paramSet.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $paramSet

        $inputObject = $paramSet.Parameters |
            Where-Object {'InputObject'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $inputObject

        $maxParam = $paramSet.Parameters |
            Where-Object {'Maximum'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $maxParam

        Assert-True ($inputObject.IsMandatory)
        Assert-True ($inputObject.ParameterType -eq [System.Object])
        Assert-True ($inputObject.ValueFromPipeline)
        Assert-False ($inputObject.ValueFromPipelineByPropertyName)
        Assert-False ($inputObject.ValueFromRemainingArguments)
        Assert-True (0 -gt $inputObject.Position)
        Assert-True (0 -eq $inputObject.Aliases.Count)

        Assert-True ($maxParam.IsMandatory)
        Assert-True ($maxParam.ParameterType -eq [System.Int64])
        Assert-False ($maxParam.ValueFromPipeline)
        Assert-False ($maxParam.ValueFromPipelineByPropertyName)
        Assert-False ($maxParam.ValueFromRemainingArguments)
        Assert-True (0 -gt $maxParam.Position)
        Assert-True (1 -eq $maxParam.Aliases.Count)
        Assert-True ('max'.Equals($maxParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-PipelineCount with non-pipeline input'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{inputObject = @(1..3); equals = 3;}
        $test.Data.err = try {Assert-PipelineCount -InputObject $test.Data.in.inputObject -Equals $test.Data.in.equals -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('PipelineArgumentOnly,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-PipelineCount with non-pipeline input'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{inputObject = @(1..3); notequals = 5;}
        $test.Data.err = try {Assert-PipelineCount -InputObject $test.Data.in.inputObject -NotEquals $test.Data.in.notequals -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('PipelineArgumentOnly,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-PipelineCount with non-pipeline input'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{inputObject = @(1..3); minimum = 2;}
        $test.Data.err = try {Assert-PipelineCount -InputObject $test.Data.in.inputObject -Minimum $test.Data.in.minimum -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('PipelineArgumentOnly,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Assert-PipelineCount with non-pipeline input'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{inputObject = @(1..3); maximum = 4;}
        $test.Data.err = try {Assert-PipelineCount -InputObject $test.Data.in.inputObject -Maximum $test.Data.in.maximum -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('PipelineArgumentOnly,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    foreach ($i in @(-1..1)) {
        $test = newTestLogEntry 'Assert-PipelineCount with pipeline containing nothing'
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @(); equals = $i;}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -Equals $test.Data.in.equals -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            if ($i -eq 0) {
                Assert-Null ($test.Data.err)
                Assert-True ($test.Data.out.Count -eq 0)
            } else {
                Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
                Assert-True ($test.Data.out.Count -eq 0)
            }

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }
}

& {
    foreach ($i in @(-1..1)) {
        $test = newTestLogEntry 'Assert-PipelineCount with pipeline containing nothing'
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @(); notequals = $i;}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -NotEquals $test.Data.in.notequals -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            if ($i -ne 0) {
                Assert-Null ($test.Data.err)
                Assert-True ($test.Data.out.Count -eq 0)
            } else {
                Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
                Assert-True ($test.Data.out.Count -eq 0)
            }

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }
}

& {
    foreach ($i in @(-1..1)) {
        $test = newTestLogEntry 'Assert-PipelineCount with pipeline containing nothing'
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @(); minimum = $i;}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -Minimum $test.Data.in.minimum -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            if ($i -le 0) {
                Assert-Null ($test.Data.err)
                Assert-True ($test.Data.out.Count -eq 0)
            } else {
                Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
                Assert-True ($test.Data.out.Count -eq 0)
            }

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }
}

& {
    foreach ($i in @(-1..1)) {
        $test = newTestLogEntry 'Assert-PipelineCount with pipeline containing nothing'
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @(); maximum = $i;}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -Maximum $test.Data.in.maximum -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            if ($i -ge 0) {
                Assert-Null ($test.Data.err)
                Assert-True ($test.Data.out.Count -eq 0)
            } else {
                Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
                Assert-True ($test.Data.out.Count -eq 0)
            }

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }
}

& {
    foreach ($i in @(-1..2)) {
        $test = newTestLogEntry 'Assert-PipelineCount with pipeline containing $true'
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @($true); equals = $i;}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -Equals $test.Data.in.equals -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            if ($i -eq 1) {
                Assert-Null ($test.Data.err)
            } else {
                Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
            }

            if ($i -lt 1) {
                Assert-True ($test.Data.out.Count -eq 0)
            } else {
                Assert-True ($test.Data.out.Count -eq 1)
                Assert-True ($test.Data.out[0])
            }

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }
}

& {
    foreach ($i in @(-1..2)) {
        $test = newTestLogEntry 'Assert-PipelineCount with pipeline containing $true'
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @($true); notequals = $i;}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -NotEquals $test.Data.in.notequals -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            if ($i -ne 1) {
                Assert-Null ($test.Data.err)
            } else {
                Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
            }

            Assert-True ($test.Data.out.Count -eq 1)
            Assert-True ($test.Data.out[0])

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }
}

& {
    foreach ($i in @(-1..2)) {
        $test = newTestLogEntry 'Assert-PipelineCount with pipeline containing $true'
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @($true); minimum = $i;}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -Minimum $test.Data.in.minimum -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            if ($i -le 1) {
                Assert-Null ($test.Data.err)
            } else {
                Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
            }

            Assert-True ($test.Data.out.Count -eq 1)
            Assert-True ($test.Data.out[0])

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }
}

& {
    foreach ($i in @(-1..2)) {
        $test = newTestLogEntry 'Assert-PipelineCount with pipeline containing $true'
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @($true); maximum = $i;}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -Maximum $test.Data.in.maximum -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            if ($i -ge 1) {
                Assert-Null ($test.Data.err)
            } else {
                Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
            }

            if ($i -le 0) {
                Assert-True ($test.Data.out.Count -eq 0)
            } else {
                Assert-True ($test.Data.out.Count -eq 1)
                Assert-True ($test.Data.out[0])
            }

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }
}

& {
    foreach ($i in @(-1..2)) {
        $test = newTestLogEntry 'Assert-PipelineCount with pipeline containing $false'
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @($false); equals = $i;}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -Equals $test.Data.in.equals -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            if ($i -eq 1) {
                Assert-Null ($test.Data.err)
            } else {
                Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
            }

            if ($i -lt 1) {
                Assert-True ($test.Data.out.Count -eq 0)
            } else {
                Assert-True ($test.Data.out.Count -eq 1)
                Assert-False ($test.Data.out[0])
            }

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }
}

& {
    foreach ($i in @(-1..2)) {
        $test = newTestLogEntry 'Assert-PipelineCount with pipeline containing $false'
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @($false); notequals = $i;}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -NotEquals $test.Data.in.notequals -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            if ($i -ne 1) {
                Assert-Null ($test.Data.err)
            } else {
                Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
            }

            Assert-True ($test.Data.out.Count -eq 1)
            Assert-False ($test.Data.out[0])

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }
}

& {
    foreach ($i in @(-1..2)) {
        $test = newTestLogEntry 'Assert-PipelineCount with pipeline containing $false'
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @($false); minimum = $i;}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -Minimum $test.Data.in.minimum -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            if ($i -le 1) {
                Assert-Null ($test.Data.err)
            } else {
                Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
            }

            Assert-True ($test.Data.out.Count -eq 1)
            Assert-False ($test.Data.out[0])

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }
}

& {
    foreach ($i in @(-1..2)) {
        $test = newTestLogEntry 'Assert-PipelineCount with pipeline containing $false'
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @($false); maximum = $i;}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -Maximum $test.Data.in.maximum -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            if ($i -ge 1) {
                Assert-Null ($test.Data.err)
            } else {
                Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
            }

            if ($i -le 0) {
                Assert-True ($test.Data.out.Count -eq 0)
            } else {
                Assert-True ($test.Data.out.Count -eq 1)
                Assert-False ($test.Data.out[0])
            }

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }
}

& {
    foreach ($i in @(-1..2)) {
        $test = newTestLogEntry 'Assert-PipelineCount with pipeline containing $null'
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @($null); equals = $i;}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -Equals $test.Data.in.equals -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            if ($i -eq 1) {
                Assert-Null ($test.Data.err)
            } else {
                Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
            }

            if ($i -lt 1) {
                Assert-True ($test.Data.out.Count -eq 0)
            } else {
                Assert-True ($test.Data.out.Count -eq 1)
                Assert-Null ($test.Data.out[0])
            }

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }
}

& {
    foreach ($i in @(-1..2)) {
        $test = newTestLogEntry 'Assert-PipelineCount with pipeline containing $null'
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @($null); notequals = $i;}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -NotEquals $test.Data.in.notequals -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            if ($i -ne 1) {
                Assert-Null ($test.Data.err)
            } else {
                Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
            }

            Assert-True ($test.Data.out.Count -eq 1)
            Assert-Null ($test.Data.out[0])

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }
}

& {
    foreach ($i in @(-1..2)) {
        $test = newTestLogEntry 'Assert-PipelineCount with pipeline containing $null'
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @($null); minimum = $i;}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -Minimum $test.Data.in.minimum -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            if ($i -le 1) {
                Assert-Null ($test.Data.err)
            } else {
                Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
            }

            Assert-True ($test.Data.out.Count -eq 1)
            Assert-Null ($test.Data.out[0])

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }
}

& {
    foreach ($i in @(-1..2)) {
        $test = newTestLogEntry 'Assert-PipelineCount with pipeline containing $null'
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{inputObject = @($null); maximum = $i;}
            $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -Maximum $test.Data.in.maximum -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            if ($i -ge 1) {
                Assert-Null ($test.Data.err)
            } else {
                Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
            }

            if ($i -le 0) {
                Assert-True ($test.Data.out.Count -eq 0)
            } else {
                Assert-True ($test.Data.out.Count -eq 1)
                Assert-Null ($test.Data.out[0])
            }

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }
}

& {
    $testDescription = 'Assert-PipelineCount with pipeline containing Non-Boolean that is convertible to $true'

    for ($i = 0; $i -lt $nonBooleanTrue.Count; $i++) {
        foreach ($j in @(-1..2)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{inputObject = @(,$nonBooleanTrue[$i]); equals = $j;}
                $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -Equals $test.Data.in.equals -OutVariable out | Out-Null} catch {$_}
                $test.Data.out = $out

                if ($j -eq 1) {
                    Assert-Null ($test.Data.err)
                } else {
                    Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                    Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
                }

                if ($j -le 0) {
                    Assert-True ($test.Data.out.Count -eq 0)
                } else {
                    Assert-True ($test.Data.out.Count -eq 1)
                    Assert-True ($test.Data.in.inputObject[0].Equals($test.Data.out[0]))
                }

                $pass = $true
            }
            finally {commitTestLogEntry $test $pass}
        }
    }

    if ($i -eq 0) {
        commitTestLogEntry (newTestLogEntry $testDescription)
        throw New-Object 'System.Exception' -ArgumentList @("No data for $testDescription")
    }
}

& {
    $testDescription = 'Assert-PipelineCount with pipeline containing Non-Boolean that is convertible to $true'

    for ($i = 0; $i -lt $nonBooleanTrue.Count; $i++) {
        foreach ($j in @(-1..2)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{inputObject = @(,$nonBooleanTrue[$i]); notequals = $j;}
                $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -NotEquals $test.Data.in.notequals -OutVariable out | Out-Null} catch {$_}
                $test.Data.out = $out

                if ($j -ne 1) {
                    Assert-Null ($test.Data.err)
                } else {
                    Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                    Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
                }

                Assert-True ($test.Data.out.Count -eq 1)
                Assert-True ($test.Data.in.inputObject[0].Equals($test.Data.out[0]))

                $pass = $true
            }
            finally {commitTestLogEntry $test $pass}
        }
    }

    if ($i -eq 0) {
        commitTestLogEntry (newTestLogEntry $testDescription)
        throw New-Object 'System.Exception' -ArgumentList @("No data for $testDescription")
    }
}

& {
    $testDescription = 'Assert-PipelineCount with pipeline containing Non-Boolean that is convertible to $true'

    for ($i = 0; $i -lt $nonBooleanTrue.Count; $i++) {
        foreach ($j in @(-1..2)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{inputObject = @(,$nonBooleanTrue[$i]); minimum = $j;}
                $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -Minimum $test.Data.in.minimum -OutVariable out | Out-Null} catch {$_}
                $test.Data.out = $out

                if ($j -le 1) {
                    Assert-Null ($test.Data.err)
                } else {
                    Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                    Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
                }

                Assert-True ($test.Data.out.Count -eq 1)
                Assert-True ($test.Data.in.inputObject[0].Equals($test.Data.out[0]))

                $pass = $true
            }
            finally {commitTestLogEntry $test $pass}
        }
    }

    if ($i -eq 0) {
        commitTestLogEntry (newTestLogEntry $testDescription)
        throw New-Object 'System.Exception' -ArgumentList @("No data for $testDescription")
    }
}

& {
    $testDescription = 'Assert-PipelineCount with pipeline containing Non-Boolean that is convertible to $true'

    for ($i = 0; $i -lt $nonBooleanTrue.Count; $i++) {
        foreach ($j in @(-1..2)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{inputObject = @(,$nonBooleanTrue[$i]); maximum = $j;}
                $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -Maximum $test.Data.in.maximum -OutVariable out | Out-Null} catch {$_}
                $test.Data.out = $out

                if ($j -ge 1) {
                    Assert-Null ($test.Data.err)
                } else {
                    Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                    Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
                }

                if ($j -le 0) {
                    Assert-True ($test.Data.out.Count -eq 0)
                } else {
                    Assert-True ($test.Data.out.Count -eq 1)
                    Assert-True ($test.Data.in.inputObject[0].Equals($test.Data.out[0]))
                }

                $pass = $true
            }
            finally {commitTestLogEntry $test $pass}
        }
    }

    if ($i -eq 0) {
        commitTestLogEntry (newTestLogEntry $testDescription)
        throw New-Object 'System.Exception' -ArgumentList @("No data for $testDescription")
    }
}

& {
    $testDescription = 'Assert-PipelineCount with pipeline containing Non-Boolean that is convertible to $false'

    for ($i = 0; $i -lt $nonBooleanFalse.Count; $i++) {
        foreach ($j in @(-1..2)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{inputObject = @(,$nonBooleanFalse[$i]); equals = $j;}
                $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -Equals $test.Data.in.equals -OutVariable out | Out-Null} catch {$_}
                $test.Data.out = $out

                if ($j -eq 1) {
                    Assert-Null ($test.Data.err)
                } else {
                    Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                    Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
                }

                if ($j -le 0) {
                    Assert-True ($test.Data.out.Count -eq 0)
                } else {
                    Assert-True ($test.Data.out.Count -eq 1)
                    Assert-True ($test.Data.in.inputObject[0].Equals($test.Data.out[0]))
                }

                $pass = $true
            }
            finally {commitTestLogEntry $test $pass}
        }
    }

    if ($i -eq 0) {
        commitTestLogEntry (newTestLogEntry $testDescription)
        throw New-Object 'System.Exception' -ArgumentList @("No data for $testDescription")
    }
}

& {
    $testDescription = 'Assert-PipelineCount with pipeline containing Non-Boolean that is convertible to $false'

    for ($i = 0; $i -lt $nonBooleanFalse.Count; $i++) {
        foreach ($j in @(-1..2)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{inputObject = @(,$nonBooleanFalse[$i]); notequals = $j;}
                $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -NotEquals $test.Data.in.notequals -OutVariable out | Out-Null} catch {$_}
                $test.Data.out = $out

                if ($j -ne 1) {
                    Assert-Null ($test.Data.err)
                } else {
                    Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                    Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
                }

                Assert-True ($test.Data.out.Count -eq 1)
                Assert-True ($test.Data.in.inputObject[0].Equals($test.Data.out[0]))

                $pass = $true
            }
            finally {commitTestLogEntry $test $pass}
        }
    }

    if ($i -eq 0) {
        commitTestLogEntry (newTestLogEntry $testDescription)
        throw New-Object 'System.Exception' -ArgumentList @("No data for $testDescription")
    }
}

& {
    $testDescription = 'Assert-PipelineCount with pipeline containing Non-Boolean that is convertible to $false'

    for ($i = 0; $i -lt $nonBooleanFalse.Count; $i++) {
        foreach ($j in @(-1..2)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{inputObject = @(,$nonBooleanFalse[$i]); minimum = $j;}
                $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -Minimum $test.Data.in.minimum -OutVariable out | Out-Null} catch {$_}
                $test.Data.out = $out

                if ($j -le 1) {
                    Assert-Null ($test.Data.err)
                } else {
                    Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                    Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
                }

                Assert-True ($test.Data.out.Count -eq 1)
                Assert-True ($test.Data.in.inputObject[0].Equals($test.Data.out[0]))

                $pass = $true
            }
            finally {commitTestLogEntry $test $pass}
        }
    }

    if ($i -eq 0) {
        commitTestLogEntry (newTestLogEntry $testDescription)
        throw New-Object 'System.Exception' -ArgumentList @("No data for $testDescription")
    }
}

& {
    $testDescription = 'Assert-PipelineCount with pipeline containing Non-Boolean that is convertible to $false'

    for ($i = 0; $i -lt $nonBooleanFalse.Count; $i++) {
        foreach ($j in @(-1..2)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{inputObject = @(,$nonBooleanFalse[$i]); maximum = $j;}
                $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -Maximum $test.Data.in.maximum -OutVariable out | Out-Null} catch {$_}
                $test.Data.out = $out

                if ($j -ge 1) {
                    Assert-Null ($test.Data.err)
                } else {
                    Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                    Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
                }

                if ($j -le 0) {
                    Assert-True ($test.Data.out.Count -eq 0)
                } else {
                    Assert-True ($test.Data.out.Count -eq 1)
                    Assert-True ($test.Data.in.inputObject[0].Equals($test.Data.out[0]))
                }

                $pass = $true
            }
            finally {commitTestLogEntry $test $pass}
        }
    }

    if ($i -eq 0) {
        commitTestLogEntry (newTestLogEntry $testDescription)
        throw New-Object 'System.Exception' -ArgumentList @("No data for $testDescription")
    }
}

& {
    $testDescription = 'Assert-PipelineCount with pipeline containing multiple items'

    $items = @(
        'hello', 0, 1.0, $true, $false, @(), @('hi', $null, 'world'), @{}, (New-Object -TypeName 'System.Collections.ArrayList')
    )

    for ($i = 0; $i -lt $items.Count; $i++) {
        $inputObject = @($items[0..$i])

        foreach ($equals in @(-1..$($inputObject.Count + 1))) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{inputObject = $inputObject; equals = $equals;}
                $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -Equals $test.Data.in.equals -OutVariable out | Out-Null} catch {$_}
                $test.Data.out = $out

                if ($equals -eq $inputObject.Count) {
                    Assert-Null ($test.Data.err)
                } else {
                    Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                    Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
                }

                if ($equals -lt $inputObject.Count) {
                    Assert-True ($test.Data.out.Count -eq ([System.Math]::Max(0, $test.Data.in.equals)))
                } else {
                    Assert-True ($test.Data.out.Count -eq $test.Data.in.inputObject.Count)
                    Assert-All @(0..$i) {param($index) $test.Data.in.inputObject[$index].Equals($test.Data.out[$index])}
                }

                $pass = $true
            }
            finally {commitTestLogEntry $test $pass}
        }
    }

    if ($i -eq 0) {
        commitTestLogEntry (newTestLogEntry $testDescription)
        throw New-Object 'System.Exception' -ArgumentList @("No data for $testDescription")
    }
}

& {
    $testDescription = 'Assert-PipelineCount with pipeline containing multiple items'

    $items = @(
        'hello', 0, 1.0, $true, $false, @(), @('hi', $null, 'world'), @{}, (New-Object -TypeName 'System.Collections.ArrayList')
    )

    for ($i = 0; $i -lt $items.Count; $i++) {
        $inputObject = @($items[0..$i])

        foreach ($notEquals in @(-1..$($inputObject.Count + 1))) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{inputObject = $inputObject; notequals = $notEquals;}
                $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -NotEquals $test.Data.in.notequals -OutVariable out | Out-Null} catch {$_}
                $test.Data.out = $out

                if ($notEquals -ne $inputObject.Count) {
                    Assert-Null ($test.Data.err)
                } else {
                    Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                    Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
                }

                Assert-True ($test.Data.out.Count -eq $test.Data.in.inputObject.Count)
                Assert-All @(0..$i) {param($index) $test.Data.in.inputObject[$index].Equals($test.Data.out[$index])}

                $pass = $true
            }
            finally {commitTestLogEntry $test $pass}
        }
    }

    if ($i -eq 0) {
        commitTestLogEntry (newTestLogEntry $testDescription)
        throw New-Object 'System.Exception' -ArgumentList @("No data for $testDescription")
    }
}

& {
    $testDescription = 'Assert-PipelineCount with pipeline containing multiple items'

    $items = @(
        'hello', 0, 1.0, $true, $false, @(), @('hi', $null, 'world'), @{}, (New-Object -TypeName 'System.Collections.ArrayList')
    )

    for ($i = 0; $i -lt $items.Count; $i++) {
        $inputObject = @($items[0..$i])

        foreach ($minimum in @(-1..$($inputObject.Count + 1))) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{inputObject = $inputObject; minimum = $minimum;}
                $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -Minimum $test.Data.in.minimum -OutVariable out | Out-Null} catch {$_}
                $test.Data.out = $out

                if ($minimum -le $inputObject.Count) {
                    Assert-Null ($test.Data.err)
                } else {
                    Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                    Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
                }

                Assert-True ($test.Data.out.Count -eq $test.Data.in.inputObject.Count)
                Assert-All @(0..$i) {param($index) $test.Data.in.inputObject[$index].Equals($test.Data.out[$index])}

                $pass = $true
            }
            finally {commitTestLogEntry $test $pass}
        }
    }

    if ($i -eq 0) {
        commitTestLogEntry (newTestLogEntry $testDescription)
        throw New-Object 'System.Exception' -ArgumentList @("No data for $testDescription")
    }
}

& {
    $testDescription = 'Assert-PipelineCount with pipeline containing multiple items'

    $items = @(
        'hello', 0, 1.0, $true, $false, @(), @('hi', $null, 'world'), @{}, (New-Object -TypeName 'System.Collections.ArrayList')
    )

    for ($i = 0; $i -lt $items.Count; $i++) {
        $inputObject = @($items[0..$i])

        foreach ($maximum in @(-1..$($inputObject.Count + 1))) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{inputObject = $inputObject; maximum = $maximum;}
                $test.Data.err = try {$test.Data.in.inputObject | Assert-PipelineCount -Maximum $test.Data.in.maximum -OutVariable out | Out-Null} catch {$_}
                $test.Data.out = $out

                if ($maximum -ge $inputObject.Count) {
                    Assert-Null ($test.Data.err)
                } else {
                    Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
                    Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-PipelineCount', [System.StringComparison]::OrdinalIgnoreCase))
                }

                if ($maximum -lt $inputObject.Count) {
                    Assert-True ($test.Data.out.Count -eq ([System.Math]::Max(0, $test.Data.in.maximum)))
                } else {
                    Assert-True ($test.Data.out.Count -eq $test.Data.in.inputObject.Count)
                    Assert-All @(0..$i) {param($index) $test.Data.in.inputObject[$index].Equals($test.Data.out[$index])}
                }

                $pass = $true
            }
            finally {commitTestLogEntry $test $pass}
        }
    }

    if ($i -eq 0) {
        commitTestLogEntry (newTestLogEntry $testDescription)
        throw New-Object 'System.Exception' -ArgumentList @("No data for $testDescription")
    }
}

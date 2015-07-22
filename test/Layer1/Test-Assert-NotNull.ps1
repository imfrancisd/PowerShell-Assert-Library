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
#>
[CmdletBinding()]
Param(
    #A data structure with an "Add" method that will be used to log tests.
    #
    #The data structure can be a simple ArrayList or a complicated custom object.
    #The advantage of using a custom object is that you have full control over the logging behavior, such as limiting the number of log entries.
    #
    #See the Notes section for examples.
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
function newTestLogEntry($testDescription)
{
    Write-Verbose -Message $testDescription -Verbose:$headerVerbosity
    $logEntry = New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
        File = $TestScriptFilePath
        Test = $testDescription
        Pass = $null
        Data = @{
            in  = $null #IDictionary (for named parameters) or IList (for arguments)
            out = $null #IList (one item per output, generated from -OutVariable parameter)
            err = $null #ErrorRecord from command that takes in and generates out
        }
    }
    if ($null -ne $Logger) {
        [System.Void]$Logger.Add($logEntry)
    }
    return $logEntry
}



$nonBooleanFalse = @(
    0, '', @($null), @(0), @(''), @($false), @(), @(,@())
)
$nonBooleanTrue = @(
    1, 'True', 'False', @(1), @('True'), @('False'), @($true), @(,@(1)), @(,@($true))
)

& {
    $test = newTestLogEntry 'Test Assert-NotNull with get-help -full'

    $test.Data.in  = @{name = 'Assert-NotNull'}
    $test.Data.err = try {Get-Help -Name $test.Data.in.name -Full -OutVariable out | Out-Null} catch {$_}
    $test.Data.out = $out

    $test.Pass =
        (Test-Null $test.Data.err) -and
        ($test.Data.out.Count -eq 1) -and
        ($test.Data.out[0].Name -is [System.String]) -and
        ($test.Data.out[0].Name.Equals('Assert-NotNull', [System.StringComparison]::OrdinalIgnoreCase)) -and
        ($test.Data.out[0].description -is [System.Collections.ICollection]) -and
        ($test.Data.out[0].description.Count -gt 0) -and
        ($null -ne $test.Data.out[0].examples) -and
        (0 -lt @($test.Data.out[0].examples.example).Count) -and
        ('' -ne @($test.Data.out[0].examples.example)[0].code)

    if (-not $test.Pass) {
        $message = 'Assert-NotNull failed with get-help -full.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    $test = newTestLogEntry 'Test Assert-NotNull parameters'

    $test.Data.in  = @{name = 'Assert-NotNull'}
    $test.Data.err = try {Get-Command -Name $test.Data.in.name -OutVariable out | Out-Null} catch {$_}
    $test.Data.out = $out

    if (Test-NotNull $test.Data.err) {
        $message = 'Assert-NotNull failed parameter tests (could not get command).'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }

    $paramSets = @($test.Data.out[0].ParameterSets)
    if (1 -ne $paramSets.Count) {
        $message = 'Assert-NotNull failed parameter tests (more than one parameter set).'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }

    $valueParam = $paramSets[0].Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
    if (Test-Null $valueParam) {
        $message = 'Assert-NotNull failed parameter tests (no parameter with name "Value").'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }

    $test.Pass =
        ($valueParam.IsMandatory) -and
        ($valueParam.ParameterType -eq [System.Object]) -and
        (-not $valueParam.ValueFromPipeline) -and
        (-not $valueParam.ValueFromPipelineByPropertyName) -and
        (-not $valueParam.ValueFromRemainingArguments) -and
        (0 -eq $valueParam.Position) -and
        (0 -eq $valueParam.Aliases.Count)

    if (-not $test.Pass) {
        $message = 'Assert-NotNull failed parameter tests ("Value" parameter attributes).'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    $test = newTestLogEntry 'Test Assert-NotNull with Boolean $true'

    $test.Data.in  = @{value = $true}
    $test.Data.err = try {Assert-NotNull $test.Data.in.value -OutVariable out | Out-Null} catch {$_}
    $test.Data.out = $out

    $test.Pass =
        (Test-Null $test.Data.err) -and
        ($test.Data.out.Count -eq 0)

    if (-not $test.Pass) {
        $message = 'Assert-NotNull failed with $true value.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    $test = newTestLogEntry 'Test Assert-NotNull with Boolean $false'

    $test.Data.in  = @{value = $false}
    $test.Data.err = try {Assert-NotNull $test.Data.in.value -OutVariable out | Out-Null} catch {$_}
    $test.Data.out = $out

    $test.Pass =
        (Test-Null $test.Data.err) -and
        ($test.Data.out.Count -eq 0)

    if (-not $test.Pass) {
        $message = 'Assert-NotNull failed with $false value.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    $test = newTestLogEntry 'Test Assert-NotNull with $null'

    $test.Data.in  = @{value = $null}
    $test.Data.err = try {Assert-NotNull $test.Data.in.value -OutVariable out | Out-Null} catch {$_}
    $test.Data.out = $out

    $test.Pass =
        ($test.Data.err -is [System.Management.Automation.ErrorRecord]) -and
        ($test.Data.err.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-NotNull', [System.StringComparison]::OrdinalIgnoreCase)) -and
        ($test.Data.out.Count -eq 0)

    if (-not $test.Pass) {
        $message = 'Assert-NotNull failed with $null value.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    for ($i = 0; $i -lt $nonBooleanTrue.Count; $i++) {
        $test = newTestLogEntry 'Test Assert-NotNull with Non-Boolean that is convertible to $true'

        $test.Data.in  = @{value = $nonBooleanTrue[$i]}
        $test.Data.err = try {Assert-NotNull $test.Data.in.value -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        $test.Pass =
            (Test-Null $test.Data.err) -and
            ($test.Data.out.Count -eq 0)

        if (-not $test.Pass) {
            $message = 'Assert-NotNull failed with Non-Boolean that is convertible to $true.'
            throw New-Object 'System.Exception' -ArgumentList @($message)
        }
    }

    if ($i -eq 0) {
        $test = newTestLogEntry 'Test Assert-NotNull with Non-Boolean that is convertible to $true'

        $message = 'No data to test Assert-NotNull with Non-Boolean that is convertible to $true.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    for ($i = 0; $i -lt $nonBooleanFalse.Count; $i++) {
        $test = newTestLogEntry 'Test Assert-NotNull with Non-Boolean that is convertible to $false'

        $test.Data.in  = @{value = $nonBooleanFalse[$i]}
        $test.Data.err = try {Assert-NotNull $test.Data.in.value -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        $test.Pass =
            (Test-Null $test.Data.err) -and
            ($test.Data.out.Count -eq 0)

        if (-not $test.Pass) {
            $message = 'Assert-NotNull failed with Non-Boolean that is convertible to $false.'
            throw New-Object 'System.Exception' -ArgumentList @($message)
        }
    }

    if ($i -eq 0) {
        $test = newTestLogEntry 'Test Assert-NotNull with Non-Boolean that is convertible to $false'

        $message = 'No data to test Assert-NotNull with Non-Boolean that is convertible to $false.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

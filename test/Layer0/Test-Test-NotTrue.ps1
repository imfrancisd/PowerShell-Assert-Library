#requires -version 2

<#
.Synopsis
Test the Test-NotTrue cmdlet.
.Description
Test the Test-NotTrue cmdlet.
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
.\test-test-nottrue.ps1 -logger $simpleLogger


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
.\test-test-nottrue.ps1 -logger $customLogger


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
        Pass = $false
        Data = @{}
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
    $test = newTestLogEntry 'Test Test-NotTrue with get-help -full'

    $test.Data.err = try {$test.Data.fullHelp = Get-Help Test-NotTrue -Full} catch {$_}

    $test.Pass =
        ($null -eq $test.Data.err) -and
        ($test.Data.fullHelp.Name -is [System.String]) -and
        ($test.Data.fullHelp.Name.Equals('Test-NotTrue', [System.StringComparison]::OrdinalIgnoreCase)) -and
        ($test.Data.fullHelp.description -is [System.Collections.ICollection]) -and
        ($test.Data.fullHelp.description.Count -gt 0) -and
        ($null -ne $test.Data.fullHelp.examples) -and
        (0 -lt @($test.Data.fullHelp.examples.example).Count) -and
        ('' -ne @($test.Data.fullHelp.examples.example)[0].code)

    if (-not $test.Pass) {
        $message = 'Test-NotTrue failed with get-help -full.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    $test = newTestLogEntry 'Test Test-NotTrue parameters'

    $message = 'Test-NotTrue failed parameter tests.'

    $test.Data.paramSets = @((Get-Command -Name Test-NotTrue).ParameterSets)
    if (1 -ne $test.Data.paramSets.Count) {
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }

    $test.Data.valueParam = $test.Data.paramSets[0].Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
    if ($null -eq $test.Data.valueParam) {
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }

    $test.Pass =
        ($test.Data.valueParam.IsMandatory) -and
        ($test.Data.valueParam.ParameterType -eq [System.Object]) -and
        (-not $test.Data.valueParam.ValueFromPipeline) -and
        (-not $test.Data.valueParam.ValueFromPipelineByPropertyName) -and
        (-not $test.Data.valueParam.ValueFromRemainingArguments) -and
        (0 -eq $test.Data.valueParam.Position) -and
        (0 -eq $test.Data.valueParam.Aliases.Count)

    if (-not $test.Pass) {
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    $test = newTestLogEntry 'Test Test-NotTrue with Boolean $true'

    $test.Data.err = try {Test-NotTrue $true -OutVariable out | Out-Null} catch {$_}
    $test.Data.out = $out

    $test.Pass =
        ($test.Data.out.Count -eq 1) -and
        ($test.Data.out[0] -is [System.Boolean]) -and
        (-not $test.Data.out[0]) -and
        ($null -eq $test.Data.err)

    if (-not $test.Pass) {
        $message = 'Test-NotTrue failed with $true value.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    $test = newTestLogEntry 'Test Test-NotTrue with Boolean $false'

    $test.Data.err = try {Test-NotTrue $false -OutVariable out | Out-Null} catch {$_}
    $test.Data.out = $out

    $test.Pass =
        ($test.Data.out.Count -eq 1) -and
        ($test.Data.out[0] -is [System.Boolean]) -and
        ($test.Data.out[0]) -and
        ($null -eq $test.Data.err)

    if (-not $test.Pass) {
        $message = 'Test-NotTrue failed with $false value.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    $test = newTestLogEntry 'Test Test-NotTrue with $null'

    $test.Data.err = try {Test-NotTrue $null -OutVariable out | Out-Null} catch {$_}
    $test.Data.out = $out

    $test.Pass =
        ($test.Data.out.Count -eq 1) -and
        ($test.Data.out[0] -is [System.Boolean]) -and
        ($test.Data.out[0]) -and
        ($null -eq $test.Data.err)

    if (-not $test.Pass) {
        $message = 'Test-NotTrue failed with $null value.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    $test = newTestLogEntry 'Test Test-NotTrue with Non-Booleans that are convertible to $true'
    $test.Data.err = [System.Array]::CreateInstance([System.Object], $nonBooleanTrue.Count)
    $test.Data.out = [System.Array]::CreateInstance([System.Object], $nonBooleanTrue.Count)

    for ($i = 0; $i -lt $nonBooleanTrue.Count; $i++) {
        $test.Data.err[$i] = try {Test-NotTrue $nonBooleanTrue[$i] -OutVariable out | Out-Null} catch {$_}
        $test.Data.out[$i] = $out

        $test.Pass =
            ($test.Data.out[$i].Count -eq 1) -and
            ($test.Data.out[$i][0] -is [System.Boolean]) -and
            ($test.Data.out[$i][0]) -and
            ($null -eq $test.Data.err[$i])

        if (-not $test.Pass) {
            break
        }
    }

    if (-not $test.Pass) {
        $message = 'Test-NotTrue failed with Non-Boolean that is convertible to $true.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    $test = newTestLogEntry 'Test Test-NotTrue with Non-Booleans that are convertible to $false'
    $test.Data.err = [System.Array]::CreateInstance([System.Object], $nonBooleanFalse.Count)
    $test.Data.out = [System.Array]::CreateInstance([System.Object], $nonBooleanFalse.Count)

    for ($i = 0; $i -lt $nonBooleanFalse.Count; $i++) {
        $test.Data.err[$i] = try {Test-NotTrue $nonBooleanFalse[$i] -OutVariable out | Out-Null} catch {$_}
        $test.Data.out[$i] = $out

        $test.Pass =
            ($test.Data.out[$i].Count -eq 1) -and
            ($test.Data.out[$i][0] -is [System.Boolean]) -and
            ($test.Data.out[$i][0]) -and
            ($null -eq $test.Data.err[$i])

        if (-not $test.Pass) {
            break
        }
    }

    if (-not $test.Pass) {
        $message = 'Test-NotTrue failed with Non-Boolean that is convertible to $false.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

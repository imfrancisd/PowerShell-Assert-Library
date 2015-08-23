#requires -version 2

<#
.Synopsis
Test the Group-ListItem cmdlet.
.Description
Test the Group-ListItem cmdlet.
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
.\Test-Group-ListItem.ps1 -logger $simpleLogger


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
.\Test-Group-ListItem.ps1 -logger $customLogger


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



function eq?([System.Object]$a, [System.Object]$b)
{
    [System.Object]::Equals($a, $b)
}
function eqListContents?([System.Collections.IList]$a, [System.Collections.IList]$b)
{
    (Test-NotNull $a) -and
    (Test-NotNull $b) -and
    (eq? $a.Count $b.Count) -and
    (Test-All @(iota $a.Count) {param($index) eq? $a[$index] $b[$index]})
}
function getEquivalentArrayType([System.Collections.IList]$list)
{
    #WARNING:
    #This function may not work as intended on all types that implement IList.
    #This function should work as intended on arrays and IList types defined
    #in System.Collections and System.Collections.Generic.

    $type = if (Test-Null $list) {[System.Void]} else {$list.GetType()}
    if ($type.IsArray) {
        $type
    } elseif ($type.IsGenericType) {
        [System.Type]::GetType("$($type.GetGenericArguments()[0].FullName)[]")
    } else {
        [System.Object[]]
    }
}
function iota([System.Int32]$count = 0, $start = 0, $step = 1)
{
    for (; $count -gt 0; $count--) {,$start; $start+=$step}
}
function missing?([System.Object]$a)
{
    [System.Reflection.Missing]::Value.Equals($a)
}

$listsWithLength0 = @(
    @(),
    (New-Object -TypeName 'System.Collections.ObjectModel.ReadOnlyCollection[System.String]' -ArgumentList (,[System.String[]]@())),
    [System.Int32[]]@(),
    (New-Object -TypeName 'System.Collections.ArrayList'),
    (New-Object -TypeName 'System.Collections.Generic.List[System.Double]')
)
$listsWithLength1 = @(
    @($null),
    (New-Object -TypeName 'System.Collections.ObjectModel.ReadOnlyCollection[System.String]' -ArgumentList (,[System.String[]]@('hi'))),
    [System.Int32[]]@(101),
    (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('hello world'))),
    (New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(3.14)))
)
$listsWithLength2 = @(
    @($null, 5),
    (New-Object -TypeName 'System.Collections.ObjectModel.ReadOnlyCollection[System.String]' -ArgumentList (,[System.String[]]@('hi', 'world'))),
    [System.Int32[]]@(101, 202),
    (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('Hello', 'World!'))),
    (New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(3.14, 2.72)))
)
$listsWithLength3 = @(
    @($null, 5, [System.DateTime]::UtcNow),
    (New-Object -TypeName 'System.Collections.ObjectModel.ReadOnlyCollection[System.String]' -ArgumentList (,[System.String[]]@('hi', 'world', '!'))),
    [System.Int32[]]@(101, 202, 303),
    (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('Hello', $null, 'World!'))),
    (New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(3.14, 2.72, 0.00)))
)
$listsWithLength4 = @(
    @($null, 5, [System.DateTime]::UtcNow, [System.Guid]::NewGuid()),
    (New-Object -TypeName 'System.Collections.ObjectModel.ReadOnlyCollection[System.String]' -ArgumentList (,[System.String[]]@('hi', 'world', '!', ''))),
    [System.Int32[]]@(101, 202, 303, 404),
    (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@('Hello', $null, 'World!', [System.String[]]@('how', 'are', 'you', 'today', '?')))),
    (New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(3.14, 2.72, 0.00, [System.Double]::Epsilon)))
)



& {
    $test = newTestLogEntry 'Group-ListItem help'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{name = 'Group-ListItem'}
        $test.Data.err = try {Get-Help -Name $test.Data.in.name -Full -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err
        Assert-True ($test.Data.out.Count -eq 1)
        Assert-True ($test.Data.out[0].Name -is [System.String])
        Assert-True ($test.Data.out[0].Name.Equals('Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase))
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
    $test = newTestLogEntry 'Group-ListItem parameters'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{name = 'Group-ListItem'; paramSet = 'Pair'}
        $test.Data.err = try {Get-Command -Name $test.Data.in.name -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err

        $paramSet = $test.Data.out[0].ParameterSets |
            Where-Object {$test.Data.in.paramSet.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $paramSet

        $pairParam = $paramSet.Parameters |
            Where-Object {'Pair'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $pairParam

        Assert-True ($pairParam.IsMandatory)
        Assert-True ($pairParam.ParameterType -eq [System.Collections.IList])
        Assert-False ($pairParam.ValueFromPipeline)
        Assert-False ($pairParam.ValueFromPipelineByPropertyName)
        Assert-False ($pairParam.ValueFromRemainingArguments)
        Assert-True (0 -gt $pairParam.Position)
        Assert-True (0 -eq $pairParam.Aliases.Count)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Group-ListItem parameters'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{name = 'Group-ListItem'; paramSet = 'Window'}
        $test.Data.err = try {Get-Command -Name $test.Data.in.name -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err

        $paramSet = $test.Data.out[0].ParameterSets |
            Where-Object {$test.Data.in.paramSet.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $paramSet

        $windowParam = $paramSet.Parameters |
            Where-Object {'Window'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $windowParam

        $sizeParam = $paramSet.Parameters |
            Where-Object {'Size'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $sizeParam

        Assert-True ($windowParam.IsMandatory)
        Assert-True ($windowParam.ParameterType -eq [System.Collections.IList])
        Assert-False ($windowParam.ValueFromPipeline)
        Assert-False ($windowParam.ValueFromPipelineByPropertyName)
        Assert-False ($windowParam.ValueFromRemainingArguments)
        Assert-True (0 -gt $windowParam.Position)
        Assert-True (0 -eq $windowParam.Aliases.Count)

        Assert-False ($sizeParam.IsMandatory)
        Assert-True ($sizeParam.ParameterType -eq [System.Int32])
        Assert-False ($sizeParam.ValueFromPipeline)
        Assert-False ($sizeParam.ValueFromPipelineByPropertyName)
        Assert-False ($sizeParam.ValueFromRemainingArguments)
        Assert-True (0 -gt $sizeParam.Position)
        Assert-True (0 -eq $sizeParam.Aliases.Count)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Group-ListItem parameters'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{name = 'Group-ListItem'; paramSet = 'RotateLeft'}
        $test.Data.err = try {Get-Command -Name $test.Data.in.name -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err

        $paramSet = $test.Data.out[0].ParameterSets |
            Where-Object {$test.Data.in.paramSet.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $paramSet

        $rotateLeftParam = $paramSet.Parameters |
            Where-Object {'RotateLeft'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $rotateLeftParam

        Assert-True ($rotateLeftParam.IsMandatory)
        Assert-True ($rotateLeftParam.ParameterType -eq [System.Collections.IList])
        Assert-False ($rotateLeftParam.ValueFromPipeline)
        Assert-False ($rotateLeftParam.ValueFromPipelineByPropertyName)
        Assert-False ($rotateLeftParam.ValueFromRemainingArguments)
        Assert-True (0 -gt $rotateLeftParam.Position)
        Assert-True (0 -eq $rotateLeftParam.Aliases.Count)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Group-ListItem parameters'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{name = 'Group-ListItem'; paramSet = 'RotateRight'}
        $test.Data.err = try {Get-Command -Name $test.Data.in.name -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err

        $paramSet = $test.Data.out[0].ParameterSets |
            Where-Object {$test.Data.in.paramSet.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $paramSet

        $rotateRightParam = $paramSet.Parameters |
            Where-Object {'RotateRight'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $rotateRightParam

        Assert-True ($rotateRightParam.IsMandatory)
        Assert-True ($rotateRightParam.ParameterType -eq [System.Collections.IList])
        Assert-False ($rotateRightParam.ValueFromPipeline)
        Assert-False ($rotateRightParam.ValueFromPipelineByPropertyName)
        Assert-False ($rotateRightParam.ValueFromRemainingArguments)
        Assert-True (0 -gt $rotateRightParam.Position)
        Assert-True (0 -eq $rotateRightParam.Aliases.Count)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Group-ListItem parameters'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{name = 'Group-ListItem'; paramSet = 'Combine'}
        $test.Data.err = try {Get-Command -Name $test.Data.in.name -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err

        $paramSet = $test.Data.out[0].ParameterSets |
            Where-Object {$test.Data.in.paramSet.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $paramSet

        $combineParam = $paramSet.Parameters |
            Where-Object {'Combine'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $combineParam

        $sizeParam = $paramSet.Parameters |
            Where-Object {'Size'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $sizeParam

        Assert-True ($combineParam.IsMandatory)
        Assert-True ($combineParam.ParameterType -eq [System.Collections.IList])
        Assert-False ($combineParam.ValueFromPipeline)
        Assert-False ($combineParam.ValueFromPipelineByPropertyName)
        Assert-False ($combineParam.ValueFromRemainingArguments)
        Assert-True (0 -gt $combineParam.Position)
        Assert-True (0 -eq $combineParam.Aliases.Count)

        Assert-False ($sizeParam.IsMandatory)
        Assert-True ($sizeParam.ParameterType -eq [System.Int32])
        Assert-False ($sizeParam.ValueFromPipeline)
        Assert-False ($sizeParam.ValueFromPipelineByPropertyName)
        Assert-False ($sizeParam.ValueFromRemainingArguments)
        Assert-True (0 -gt $sizeParam.Position)
        Assert-True (0 -eq $sizeParam.Aliases.Count)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Group-ListItem parameters'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{name = 'Group-ListItem'; paramSet = 'Permute'}
        $test.Data.err = try {Get-Command -Name $test.Data.in.name -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err

        $paramSet = $test.Data.out[0].ParameterSets |
            Where-Object {$test.Data.in.paramSet.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $paramSet

        $permuteParam = $paramSet.Parameters |
            Where-Object {'Permute'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $permuteParam

        $sizeParam = $paramSet.Parameters |
            Where-Object {'Size'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $sizeParam

        Assert-True ($permuteParam.IsMandatory)
        Assert-True ($permuteParam.ParameterType -eq [System.Collections.IList])
        Assert-False ($permuteParam.ValueFromPipeline)
        Assert-False ($permuteParam.ValueFromPipelineByPropertyName)
        Assert-False ($permuteParam.ValueFromRemainingArguments)
        Assert-True (0 -gt $permuteParam.Position)
        Assert-True (0 -eq $permuteParam.Aliases.Count)

        Assert-False ($sizeParam.IsMandatory)
        Assert-True ($sizeParam.ParameterType -eq [System.Int32])
        Assert-False ($sizeParam.ValueFromPipeline)
        Assert-False ($sizeParam.ValueFromPipelineByPropertyName)
        Assert-False ($sizeParam.ValueFromRemainingArguments)
        Assert-True (0 -gt $sizeParam.Position)
        Assert-True (0 -eq $sizeParam.Aliases.Count)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Group-ListItem parameters'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{name = 'Group-ListItem'; paramSet = 'Zip'}
        $test.Data.err = try {Get-Command -Name $test.Data.in.name -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err

        $paramSet = $test.Data.out[0].ParameterSets |
            Where-Object {$test.Data.in.paramSet.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $paramSet

        $zipParam = $paramSet.Parameters |
            Where-Object {'Zip'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $zipParam

        Assert-True ($zipParam.IsMandatory)
        Assert-True ($zipParam.ParameterType -eq [System.Collections.IList[]])
        Assert-False ($zipParam.ValueFromPipeline)
        Assert-False ($zipParam.ValueFromPipelineByPropertyName)
        Assert-False ($zipParam.ValueFromRemainingArguments)
        Assert-True (0 -gt $zipParam.Position)
        Assert-True (0 -eq $zipParam.Aliases.Count)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Group-ListItem parameters'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{name = 'Group-ListItem'; paramSet = 'CartesianProduct'}
        $test.Data.err = try {Get-Command -Name $test.Data.in.name -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err

        $paramSet = $test.Data.out[0].ParameterSets |
            Where-Object {$test.Data.in.paramSet.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $paramSet

        $cartesianProductParam = $paramSet.Parameters |
            Where-Object {'CartesianProduct'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $cartesianProductParam

        Assert-True ($cartesianProductParam.IsMandatory)
        Assert-True ($cartesianProductParam.ParameterType -eq [System.Collections.IList[]])
        Assert-False ($cartesianProductParam.ValueFromPipeline)
        Assert-False ($cartesianProductParam.ValueFromPipelineByPropertyName)
        Assert-False ($cartesianProductParam.ValueFromRemainingArguments)
        Assert-True (0 -gt $cartesianProductParam.Position)
        Assert-True (0 -eq $cartesianProductParam.Aliases.Count)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Group-ListItem parameters'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{name = 'Group-ListItem'; paramSet = 'CoveringArray'}
        $test.Data.err = try {Get-Command -Name $test.Data.in.name -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-Null $test.Data.err

        $paramSet = $test.Data.out[0].ParameterSets |
            Where-Object {$test.Data.in.paramSet.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $paramSet

        $coveringArrayParam = $paramSet.Parameters |
            Where-Object {'CoveringArray'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $coveringArrayParam

        $strengthParam = $paramSet.Parameters |
            Where-Object {'Strength'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
        Assert-NotNull $strengthParam

        Assert-True ($coveringArrayParam.IsMandatory)
        Assert-True ($coveringArrayParam.ParameterType -eq [System.Collections.IList[]])
        Assert-False ($coveringArrayParam.ValueFromPipeline)
        Assert-False ($coveringArrayParam.ValueFromPipelineByPropertyName)
        Assert-False ($coveringArrayParam.ValueFromRemainingArguments)
        Assert-True (0 -gt $coveringArrayParam.Position)
        Assert-True (0 -eq $coveringArrayParam.Aliases.Count)

        Assert-False ($strengthParam.IsMandatory)
        Assert-True ($strengthParam.ParameterType -eq [System.Int32])
        Assert-False ($strengthParam.ValueFromPipeline)
        Assert-False ($strengthParam.ValueFromPipelineByPropertyName)
        Assert-False ($strengthParam.ValueFromRemainingArguments)
        Assert-True (0 -gt $strengthParam.Position)
        Assert-True (0 -eq $strengthParam.Aliases.Count)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $test = newTestLogEntry 'Group-ListItem -Pair with null list'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{pair = $null}
        $test.Data.err = try {Group-ListItem -Pair $test.Data.in.pair -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('ParameterArgumentValidationErrorNullNotAllowed,Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.err.Exception.ParameterName.Equals('Pair', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $testDescription = 'Group-ListItem -Pair with list of length 0'

    for ($i = 0; $i -lt $listsWithLength0.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{pair = $listsWithLength0[$i]}
            $test.Data.err = try {Group-ListItem -Pair $test.Data.in.pair -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null ($test.Data.err)
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
    $testDescription = 'Group-ListItem -Pair with list of length 1'

    for ($i = 0; $i -lt $listsWithLength1.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{pair = $listsWithLength1[$i]}
            $test.Data.err = try {Group-ListItem -Pair $test.Data.in.pair -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null ($test.Data.err)
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
    $testDescription = 'Group-ListItem -Pair with list of length 2'

    for ($i = 0; $i -lt $listsWithLength2.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{pair = $listsWithLength2[$i]}

            $expectedType = getEquivalentArrayType $test.Data.in.pair
            $expectedPairs = @(,$test.Data.in.pair)

            $test.Data.err = try {Group-ListItem -Pair $test.Data.in.pair -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null ($test.Data.err)
            Assert-True (eq? $expectedPairs.Count $test.Data.out.Count)
            iota $expectedPairs.Count |
                Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedPairs[$row]} |
                Out-Null

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
    $testDescription = 'Group-ListItem -Pair with list of length 3'

    for ($i = 0; $i -lt $listsWithLength3.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{pair = $listsWithLength3[$i]}

            $expectedType = getEquivalentArrayType $test.Data.in.pair
            $expectedPairs = @(
                $test.Data.in.pair[0..1],
                $test.Data.in.pair[1..2]
            )

            $test.Data.err = try {Group-ListItem -Pair $test.Data.in.pair -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null ($test.Data.err)
            Assert-True (eq? $expectedPairs.Count $test.Data.out.Count)
            iota $expectedPairs.Count |
                Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedPairs[$row]} |
                Out-Null

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
    $testDescription = 'Group-ListItem -Pair with list of length 4'

    for ($i = 0; $i -lt $listsWithLength4.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{pair = $listsWithLength4[$i]}

            $expectedType = getEquivalentArrayType $test.Data.in.pair
            $expectedPairs = @(
                $test.Data.in.pair[0..1],
                $test.Data.in.pair[1..2],
                $test.Data.in.pair[2..3]
            )

            $test.Data.err = try {Group-ListItem -Pair $test.Data.in.pair -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null ($test.Data.err)
            Assert-True (eq? $expectedPairs.Count $test.Data.out.Count)
            iota $expectedPairs.Count |
                Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedPairs[$row]} |
                Out-Null

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
    $testDescription = 'Group-ListItem -Pair with list of length 5 or more'

    foreach ($len in @(5..9)) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{pair = [System.Int64[]]@(1..$len)}

            $expectedType = getEquivalentArrayType $test.Data.in.pair
            $expectedPairs = @(iota ($len - 1) | ForEach-Object {,$test.Data.in.pair[@(iota 2 -start $_)]})

            $test.Data.err = try {Group-ListItem -Pair $test.Data.in.pair -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null ($test.Data.err)
            Assert-True (eq? $expectedPairs.Count $test.Data.out.Count)
            iota $expectedPairs.Count |
                Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedPairs[$row]} |
                Out-Null

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }
}

& {
    $testDescription = 'Group-ListItem -Window with null list'

    foreach ($size in @(-1, 0, 1, [System.Reflection.Missing]::Value)) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{window = $null; size = $size;}

            if (missing? $size) {
                $test.Data.err = try {Group-ListItem -Window $test.Data.in.window -OutVariable out | Out-Null} catch {$_}
                $test.Data.out = $out
            } else {
                $test.Data.err = try {Group-ListItem -Window $test.Data.in.window -Size $test.Data.in.size -OutVariable out | Out-Null} catch {$_}
                $test.Data.out = $out
            }

            Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
            Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('ParameterArgumentValidationErrorNullNotAllowed,Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase))
            Assert-True ($test.Data.err.Exception.ParameterName.Equals('Window', [System.StringComparison]::OrdinalIgnoreCase))
            Assert-True ($test.Data.out.Count -eq 0)

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }
}

& {
    $testDescription = 'Group-ListItem -Window with list of length 0'

    for ($i = 0; $i -lt $listsWithLength0.Count; $i++) {
        $window = $listsWithLength0[$i]
        $expectedType = getEquivalentArrayType $window

        foreach ($size in @(-2, -1, 0, 1, 2, [System.Reflection.Missing]::Value)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{window = $window; size = $size;}

                if (missing? $size) {
                    $expectedWindows = @(,$test.Data.in.window)
                } elseif ($size -lt 0) {
                    $expectedWindows = @()
                } elseif ($size -eq 0) {
                    $expectedWindows = @(,@())
                } else {
                    $expectedWindows = @()
                }

                if (missing? $size) {
                    $test.Data.err = try {Group-ListItem -Window $test.Data.in.window -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                } else {
                    $test.Data.err = try {Group-ListItem -Window $test.Data.in.window -Size $test.Data.in.size -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                }

                Assert-Null ($test.Data.err)
                Assert-True (eq? $expectedWindows.Count $test.Data.out.Count)
                iota $expectedWindows.Count |
                    Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                    Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                    Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedWindows[$row]} |
                    Out-Null

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
    $testDescription = 'Group-ListItem -Window with list of length 1'

    for ($i = 0; $i -lt $listsWithLength1.Count; $i++) {
        $window = $listsWithLength1[$i]
        $expectedType = getEquivalentArrayType $window

        foreach ($size in @(-2, -1, 0, 1, 2, 3, [System.Reflection.Missing]::Value)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{window = $window; size = $size;}

                if ((missing? $size) -or ($size -eq 1)) {
                    $expectedWindows = @(,$test.Data.in.window)
                } elseif ($size -lt 0) {
                    $expectedWindows = @()
                } elseif ($size -eq 0) {
                    $expectedWindows = @(,@())
                } else {
                    $expectedWindows = @()
                }

                if (missing? $size) {
                    $test.Data.err = try {Group-ListItem -Window $test.Data.in.window -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                } else {
                    $test.Data.err = try {Group-ListItem -Window $test.Data.in.window -Size $test.Data.in.size -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                }

                Assert-Null ($test.Data.err)
                Assert-True (eq? $expectedWindows.Count $test.Data.out.Count)
                iota $expectedWindows.Count |
                    Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                    Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                    Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedWindows[$row]} |
                    Out-Null

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
    $testDescription = 'Group-ListItem -Window with list of length 2'

    for ($i = 0; $i -lt $listsWithLength2.Count; $i++) {
        $window = $listsWithLength2[$i]
        $expectedType = getEquivalentArrayType $window

        foreach ($size in @(-2, -1, 0, 1, 2, 3, 4, [System.Reflection.Missing]::Value)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{window = $window; size = $size;}

                if ((missing? $size) -or ($size -eq 2)) {
                    $expectedWindows = @(,$test.Data.in.window)
                } elseif ($size -lt 0) {
                    $expectedWindows = @()
                } elseif ($size -eq 0) {
                    $expectedWindows = @(,@())
                } elseif ($size -eq 1) {
                    $expectedWindows = @(
                        $test.Data.in.window[0..0],
                        $test.Data.in.window[1..1]
                    )
                } else {
                    $expectedWindows = @()
                }

                if (missing? $size) {
                    $test.Data.err = try {Group-ListItem -Window $test.Data.in.window -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                } else {
                    $test.Data.err = try {Group-ListItem -Window $test.Data.in.window -Size $test.Data.in.size -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                }

                Assert-Null ($test.Data.err)
                Assert-True (eq? $expectedWindows.Count $test.Data.out.Count)
                iota $expectedWindows.Count |
                    Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                    Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                    Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedWindows[$row]} |
                    Out-Null

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
    $testDescription = 'Group-ListItem -Window with list of length 3'

    for ($i = 0; $i -lt $listsWithLength3.Count; $i++) {
        $window = $listsWithLength3[$i]
        $expectedType = getEquivalentArrayType $window

        foreach ($size in @(-2, -1, 0, 1, 2, 3, 4, 5, [System.Reflection.Missing]::Value)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{window = $window; size = $size;}

                if ((missing? $size) -or ($size -eq 3)) {
                    $expectedWindows = @(,$test.Data.in.window)
                } elseif ($size -lt 0) {
                    $expectedWindows = @()
                } elseif ($size -eq 0) {
                    $expectedWindows = @(,@())
                } elseif ($size -eq 1) {
                    $expectedWindows = @(
                        $test.Data.in.window[0..0],
                        $test.Data.in.window[1..1],
                        $test.Data.in.window[2..2]
                    )
                } elseif ($size -eq 2) {
                    $expectedWindows = @(
                        $test.Data.in.window[0..1],
                        $test.Data.in.window[1..2]
                    )
                } else {
                    $expectedWindows = @()
                }

                if (missing? $size) {
                    $test.Data.err = try {Group-ListItem -Window $test.Data.in.window -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                } else {
                    $test.Data.err = try {Group-ListItem -Window $test.Data.in.window -Size $test.Data.in.size -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                }

                Assert-Null ($test.Data.err)
                Assert-True (eq? $expectedWindows.Count $test.Data.out.Count)
                iota $expectedWindows.Count |
                    Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                    Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                    Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedWindows[$row]} |
                    Out-Null

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
    $testDescription = 'Group-ListItem -Window with list of length 4'

    for ($i = 0; $i -lt $listsWithLength4.Count; $i++) {
        $window = $listsWithLength4[$i]
        $expectedType = getEquivalentArrayType $window

        foreach ($size in @(-2, -1, 0, 1, 2, 3, 4, 5, 6, [System.Reflection.Missing]::Value)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{window = $window; size = $size;}

                if ((missing? $size) -or ($size -eq 4)) {
                    $expectedWindows = @(,$test.Data.in.window)
                } elseif ($size -lt 0) {
                    $expectedWindows = @()
                } elseif ($size -eq 0) {
                    $expectedWindows = @(,@())
                } elseif ($size -eq 1) {
                    $expectedWindows = @(
                        $test.Data.in.window[0..0],
                        $test.Data.in.window[1..1],
                        $test.Data.in.window[2..2],
                        $test.Data.in.window[3..3]
                    )
                } elseif ($size -eq 2) {
                    $expectedWindows = @(
                        $test.Data.in.window[0..1],
                        $test.Data.in.window[1..2],
                        $test.Data.in.window[2..3]
                    )
                } elseif ($size -eq 3) {
                    $expectedWindows = @(
                        $test.Data.in.window[0..2],
                        $test.Data.in.window[1..3]
                    )
                } else {
                    $expectedWindows = @()
                }

                if (missing? $size) {
                    $test.Data.err = try {Group-ListItem -Window $test.Data.in.window -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                } else {
                    $test.Data.err = try {Group-ListItem -Window $test.Data.in.window -Size $test.Data.in.size -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                }

                Assert-Null ($test.Data.err)
                Assert-True (eq? $expectedWindows.Count $test.Data.out.Count)
                iota $expectedWindows.Count |
                    Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                    Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                    Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedWindows[$row]} |
                    Out-Null

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
    $testDescription = 'Group-ListItem -Window with list of length 5 or more'

    foreach ($len in @(5..9)) {
        $window = [System.Int64[]]@(1..$len)
        $expectedType = getEquivalentArrayType $window

        foreach ($size in @(-1..$($len + 1)) + @([System.Reflection.Missing]::Value)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{window = $window; size = $size;}

                if (missing? $size) {
                    $expectedWindows = @(,$test.Data.in.window)
                } elseif ($size -lt 0) {
                    $expectedWindows = @()
                } elseif ($size -eq 0) {
                    $expectedWindows = @(,@())
                } else {
                    $expectedWindows = @(iota ($len - $size + 1) | ForEach-Object {,$test.Data.in.window[@(iota $size -start $_)]})
                }

                if (missing? $size) {
                    $test.Data.err = try {Group-ListItem -Window $test.Data.in.window -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                } else {
                    $test.Data.err = try {Group-ListItem -Window $test.Data.in.window -Size $test.Data.in.size -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                }

                Assert-Null ($test.Data.err)
                Assert-True (eq? $expectedWindows.Count $test.Data.out.Count)
                iota $expectedWindows.Count |
                    Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                    Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                    Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedWindows[$row]} |
                    Out-Null

                $pass = $true
            }
            finally {commitTestLogEntry $test $pass}
        }
    }
}

& {
    $test = newTestLogEntry 'Group-ListItem -RotateLeft with null list'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{rotateLeft = $null}
        $test.Data.err = try {Group-ListItem -RotateLeft $test.Data.in.rotateLeft -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('ParameterArgumentValidationErrorNullNotAllowed,Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.err.Exception.ParameterName.Equals('RotateLeft', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $testDescription = 'Group-ListItem -RotateLeft with list of length 0'

    for ($i = 0; $i -lt $listsWithLength0.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{rotateLeft = $listsWithLength0[$i]}

            $expectedType = getEquivalentArrayType $test.Data.in.rotateLeft
            $expectedRotations = @(,$test.Data.in.rotateLeft)

            $test.Data.err = try {Group-ListItem -RotateLeft $test.Data.in.rotateLeft -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null ($test.Data.err)
            Assert-True (eq? $expectedRotations.Count $test.Data.out.Count)
            iota $expectedRotations.Count |
                Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedRotations[$row]} |
                Out-Null

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
    $testDescription = 'Group-ListItem -RotateLeft with list of length 1'

    for ($i = 0; $i -lt $listsWithLength1.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{rotateLeft = $listsWithLength1[$i]}

            $expectedType = getEquivalentArrayType $test.Data.in.rotateLeft
            $expectedRotations = @(,$test.Data.in.rotateLeft)

            $test.Data.err = try {Group-ListItem -RotateLeft $test.Data.in.rotateLeft -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null ($test.Data.err)
            Assert-True (eq? $expectedRotations.Count $test.Data.out.Count)
            iota $expectedRotations.Count |
                Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedRotations[$row]} |
                Out-Null

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
    $testDescription = 'Group-ListItem -RotateLeft with list of length 2'

    for ($i = 0; $i -lt $listsWithLength2.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{rotateLeft = $listsWithLength2[$i]}

            $expectedType = getEquivalentArrayType $test.Data.in.rotateLeft
            $expectedRotations = @(
                $test.Data.in.rotateLeft[0, 1],
                $test.Data.in.rotateLeft[1, 0]
            )

            $test.Data.err = try {Group-ListItem -RotateLeft $test.Data.in.rotateLeft -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null ($test.Data.err)
            Assert-True (eq? $expectedRotations.Count $test.Data.out.Count)
            iota $expectedRotations.Count |
                Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedRotations[$row]} |
                Out-Null

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
    $testDescription = 'Group-ListItem -RotateLeft with list of length 3'

    for ($i = 0; $i -lt $listsWithLength3.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{rotateLeft = $listsWithLength3[$i]}

            $expectedType = getEquivalentArrayType $test.Data.in.rotateLeft
            $expectedRotations = @(
                $test.Data.in.rotateLeft[0, 1, 2],
                $test.Data.in.rotateLeft[1, 2, 0],
                $test.Data.in.rotateLeft[2, 0, 1]
            )

            $test.Data.err = try {Group-ListItem -RotateLeft $test.Data.in.rotateLeft -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null ($test.Data.err)
            Assert-True (eq? $expectedRotations.Count $test.Data.out.Count)
            iota $expectedRotations.Count |
                Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedRotations[$row]} |
                Out-Null

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
    $testDescription = 'Group-ListItem -RotateLeft with list of length 4'

    for ($i = 0; $i -lt $listsWithLength4.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{rotateLeft = $listsWithLength4[$i]}

            $expectedType = getEquivalentArrayType $test.Data.in.rotateLeft
            $expectedRotations = @(
                $test.Data.in.rotateLeft[0, 1, 2, 3],
                $test.Data.in.rotateLeft[1, 2, 3, 0],
                $test.Data.in.rotateLeft[2, 3, 0, 1],
                $test.Data.in.rotateLeft[3, 0, 1, 2]
            )

            $test.Data.err = try {Group-ListItem -RotateLeft $test.Data.in.rotateLeft -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null ($test.Data.err)
            Assert-True (eq? $expectedRotations.Count $test.Data.out.Count)
            iota $expectedRotations.Count |
                Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedRotations[$row]} |
                Out-Null

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
    $testDescription = 'Group-ListItem -RotateLeft with list of length 5 or more'

    foreach ($len in @(5..9)) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{rotateLeft = [System.Int64[]]@(1..$len)}

            $expectedType = getEquivalentArrayType $test.Data.in.rotateLeft
            $expectedRotations = @(iota $len | ForEach-Object {,$test.Data.in.rotateLeft[@(iota $len -start $_ | ForEach-Object {$_ % $len})]})

            $test.Data.err = try {Group-ListItem -RotateLeft $test.Data.in.rotateLeft -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null ($test.Data.err)
            Assert-True (eq? $expectedRotations.Count $test.Data.out.Count)
            iota $expectedRotations.Count |
                Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedRotations[$row]} |
                Out-Null

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }
}

& {
    $test = newTestLogEntry 'Group-ListItem -RotateRight with null list'
    $pass = $false
    try {
        $test.Data.out = $out = @()
        $test.Data.in  = @{rotateRight = $null}
        $test.Data.err = try {Group-ListItem -RotateRight $test.Data.in.rotateRight -OutVariable out | Out-Null} catch {$_}
        $test.Data.out = $out

        Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
        Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('ParameterArgumentValidationErrorNullNotAllowed,Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.err.Exception.ParameterName.Equals('RotateRight', [System.StringComparison]::OrdinalIgnoreCase))
        Assert-True ($test.Data.out.Count -eq 0)

        $pass = $true
    }
    finally {commitTestLogEntry $test $pass}
}

& {
    $testDescription = 'Group-ListItem -RotateRight with list of length 0'

    for ($i = 0; $i -lt $listsWithLength0.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{rotateRight = $listsWithLength0[$i]}

            $expectedType = getEquivalentArrayType $test.Data.in.rotateRight
            $expectedRotations = @(,$test.Data.in.rotateRight)

            $test.Data.err = try {Group-ListItem -RotateRight $test.Data.in.rotateRight -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null ($test.Data.err)
            Assert-True (eq? $expectedRotations.Count $test.Data.out.Count)
            iota $expectedRotations.Count |
                Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedRotations[$row]} |
                Out-Null

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
    $testDescription = 'Group-ListItem -RotateRight with list of length 1'

    for ($i = 0; $i -lt $listsWithLength1.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{rotateRight = $listsWithLength1[$i]}

            $expectedType = getEquivalentArrayType $test.Data.in.rotateRight
            $expectedRotations = @(,$test.Data.in.rotateRight)

            $test.Data.err = try {Group-ListItem -RotateRight $test.Data.in.rotateRight -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null ($test.Data.err)
            Assert-True (eq? $expectedRotations.Count $test.Data.out.Count)
            iota $expectedRotations.Count |
                Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedRotations[$row]} |
                Out-Null

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
    $testDescription = 'Group-ListItem -RotateRight with list of length 2'

    for ($i = 0; $i -lt $listsWithLength2.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{rotateRight = $listsWithLength2[$i]}

            $expectedType = getEquivalentArrayType $test.Data.in.rotateRight
            $expectedRotations = @(
                $test.Data.in.rotateRight[0, 1],
                $test.Data.in.rotateRight[1, 0]
            )

            $test.Data.err = try {Group-ListItem -RotateRight $test.Data.in.rotateRight -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null ($test.Data.err)
            Assert-True (eq? $expectedRotations.Count $test.Data.out.Count)
            iota $expectedRotations.Count |
                Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedRotations[$row]} |
                Out-Null

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
    $testDescription = 'Group-ListItem -RotateRight with list of length 3'

    for ($i = 0; $i -lt $listsWithLength3.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{rotateRight = $listsWithLength3[$i]}

            $expectedType = getEquivalentArrayType $test.Data.in.rotateRight
            $expectedRotations = @(
                $test.Data.in.rotateRight[0, 1, 2],
                $test.Data.in.rotateRight[2, 0, 1],
                $test.Data.in.rotateRight[1, 2, 0]
            )

            $test.Data.err = try {Group-ListItem -RotateRight $test.Data.in.rotateRight -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null ($test.Data.err)
            Assert-True (eq? $expectedRotations.Count $test.Data.out.Count)
            iota $expectedRotations.Count |
                Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedRotations[$row]} |
                Out-Null

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
    $testDescription = 'Group-ListItem -RotateRight with list of length 4'

    for ($i = 0; $i -lt $listsWithLength4.Count; $i++) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{rotateRight = $listsWithLength4[$i]}

            $expectedType = getEquivalentArrayType $test.Data.in.rotateRight
            $expectedRotations = @(
                $test.Data.in.rotateRight[0, 1, 2, 3],
                $test.Data.in.rotateRight[3, 0, 1, 2],
                $test.Data.in.rotateRight[2, 3, 0, 1],
                $test.Data.in.rotateRight[1, 2, 3, 0]
            )

            $test.Data.err = try {Group-ListItem -RotateRight $test.Data.in.rotateRight -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null ($test.Data.err)
            Assert-True (eq? $expectedRotations.Count $test.Data.out.Count)
            iota $expectedRotations.Count |
                Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedRotations[$row]} |
                Out-Null

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
    $testDescription = 'Group-ListItem -RotateRight with list of length 5 or more'

    foreach ($len in @(5..9)) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{rotateRight = [System.Int64[]]@(1..$len)}

            $expectedType = getEquivalentArrayType $test.Data.in.rotateRight
            $expectedRotations = @(iota $len -start $len -step (-1) | ForEach-Object {,$test.Data.in.rotateRight[@(iota $len -start $_ | ForEach-Object {$_ % $len})]})

            $test.Data.err = try {Group-ListItem -RotateRight $test.Data.in.rotateRight -OutVariable out | Out-Null} catch {$_}
            $test.Data.out = $out

            Assert-Null ($test.Data.err)
            Assert-True (eq? $expectedRotations.Count $test.Data.out.Count)
            iota $expectedRotations.Count |
                Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedRotations[$row]} |
                Out-Null

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }
}

& {
    $testDescription = 'Group-ListItem -Combine with null list'

    foreach ($size in @(-1, 0, 1, [System.Reflection.Missing]::Value)) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{combine = $null; size = $size;}

            if (missing? $size) {
                $test.Data.err = try {Group-ListItem -Combine $test.Data.in.combine -OutVariable out | Out-Null} catch {$_}
                $test.Data.out = $out
            } else {
                $test.Data.err = try {Group-ListItem -Combine $test.Data.in.combine -Size $test.Data.in.size -OutVariable out | Out-Null} catch {$_}
                $test.Data.out = $out
            }

            Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
            Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('ParameterArgumentValidationErrorNullNotAllowed,Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase))
            Assert-True ($test.Data.err.Exception.ParameterName.Equals('Combine', [System.StringComparison]::OrdinalIgnoreCase))
            Assert-True ($test.Data.out.Count -eq 0)

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }
}

& {
    $testDescription = 'Group-ListItem -Combine with list of length 0'

    for ($i = 0; $i -lt $listsWithLength0.Count; $i++) {
        $combine = $listsWithLength0[$i]
        $expectedType = getEquivalentArrayType $combine

        foreach ($size in @(-2, -1, 0, 1, 2, [System.Reflection.Missing]::Value)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{combine = $combine; size = $size;}

                if (missing? $size) {
                    $expectedCombinations = @(,$test.Data.in.combine)
                } elseif ($size -lt 0) {
                    $expectedCombinations = @()
                } elseif ($size -eq 0) {
                    $expectedCombinations = @(,@())
                } else {
                    $expectedCombinations = @()
                }

                if (missing? $size) {
                    $test.Data.err = try {Group-ListItem -Combine $test.Data.in.combine -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                } else {
                    $test.Data.err = try {Group-ListItem -Combine $test.Data.in.combine -Size $test.Data.in.size -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                }

                Assert-Null ($test.Data.err)
                Assert-True (eq? $expectedCombinations.Count $test.Data.out.Count)
                iota $expectedCombinations.Count |
                    Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                    Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                    Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedCombinations[$row]} |
                    Out-Null

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
    $testDescription = 'Group-ListItem -Combine with list of length 1'

    for ($i = 0; $i -lt $listsWithLength1.Count; $i++) {
        $combine = $listsWithLength1[$i]
        $expectedType = getEquivalentArrayType $combine

        foreach ($size in @(-2, -1, 0, 1, 2, 3, [System.Reflection.Missing]::Value)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{combine = $combine; size = $size;}

                if ((missing? $size) -or ($size -eq 1)) {
                    $expectedCombinations = @(,$test.Data.in.combine)
                } elseif ($size -lt 0) {
                    $expectedCombinations = @()
                } elseif ($size -eq 0) {
                    $expectedCombinations = @(,@())
                } else {
                    $expectedCombinations = @()
                }

                if (missing? $size) {
                    $test.Data.err = try {Group-ListItem -Combine $test.Data.in.combine -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                } else {
                    $test.Data.err = try {Group-ListItem -Combine $test.Data.in.combine -Size $test.Data.in.size -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                }

                Assert-Null ($test.Data.err)
                Assert-True (eq? $expectedCombinations.Count $test.Data.out.Count)
                iota $expectedCombinations.Count |
                    Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                    Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                    Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedCombinations[$row]} |
                    Out-Null

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
    $testDescription = 'Group-ListItem -Combine with list of length 2'

    for ($i = 0; $i -lt $listsWithLength2.Count; $i++) {
        $combine = $listsWithLength2[$i]
        $expectedType = getEquivalentArrayType $combine

        foreach ($size in @(-2, -1, 0, 1, 2, 3, 4, [System.Reflection.Missing]::Value)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{combine = $combine; size = $size;}

                if ((missing? $size) -or ($size -eq 2)) {
                    $expectedCombinations = @(,$test.Data.in.combine)
                } elseif ($size -lt 0) {
                    $expectedCombinations = @()
                } elseif ($size -eq 0) {
                    $expectedCombinations = @(,@())
                } elseif ($size -eq 1) {
                    $expectedCombinations = @(
                        $test.Data.in.combine[,0],
                        $test.Data.in.combine[,1]
                    )
                } else {
                    $expectedCombinations = @()
                }

                if (missing? $size) {
                    $test.Data.err = try {Group-ListItem -Combine $test.Data.in.combine -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                } else {
                    $test.Data.err = try {Group-ListItem -Combine $test.Data.in.combine -Size $test.Data.in.size -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                }

                Assert-Null ($test.Data.err)
                Assert-True (eq? $expectedCombinations.Count $test.Data.out.Count)
                iota $expectedCombinations.Count |
                    Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                    Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                    Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedCombinations[$row]} |
                    Out-Null

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
    $testDescription = 'Group-ListItem -Combine with list of length 3'

    for ($i = 0; $i -lt $listsWithLength3.Count; $i++) {
        $combine = $listsWithLength3[$i]
        $expectedType = getEquivalentArrayType $combine

        foreach ($size in @(-2, -1, 0, 1, 2, 3, 4, 5, [System.Reflection.Missing]::Value)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{combine = $combine; size = $size;}

                if ((missing? $size) -or ($size -eq 3)) {
                    $expectedCombinations = @(,$test.Data.in.combine)
                } elseif ($size -lt 0) {
                    $expectedCombinations = @()
                } elseif ($size -eq 0) {
                    $expectedCombinations = @(,@())
                } elseif ($size -eq 1) {
                    $expectedCombinations = @(
                        $test.Data.in.combine[,0],
                        $test.Data.in.combine[,1],
                        $test.Data.in.combine[,2]
                    )
                } elseif ($size -eq 2) {
                    $expectedCombinations = @(
                        $test.Data.in.combine[0, 1],
                        $test.Data.in.combine[0, 2],
                        $test.Data.in.combine[1, 2]
                    )
                } else {
                    $expectedCombinations = @()
                }

                if (missing? $size) {
                    $test.Data.err = try {Group-ListItem -Combine $test.Data.in.combine -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                } else {
                    $test.Data.err = try {Group-ListItem -Combine $test.Data.in.combine -Size $test.Data.in.size -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                }

                Assert-Null ($test.Data.err)
                Assert-True (eq? $expectedCombinations.Count $test.Data.out.Count)
                iota $expectedCombinations.Count |
                    Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                    Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                    Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedCombinations[$row]} |
                    Out-Null

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
    $testDescription = 'Group-ListItem -Combine with list of length 4'

    for ($i = 0; $i -lt $listsWithLength4.Count; $i++) {
        $combine = $listsWithLength4[$i]
        $expectedType = getEquivalentArrayType $combine

        foreach ($size in @(-2, -1, 0, 1, 2, 3, 4, 5, 6, [System.Reflection.Missing]::Value)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{combine = $combine; size = $size;}

                if ((missing? $size) -or ($size -eq 4)) {
                    $expectedCombinations = @(,$test.Data.in.combine)
                } elseif ($size -lt 0) {
                    $expectedCombinations = @()
                } elseif ($size -eq 0) {
                    $expectedCombinations = @(,@())
                } elseif ($size -eq 1) {
                    $expectedCombinations = @(
                        $test.Data.in.combine[,0],
                        $test.Data.in.combine[,1],
                        $test.Data.in.combine[,2],
                        $test.Data.in.combine[,3]
                    )
                } elseif ($size -eq 2) {
                    $expectedCombinations = @(
                        $test.Data.in.combine[0, 1],
                        $test.Data.in.combine[0, 2],
                        $test.Data.in.combine[0, 3],
                        $test.Data.in.combine[1, 2],
                        $test.Data.in.combine[1, 3],
                        $test.Data.in.combine[2, 3]
                    )
                } elseif ($size -eq 3) {
                    $expectedCombinations = @(
                        $test.Data.in.combine[0, 1, 2],
                        $test.Data.in.combine[0, 1, 3],
                        $test.Data.in.combine[0, 2, 3],
                        $test.Data.in.combine[1, 2, 3]
                    )
                } else {
                    $expectedCombinations = @()
                }

                if (missing? $size) {
                    $test.Data.err = try {Group-ListItem -Combine $test.Data.in.combine -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                } else {
                    $test.Data.err = try {Group-ListItem -Combine $test.Data.in.combine -Size $test.Data.in.size -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                }

                Assert-Null ($test.Data.err)
                Assert-True (eq? $expectedCombinations.Count $test.Data.out.Count)
                iota $expectedCombinations.Count |
                    Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                    Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                    Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedCombinations[$row]} |
                    Out-Null

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
    $testDescription = 'Group-ListItem -Combine with list of length 5 or more'

    function numCombin($n, $k)
    {
        if ($n -lt $k) {
            return 0
        } elseif ($k -lt 0) {
            return 0
        } elseif ($k -eq 0) {
            return 1
        } elseif ($n -eq $k) {
            return 1
        } else {
            $num = 1
            $den = 1
            $($n - $k + 1)..$n | ForEach-Object {$num *= $_}
            1..$k | ForEach-Object {$den *= $_}
            return $num / $den
        }
    }

    foreach ($len in @(5..7)) {
        $combine = [System.Int64[]]@(1..$len)
        $expectedType = getEquivalentArrayType $combine

        foreach ($size in @(-1..$($len + 1)) + @([System.Reflection.Missing]::Value)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{combine = $combine; size = $size;}

                if (missing? $size) {
                    $expectedCombinationSize = $test.Data.in.combine.Count
                    $expectedCombinationCount = numCombin $len $expectedCombinationSize

                    $test.Data.err = try {Group-ListItem -Combine $test.Data.in.combine -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                } else {
                    $expectedCombinationSize = $size
                    $expectedCombinationCount = numCombin $len $expectedCombinationSize

                    $test.Data.err = try {Group-ListItem -Combine $test.Data.in.combine -Size $test.Data.in.size -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                }

                Assert-Null ($test.Data.err)
                Assert-True (eq? $expectedCombinationCount $test.Data.out.Count)
                iota $expectedCombinationCount |
                    Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                    Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                    Assert-PipelineAll {param($row) eq? $test.Data.out[$row].Items.Count $expectedCombinationSize} |
                    Out-Null

                $pass = $true
            }
            finally {commitTestLogEntry $test $pass}
        }
    }
}

& {
    $testDescription = 'Group-ListItem -Permute with null list'

    foreach ($size in @(-1, 0, 1, [System.Reflection.Missing]::Value)) {
        $test = newTestLogEntry $testDescription
        $pass = $false
        try {
            $test.Data.out = $out = @()
            $test.Data.in  = @{permute = $null; size = $size;}

            if (missing? $size) {
                $test.Data.err = try {Group-ListItem -Permute $test.Data.in.permute -OutVariable out | Out-Null} catch {$_}
                $test.Data.out = $out
            } else {
                $test.Data.err = try {Group-ListItem -Permute $test.Data.in.permute -Size $test.Data.in.size -OutVariable out | Out-Null} catch {$_}
                $test.Data.out = $out
            }

            Assert-True ($test.Data.err -is [System.Management.Automation.ErrorRecord])
            Assert-True ($test.Data.err.FullyQualifiedErrorId.Equals('ParameterArgumentValidationErrorNullNotAllowed,Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase))
            Assert-True ($test.Data.err.Exception.ParameterName.Equals('Permute', [System.StringComparison]::OrdinalIgnoreCase))
            Assert-True ($test.Data.out.Count -eq 0)

            $pass = $true
        }
        finally {commitTestLogEntry $test $pass}
    }
}

& {
    $testDescription = 'Group-ListItem -Permute with list of length 0'

    for ($i = 0; $i -lt $listsWithLength0.Count; $i++) {
        $permute = $listsWithLength0[$i]
        $expectedType = getEquivalentArrayType $permute

        foreach ($size in @(-2, -1, 0, 1, 2, [System.Reflection.Missing]::Value)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{permute = $permute; size = $size;}

                if (missing? $size) {
                    $expectedPermutations = @(,$test.Data.in.permute)
                } elseif ($size -lt 0) {
                    $expectedPermutations = @()
                } elseif ($size -eq 0) {
                    $expectedPermutations = @(,@())
                } else {
                    $expectedPermutations = @()
                }

                if (missing? $size) {
                    $test.Data.err = try {Group-ListItem -Permute $test.Data.in.permute -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                } else {
                    $test.Data.err = try {Group-ListItem -Permute $test.Data.in.permute -Size $test.Data.in.size -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                }

                Assert-Null ($test.Data.err)
                Assert-True (eq? $expectedPermutations.Count $test.Data.out.Count)
                iota $expectedPermutations.Count |
                    Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                    Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                    Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedPermutations[$row]} |
                    Out-Null

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
    $testDescription = 'Group-ListItem -Permute with list of length 1'

    for ($i = 0; $i -lt $listsWithLength1.Count; $i++) {
        $permute = $listsWithLength1[$i]
        $expectedType = getEquivalentArrayType $permute

        foreach ($size in @(-2, -1, 0, 1, 2, 3, [System.Reflection.Missing]::Value)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{permute = $permute; size = $size;}

                if ((missing? $size) -or ($size -eq 1)) {
                    $expectedPermutations = @(,$test.Data.in.permute)
                } elseif ($size -lt 0) {
                    $expectedPermutations = @()
                } elseif ($size -eq 0) {
                    $expectedPermutations = @(,@())
                } else {
                    $expectedPermutations = @()
                }

                if (missing? $size) {
                    $test.Data.err = try {Group-ListItem -Permute $test.Data.in.permute -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                } else {
                    $test.Data.err = try {Group-ListItem -Permute $test.Data.in.permute -Size $test.Data.in.size -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                }

                Assert-Null ($test.Data.err)
                Assert-True (eq? $expectedPermutations.Count $test.Data.out.Count)
                iota $expectedPermutations.Count |
                    Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                    Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                    Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedPermutations[$row]} |
                    Out-Null

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
    $testDescription = 'Group-ListItem -Permute with list of length 2'

    for ($i = 0; $i -lt $listsWithLength2.Count; $i++) {
        $permute = $listsWithLength2[$i]
        $expectedType = getEquivalentArrayType $permute

        foreach ($size in @(-2, -1, 0, 1, 2, 3, 4, [System.Reflection.Missing]::Value)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{permute = $permute; size = $size;}

                if ((missing? $size) -or ($size -eq 2)) {
                    $expectedPermutations = @(
                        $test.Data.in.permute[0, 1],
                        $test.Data.in.permute[1, 0]
                    )
                } elseif ($size -lt 0) {
                    $expectedPermutations = @()
                } elseif ($size -eq 0) {
                    $expectedPermutations = @(,@())
                } elseif ($size -eq 1) {
                    $expectedPermutations = @(
                        $test.Data.in.permute[,0],
                        $test.Data.in.permute[,1]
                    )
                } else {
                    $expectedPermutations = @()
                }

                if (missing? $size) {
                    $test.Data.err = try {Group-ListItem -Permute $test.Data.in.permute -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                } else {
                    $test.Data.err = try {Group-ListItem -Permute $test.Data.in.permute -Size $test.Data.in.size -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                }

                Assert-Null ($test.Data.err)
                Assert-True (eq? $expectedPermutations.Count $test.Data.out.Count)
                iota $expectedPermutations.Count |
                    Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                    Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                    Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedPermutations[$row]} |
                    Out-Null

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
    $testDescription = 'Group-ListItem -Permute with list of length 3'

    for ($i = 0; $i -lt $listsWithLength3.Count; $i++) {
        $permute = $listsWithLength3[$i]
        $expectedType = getEquivalentArrayType $permute

        foreach ($size in @(-2, -1, 0, 1, 2, 3, 4, 5, [System.Reflection.Missing]::Value)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{permute = $permute; size = $size;}

                if ((missing? $size) -or ($size -eq 3)) {
                    $expectedPermutations = @(
                        $test.Data.in.permute[0, 1, 2],
                        $test.Data.in.permute[0, 2, 1],
                        $test.Data.in.permute[1, 0, 2],
                        $test.Data.in.permute[1, 2, 0],
                        $test.Data.in.permute[2, 0, 1],
                        $test.Data.in.permute[2, 1, 0]
                    )
                } elseif ($size -lt 0) {
                    $expectedPermutations = @()
                } elseif ($size -eq 0) {
                    $expectedPermutations = @(,@())
                } elseif ($size -eq 1) {
                    $expectedPermutations = @(
                        $test.Data.in.permute[,0],
                        $test.Data.in.permute[,1],
                        $test.Data.in.permute[,2]
                    )
                } elseif ($size -eq 2) {
                    $expectedPermutations = @(
                        $test.Data.in.permute[0, 1],
                        $test.Data.in.permute[0, 2],
                        $test.Data.in.permute[1, 0],
                        $test.Data.in.permute[1, 2],
                        $test.Data.in.permute[2, 0],
                        $test.Data.in.permute[2, 1]
                    )
                } else {
                    $expectedPermutations = @()
                }

                if (missing? $size) {
                    $test.Data.err = try {Group-ListItem -Permute $test.Data.in.permute -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                } else {
                    $test.Data.err = try {Group-ListItem -Permute $test.Data.in.permute -Size $test.Data.in.size -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                }

                Assert-Null ($test.Data.err)
                Assert-True (eq? $expectedPermutations.Count $test.Data.out.Count)
                iota $expectedPermutations.Count |
                    Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                    Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                    Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedPermutations[$row]} |
                    Out-Null

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
    $testDescription = 'Group-ListItem -Permute with list of length 4'

    for ($i = 0; $i -lt $listsWithLength4.Count; $i++) {
        $permute = $listsWithLength4[$i]
        $expectedType = getEquivalentArrayType $permute

        foreach ($size in @(-2, -1, 0, 1, 2, 3, 4, 5, 6, [System.Reflection.Missing]::Value)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{permute = $permute; size = $size;}

                if ((missing? $size) -or ($size -eq 4)) {
                    $expectedPermutations = @(
                        $test.Data.in.permute[0, 1, 2, 3],
                        $test.Data.in.permute[0, 1, 3, 2],
                        $test.Data.in.permute[0, 2, 1, 3],
                        $test.Data.in.permute[0, 2, 3, 1],
                        $test.Data.in.permute[0, 3, 1, 2],
                        $test.Data.in.permute[0, 3, 2, 1],
                        $test.Data.in.permute[1, 0, 2, 3],
                        $test.Data.in.permute[1, 0, 3, 2],
                        $test.Data.in.permute[1, 2, 0, 3],
                        $test.Data.in.permute[1, 2, 3, 0],
                        $test.Data.in.permute[1, 3, 0, 2],
                        $test.Data.in.permute[1, 3, 2, 0],
                        $test.Data.in.permute[2, 0, 1, 3],
                        $test.Data.in.permute[2, 0, 3, 1],
                        $test.Data.in.permute[2, 1, 0, 3],
                        $test.Data.in.permute[2, 1, 3, 0],
                        $test.Data.in.permute[2, 3, 0, 1],
                        $test.Data.in.permute[2, 3, 1, 0],
                        $test.Data.in.permute[3, 0, 1, 2],
                        $test.Data.in.permute[3, 0, 2, 1],
                        $test.Data.in.permute[3, 1, 0, 2],
                        $test.Data.in.permute[3, 1, 2, 0],
                        $test.Data.in.permute[3, 2, 0, 1],
                        $test.Data.in.permute[3, 2, 1, 0]
                    )
                } elseif ($size -lt 0) {
                    $expectedPermutations = @()
                } elseif ($size -eq 0) {
                    $expectedPermutations = @(,@())
                } elseif ($size -eq 1) {
                    $expectedPermutations = @(
                        $test.Data.in.permute[,0],
                        $test.Data.in.permute[,1],
                        $test.Data.in.permute[,2],
                        $test.Data.in.permute[,3]
                    )
                } elseif ($size -eq 2) {
                    $expectedPermutations = @(
                        $test.Data.in.permute[0, 1],
                        $test.Data.in.permute[0, 2],
                        $test.Data.in.permute[0, 3],
                        $test.Data.in.permute[1, 0],
                        $test.Data.in.permute[1, 2],
                        $test.Data.in.permute[1, 3],
                        $test.Data.in.permute[2, 0],
                        $test.Data.in.permute[2, 1],
                        $test.Data.in.permute[2, 3],
                        $test.Data.in.permute[3, 0],
                        $test.Data.in.permute[3, 1],
                        $test.Data.in.permute[3, 2]
                    )
                } elseif ($size -eq 3) {
                    $expectedPermutations = @(
                        $test.Data.in.permute[0, 1, 2],
                        $test.Data.in.permute[0, 1, 3],
                        $test.Data.in.permute[0, 2, 1],
                        $test.Data.in.permute[0, 2, 3],
                        $test.Data.in.permute[0, 3, 1],
                        $test.Data.in.permute[0, 3, 2],
                        $test.Data.in.permute[1, 0, 2],
                        $test.Data.in.permute[1, 0, 3],
                        $test.Data.in.permute[1, 2, 0],
                        $test.Data.in.permute[1, 2, 3],
                        $test.Data.in.permute[1, 3, 0],
                        $test.Data.in.permute[1, 3, 2],
                        $test.Data.in.permute[2, 0, 1],
                        $test.Data.in.permute[2, 0, 3],
                        $test.Data.in.permute[2, 1, 0],
                        $test.Data.in.permute[2, 1, 3],
                        $test.Data.in.permute[2, 3, 0],
                        $test.Data.in.permute[2, 3, 1],
                        $test.Data.in.permute[3, 0, 1],
                        $test.Data.in.permute[3, 0, 2],
                        $test.Data.in.permute[3, 1, 0],
                        $test.Data.in.permute[3, 1, 2],
                        $test.Data.in.permute[3, 2, 0],
                        $test.Data.in.permute[3, 2, 1]
                    )
                } else {
                    $expectedPermutations = @()
                }

                if (missing? $size) {
                    $test.Data.err = try {Group-ListItem -Permute $test.Data.in.permute -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                } else {
                    $test.Data.err = try {Group-ListItem -Permute $test.Data.in.permute -Size $test.Data.in.size -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                }

                Assert-Null ($test.Data.err)
                Assert-True (eq? $expectedPermutations.Count $test.Data.out.Count)
                iota $expectedPermutations.Count |
                    Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                    Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                    Assert-PipelineAll {param($row) eqListContents? $test.Data.out[$row].Items $expectedPermutations[$row]} |
                    Out-Null

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
    $testDescription = 'Group-ListItem -Permute with list of length 5 or more'

    function numPermut($n, $k)
    {
        if ($n -lt $k) {
            return 0
        } elseif ($k -lt 0) {
            return 0
        } elseif ($k -eq 0) {
            return 1
        } elseif ($n -eq $k) {
            $num = 1
            1..$n | ForEach-Object {$num *= $_}
            return $num
        } else {
            $num = 1
            $($n - $k + 1)..$n | ForEach-Object {$num *= $_}
            return $num
        }
    }

    foreach ($len in @(5..7)) {
        $permute = [System.Int64[]]@(1..$len)
        $expectedType = getEquivalentArrayType $permute

        foreach ($size in @(-1..$($len + 1)) + @([System.Reflection.Missing]::Value)) {
            $test = newTestLogEntry $testDescription
            $pass = $false
            try {
                $test.Data.out = $out = @()
                $test.Data.in  = @{permute = $permute; size = $size;}

                if (missing? $size) {
                    $expectedPermutationSize = $test.Data.in.permute.Count
                    $expectedPermutationCount = numPermut $len $expectedPermutationSize

                    $test.Data.err = try {Group-ListItem -Permute $test.Data.in.permute -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                } else {
                    $expectedPermutationSize = $size
                    $expectedPermutationCount = numPermut $len $expectedPermutationSize

                    $test.Data.err = try {Group-ListItem -Permute $test.Data.in.permute -Size $test.Data.in.size -OutVariable out | Out-Null} catch {$_}
                    $test.Data.out = $out
                }

                Assert-Null ($test.Data.err)
                Assert-True (eq? $expectedPermutationCount $test.Data.out.Count)
                iota $expectedPermutationCount |
                    Assert-PipelineAll {param($row) $test.Data.out[$row] -isnot [System.Collections.IEnumerable]} |
                    Assert-PipelineAll {param($row) $test.Data.out[$row].Items -is $expectedType} |
                    Assert-PipelineAll {param($row) eq? $test.Data.out[$row].Items.Count $expectedPermutationSize} |
                    Out-Null

                $pass = $true
            }
            finally {commitTestLogEntry $test $pass}
        }
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Zip with nulls' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $out3 = New-Object -TypeName 'System.Collections.ArrayList'
    $out4 = New-Object -TypeName 'System.Collections.ArrayList'

    $er1 = try {Group-ListItem -Zip $null -OutVariable out1 | Out-Null} catch {$_}
    $er2 = try {Group-ListItem -Zip @($null) -OutVariable out2 | Out-Null} catch {$_}
    $er3 = try {Group-ListItem -Zip (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList (,@(@(1,2,3), $null))) -OutVariable out3 | Out-Null} catch {$_}
    $er4 = try {Group-ListItem -Zip (New-Object -TypeName 'System.Collections.Generic.List[System.Object]' -ArgumentList (,@($null, @(4,5,6)))) -OutVariable out4 | Out-Null} catch {$_}

    @($out1, $out2, $out3, $out4) |
        Assert-PipelineAll {param($out) $out.Count -eq 0} |
        Out-Null

    @($er1, $er2, $er3, $er4) |
        Assert-PipelineAll {param($er) $er -is [System.Management.Automation.ErrorRecord]} |
        Assert-PipelineAll {param($er) $er.FullyQualifiedErrorId.Equals('ParameterArgumentValidationError,Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineAll {param($er) $er.Exception.ParameterName.Equals('Zip', [System.StringComparison]::OrdinalIgnoreCase)} |
        Out-Null
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Zip with lists of length 0' -Verbose:$headerVerbosity

    Group-ListItem -Zip @(,@()) | Assert-PipelineEmpty

    Group-ListItem -Zip @(@(), (New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@()))) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@(), @($null)) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@($null), @()) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@(1,2), (New-Object -TypeName 'System.Collections.ArrayList')) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@(), (New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@(1,2)))) | Assert-PipelineEmpty

    Group-ListItem -Zip @(@(), @(), @()) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@(), @($null), @(1,2)) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@(1,2), @(), @($null)) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@($null), @(1,2), @()) | Assert-PipelineEmpty

    Group-ListItem -Zip @(@(), @(), @(), @()) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@(), @($null), @(1,2), @('a','b','c')) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@($null), @(), @(1,2), @('a','b','c')) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@($null), @(1,2), @(), @('a','b','c')) | Assert-PipelineEmpty
    Group-ListItem -Zip @(@($null), @(1,2), @('a','b','c'), @()) | Assert-PipelineEmpty
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Zip with no lists' -Verbose:$headerVerbosity

    Group-ListItem -Zip @() | Assert-PipelineEmpty
    Group-ListItem -Zip (New-Object -TypeName 'System.Collections.ArrayList') | Assert-PipelineEmpty
    Group-ListItem -Zip (New-Object -TypeName 'System.Collections.Generic.List[System.Byte[]]') | Assert-PipelineEmpty
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Zip with 1 list' -Verbose:$headerVerbosity

    $list1 = [System.String[]]@('a')
    $list2 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@($null, @()))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(0.00, 2.72, 3.14))
    $list4 = [System.Double[]]@(100, 200, 300, 400)
    $list5 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@(@($null), @(), 'hi', $null, 5))
    $list6 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('hello', 'world', 'how', 'are', 'you', 'today'))
    $lists = @(
        @(,$list1),
        @(,$list2),
        @(,$list3),
        @(,$list4),
        @(,$list5),
        @(,$list6)
    )

    function oracleType($list)
    {
        if ($list[0].Equals($list1) -or $list[0].Equals($list6)) {
            return [System.String[]]
        } elseif ($list[0].Equals($list3) -or $list[0].Equals($list4)) {
            return [System.Double[]]
        } else {
            return [System.Object[]]
        }
    }

    function oracleOutput($list)
    {
        $count = $list[0].Count
        for ($i = 0; $i -lt $count; $i++) {
            @{'Items' = @(,$list[0][$i])}
        }
    }
    
    function areEqual($a, $b)
    {
        if ($null -eq $a) {
            $null -eq $b
        } else {
            $a.Equals($b)
        }
    }

    foreach ($list in $lists) {
        $expectedType = oracleType $list
        $expectedOutput = @(oracleOutput $list)
        $actualOutput = New-Object -TypeName 'System.Collections.ArrayList'

        Group-ListItem -Zip $list -OutVariable actualOutput | Out-Null

        Assert-True ($actualOutput.Count -eq $expectedOutput.Count)
        Assert-True ($actualOutput.Count -gt 0)

        @(0..$($actualOutput.Count - 1)) |
            Assert-PipelineAll {param($row) $actualOutput[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $actualOutput[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $actualOutput[$row].Items.Length -eq 1} |
            Assert-PipelineAll {param($row) Test-All @(0) {param($col) areEqual $actualOutput[$row].Items[$col] $expectedOutput[$row].Items[$col]}} |
            Assert-PipelineAny |
            Out-Null
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Zip with 2 lists' -Verbose:$headerVerbosity

    $list1 = [System.String[]]@('a')
    $list2 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@($null, @()))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(0.00, 2.72, 3.14))
    $list4 = [System.Double[]]@(100, 200, 300, 400)
    $list5 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@(@($null), @(), 'hi', $null, 5))
    $list6 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('hello', 'world', 'how', 'are', 'you', 'today'))
    $lists = @(
        @($list1, $list1), @($list1, $list2), @($list1, $list3), @($list1, $list4), @($list1, $list5), @($list1, $list6),
        @($list2, $list1), @($list2, $list2), @($list2, $list3), @($list2, $list4), @($list2, $list5), @($list2, $list6),
        @($list3, $list1), @($list3, $list2), @($list3, $list3), @($list3, $list4), @($list3, $list5), @($list3, $list6),
        @($list4, $list1), @($list4, $list2), @($list4, $list3), @($list4, $list4), @($list4, $list5), @($list4, $list6),
        @($list5, $list1), @($list5, $list2), @($list5, $list3), @($list5, $list4), @($list5, $list5), @($list5, $list6),
        @($list6, $list1), @($list6, $list2), @($list6, $list3), @($list6, $list4), @($list6, $list5), @($list6, $list6)
    )

    function oracleType($list)
    {
        if ($list[0].Equals($list1) -and $list[1].Equals($list6)) {
            return [System.String[]]
        } elseif ($list[0].Equals($list6) -and $list[1].Equals($list1)) {
            return [System.String[]]
        } elseif ($list[0].Equals($list1) -and $list[1].Equals($list1)) {
            return [System.String[]]
        } elseif ($list[0].Equals($list6) -and $list[1].Equals($list6)) {
            return [System.String[]]
        } elseif ($list[0].Equals($list3) -and $list[1].Equals($list4)) {
            return [System.Double[]]
        } elseif ($list[0].Equals($list4) -and $list[1].Equals($list3)) {
            return [System.Double[]]
        } elseif ($list[0].Equals($list3) -and $list[1].Equals($list3)) {
            return [System.Double[]]
        } elseif ($list[0].Equals($list4) -and $list[1].Equals($list4)) {
            return [System.Double[]]
        } else {
            return [System.Object[]]
        }
    }

    function oracleOutput($list)
    {
        $count = @($list[0].Count, $list[1].Count | Sort-Object)[0]
        for ($i = 0; $i -lt $count; $i++) {
            @{'Items' = @($list[0][$i], $list[1][$i])}
        }
    }
    
    function areEqual($a, $b)
    {
        if ($null -eq $a) {
            $null -eq $b
        } else {
            $a.Equals($b)
        }
    }

    foreach ($list in $lists) {
        $expectedType = oracleType $list
        $expectedOutput = @(oracleOutput $list)
        $actualOutput = New-Object -TypeName 'System.Collections.ArrayList'

        Group-ListItem -Zip $list -OutVariable actualOutput | Out-Null

        Assert-True ($actualOutput.Count -eq $expectedOutput.Count)
        Assert-True ($actualOutput.Count -gt 0)

        @(0..$($actualOutput.Count - 1)) |
            Assert-PipelineAll {param($row) $actualOutput[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $actualOutput[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $actualOutput[$row].Items.Length -eq 2} |
            Assert-PipelineAll {param($row) Test-All @(0, 1) {param($col) areEqual $actualOutput[$row].Items[$col] $expectedOutput[$row].Items[$col]}} |
            Assert-PipelineAny |
            Out-Null
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Zip with 3 lists' -Verbose:$headerVerbosity

    $list1 = [System.String[]]@('a')
    $list2 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@($null, @()))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(0.00, 2.72, 3.14))
    $list4 = [System.String[]]@('100', '200', '300', '400')
    $list5 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@(@($null), @(), 'hi', $null, 5))
    $list6 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('hello', 'world', 'how', 'are', 'you', 'today'))

    $lists = Group-ListItem -Permute @($list1, $list2, $list3, $list4, $list5, $list6) -Size 3

    function oracleType($list)
    {
        if ($list[0].Equals($list3) -and $list[1].Equals($list3) -and $list[2].Equals($list3)) {
            return [System.Double[]]
        } elseif ($list[0].Equals($list2) -or $list[0].Equals($list3) -or $list[0].Equals($list5)) {
            return [System.Object[]]
        } elseif ($list[1].Equals($list2) -or $list[1].Equals($list3) -or $list[1].Equals($list5)) {
            return [System.Object[]]
        } elseif ($list[2].Equals($list2) -or $list[2].Equals($list3) -or $list[2].Equals($list5)) {
            return [System.Object[]]
        } else {
            return [System.String[]]
        }
    }

    function oracleOutput($list)
    {
        $count = @($list[0].Count, $list[1].Count, $list[2].Count | Sort-Object)[0]
        for ($i = 0; $i -lt $count; $i++) {
            @{'Items' = @($list[0][$i], $list[1][$i], $list[2][$i])}
        }
    }
    
    function areEqual($a, $b)
    {
        if ($null -eq $a) {
            $null -eq $b
        } else {
            $a.Equals($b)
        }
    }

    foreach ($list in $lists) {
        $expectedType = oracleType $list.Items
        $expectedOutput = @(oracleOutput $list.Items)
        $actualOutput = New-Object -TypeName 'System.Collections.ArrayList'

        Group-ListItem -Zip $list.Items -OutVariable actualOutput | Out-Null

        Assert-True ($actualOutput.Count -eq $expectedOutput.Count)
        Assert-True ($actualOutput.Count -gt 0)

        @(0..$($actualOutput.Count - 1)) |
            Assert-PipelineAll {param($row) $actualOutput[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $actualOutput[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $actualOutput[$row].Items.Length -eq 3} |
            Assert-PipelineAll {param($row) Test-All @(0, 1, 2) {param($col) areEqual $actualOutput[$row].Items[$col] $expectedOutput[$row].Items[$col]}} |
            Assert-PipelineAny |
            Out-Null
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -Zip with 4 lists' -Verbose:$headerVerbosity

    $list1 = [System.String[]]@('a')
    $list2 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@($null, @()))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('0.00', '2.72', '3.14'))
    $list4 = [System.String[]]@('100', '200', '300', '400')
    $list5 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@(@($null), @(), 'hi', $null, 5))
    $list6 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('hello', 'world', 'how', 'are', 'you', 'today'))

    $lists = Group-ListItem -Permute @($list1, $list2, $list3, $list4, $list5, $list6) -Size 4

    function oracleType($list)
    {
        if ($list[0].Equals($list2) -or $list[0].Equals($list5)) {
            return [System.Object[]]
        } elseif ($list[1].Equals($list2) -or $list[1].Equals($list5)) {
            return [System.Object[]]
        } elseif ($list[2].Equals($list2) -or $list[2].Equals($list5)) {
            return [System.Object[]]
        } elseif ($list[3].Equals($list2) -or $list[3].Equals($list5)) {
            return [System.Object[]]
        } else {
            return [System.String[]]
        }
    }

    function oracleOutput($list)
    {
        $count = @($list[0].Count, $list[1].Count, $list[2].Count, $list[3].Count | Sort-Object)[0]
        for ($i = 0; $i -lt $count; $i++) {
            @{'Items' = @($list[0][$i], $list[1][$i], $list[2][$i], $list[3][$i])}
        }
    }
    
    function areEqual($a, $b)
    {
        if ($null -eq $a) {
            $null -eq $b
        } else {
            $a.Equals($b)
        }
    }

    foreach ($list in $lists) {
        $expectedType = oracleType $list.Items
        $expectedOutput = @(oracleOutput $list.Items)
        $actualOutput = New-Object -TypeName 'System.Collections.ArrayList'

        Group-ListItem -Zip $list.Items -OutVariable actualOutput | Out-Null

        Assert-True ($actualOutput.Count -eq $expectedOutput.Count)
        Assert-True ($actualOutput.Count -gt 0)

        @(0..$($actualOutput.Count - 1)) |
            Assert-PipelineAll {param($row) $actualOutput[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $actualOutput[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $actualOutput[$row].Items.Length -eq 4} |
            Assert-PipelineAll {param($row) Test-All @(0, 1, 2, 3) {param($col) areEqual $actualOutput[$row].Items[$col] $expectedOutput[$row].Items[$col]}} |
            Assert-PipelineAny |
            Out-Null
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CartesianProduct with nulls' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $out3 = New-Object -TypeName 'System.Collections.ArrayList'
    $out4 = New-Object -TypeName 'System.Collections.ArrayList'

    $er1 = try {Group-ListItem -CartesianProduct $null -OutVariable out1 | Out-Null} catch {$_}
    $er2 = try {Group-ListItem -CartesianProduct @($null) -OutVariable out2 | Out-Null} catch {$_}
    $er3 = try {Group-ListItem -CartesianProduct (New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList (,@(@(1,2,3), $null))) -OutVariable out3 | Out-Null} catch {$_}
    $er4 = try {Group-ListItem -CartesianProduct (New-Object -TypeName 'System.Collections.Generic.List[System.Object]' -ArgumentList (,@($null, @(4,5,6)))) -OutVariable out4 | Out-Null} catch {$_}

    @($out1, $out2, $out3, $out4) |
        Assert-PipelineAll {param($out) $out.Count -eq 0} |
        Out-Null

    @($er1, $er2, $er3, $er4) |
        Assert-PipelineAll {param($er) $er -is [System.Management.Automation.ErrorRecord]} |
        Assert-PipelineAll {param($er) $er.FullyQualifiedErrorId.Equals('ParameterArgumentValidationError,Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineAll {param($er) $er.Exception.ParameterName.Equals('CartesianProduct', [System.StringComparison]::OrdinalIgnoreCase)} |
        Out-Null
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CartesianProduct with lists of length 0' -Verbose:$headerVerbosity

    Group-ListItem -CartesianProduct @(,@()) | Assert-PipelineEmpty

    Group-ListItem -CartesianProduct @(@(), (New-Object -TypeName 'System.Collections.Generic.List[System.String]')) | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct @(@(), @($null)) | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct @(@($null), @()) | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct @(@(1,2), (New-Object -TypeName 'System.Collections.ArrayList')) | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct @(@(), (New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@(1,2)))) | Assert-PipelineEmpty

    Group-ListItem -CartesianProduct @(@(), @(), @()) | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct @(@(), @($null), @(1,2)) | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct @(@(1,2), @(), @($null)) | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct @(@($null), @(1,2), @()) | Assert-PipelineEmpty

    Group-ListItem -CartesianProduct @(@(), @(), @(), @()) | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct @(@(), @($null), @(1,2), @('a','b','c')) | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct @(@($null), @(), @(1,2), @('a','b','c')) | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct @(@($null), @(1,2), @(), @('a','b','c')) | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct @(@($null), @(1,2), @('a','b','c'), @()) | Assert-PipelineEmpty
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CartesianProduct with no lists' -Verbose:$headerVerbosity

    Group-ListItem -CartesianProduct @() | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct (New-Object -TypeName 'System.Collections.ArrayList') | Assert-PipelineEmpty
    Group-ListItem -CartesianProduct (New-Object -TypeName 'System.Collections.Generic.List[System.Byte[]]') | Assert-PipelineEmpty
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CartesianProduct with 1 list' -Verbose:$headerVerbosity

    $list1 = [System.String[]]@('a')
    $list2 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@($null, @()))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(0.00, 2.72, 3.14))
    $list4 = [System.Double[]]@(100, 200, 300, 400)
    $list5 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@(@($null), @(), 'hi', $null, 5))
    $list6 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('hello', 'world', 'how', 'are', 'you', 'today'))
    $lists = @(
        @(,$list1),
        @(,$list2),
        @(,$list3),
        @(,$list4),
        @(,$list5),
        @(,$list6)
    )

    function oracleType($list)
    {
        if ($list[0].Equals($list1) -or $list[0].Equals($list6)) {
            return [System.String[]]
        } elseif ($list[0].Equals($list3) -or $list[0].Equals($list4)) {
            return [System.Double[]]
        } else {
            return [System.Object[]]
        }
    }

    function oracleOutput($list)
    {
        foreach ($i in $list[0]) {
            @{'Items' = @(,$i)}
        }
    }
    
    function areEqual($a, $b)
    {
        if ($null -eq $a) {
            $null -eq $b
        } else {
            $a.Equals($b)
        }
    }

    foreach ($list in $lists) {
        $expectedType = oracleType $list
        $expectedOutput = @(oracleOutput $list)
        $actualOutput = New-Object -TypeName 'System.Collections.ArrayList'

        Group-ListItem -CartesianProduct $list -OutVariable actualOutput | Out-Null

        Assert-True ($actualOutput.Count -eq $expectedOutput.Count)
        Assert-True ($actualOutput.Count -gt 0)

        @(0..$($actualOutput.Count - 1)) |
            Assert-PipelineAll {param($row) $actualOutput[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $actualOutput[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $actualOutput[$row].Items.Length -eq 1} |
            Assert-PipelineAll {param($row) Test-All @(0) {param($col) areEqual $actualOutput[$row].Items[$col] $expectedOutput[$row].Items[$col]}} |
            Assert-PipelineAny |
            Out-Null
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CartesianProduct with 2 lists' -Verbose:$headerVerbosity

    $list1 = [System.String[]]@('a')
    $list2 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@($null, @()))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(0.00, 2.72, 3.14))
    $list4 = [System.Double[]]@(100, 200, 300, 400)
    $list5 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@(@($null), @(), 'hi', $null, 5))
    $list6 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('hello', 'world', 'how', 'are', 'you', 'today'))
    $lists = @(
        @($list1, $list1), @($list1, $list2), @($list1, $list3), @($list1, $list4), @($list1, $list5), @($list1, $list6),
        @($list2, $list1), @($list2, $list2), @($list2, $list3), @($list2, $list4), @($list2, $list5), @($list2, $list6),
        @($list3, $list1), @($list3, $list2), @($list3, $list3), @($list3, $list4), @($list3, $list5), @($list3, $list6),
        @($list4, $list1), @($list4, $list2), @($list4, $list3), @($list4, $list4), @($list4, $list5), @($list4, $list6),
        @($list5, $list1), @($list5, $list2), @($list5, $list3), @($list5, $list4), @($list5, $list5), @($list5, $list6),
        @($list6, $list1), @($list6, $list2), @($list6, $list3), @($list6, $list4), @($list6, $list5), @($list6, $list6)
    )

    function oracleType($list)
    {
        if ($list[0].Equals($list1) -and $list[1].Equals($list6)) {
            return [System.String[]]
        } elseif ($list[0].Equals($list6) -and $list[1].Equals($list1)) {
            return [System.String[]]
        } elseif ($list[0].Equals($list1) -and $list[1].Equals($list1)) {
            return [System.String[]]
        } elseif ($list[0].Equals($list6) -and $list[1].Equals($list6)) {
            return [System.String[]]
        } elseif ($list[0].Equals($list3) -and $list[1].Equals($list4)) {
            return [System.Double[]]
        } elseif ($list[0].Equals($list4) -and $list[1].Equals($list3)) {
            return [System.Double[]]
        } elseif ($list[0].Equals($list3) -and $list[1].Equals($list3)) {
            return [System.Double[]]
        } elseif ($list[0].Equals($list4) -and $list[1].Equals($list4)) {
            return [System.Double[]]
        } else {
            return [System.Object[]]
        }
    }

    function oracleOutput($list)
    {
        foreach ($i in $list[0]) {
            foreach ($j in $list[1]) {
                @{'Items' = @($i, $j)}
            }
        }
    }
    
    function areEqual($a, $b)
    {
        if ($null -eq $a) {
            $null -eq $b
        } else {
            $a.Equals($b)
        }
    }

    foreach ($list in $lists) {
        $expectedType = oracleType $list
        $expectedOutput = @(oracleOutput $list)
        $actualOutput = New-Object -TypeName 'System.Collections.ArrayList'

        Group-ListItem -CartesianProduct $list -OutVariable actualOutput | Out-Null

        Assert-True ($actualOutput.Count -eq $expectedOutput.Count)
        Assert-True ($actualOutput.Count -gt 0)

        @(0..$($actualOutput.Count - 1)) |
            Assert-PipelineAll {param($row) $actualOutput[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $actualOutput[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $actualOutput[$row].Items.Length -eq 2} |
            Assert-PipelineAll {param($row) Test-All @(0..1) {param($col) areEqual $actualOutput[$row].Items[$col] $expectedOutput[$row].Items[$col]}} |
            Assert-PipelineAny |
            Out-Null
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CartesianProduct with 3 lists' -Verbose:$headerVerbosity

    $list1 = [System.String[]]@('a')
    $list2 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@($null, @()))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.Double]' -ArgumentList @(,[System.Double[]]@(0.00, 2.72, 3.14))
    $list4 = [System.String[]]@('100', '200', '300', '400')
    $list5 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@(@($null), @(), 'hi', $null, 5))
    $list6 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('hello', 'world', 'how', 'are', 'you', 'today'))

    $lists = Group-ListItem -Permute @($list1, $list2, $list3, $list4, $list5, $list6) -Size 3

    function oracleType($list)
    {
        if ($list[0].Equals($list3) -and $list[1].Equals($list3) -and $list[2].Equals($list3)) {
            return [System.Double[]]
        } elseif ($list[0].Equals($list2) -or $list[0].Equals($list3) -or $list[0].Equals($list5)) {
            return [System.Object[]]
        } elseif ($list[1].Equals($list2) -or $list[1].Equals($list3) -or $list[1].Equals($list5)) {
            return [System.Object[]]
        } elseif ($list[2].Equals($list2) -or $list[2].Equals($list3) -or $list[2].Equals($list5)) {
            return [System.Object[]]
        } else {
            return [System.String[]]
        }
    }

    function oracleOutput($list)
    {
        foreach ($i in $list[0]) {
            foreach ($j in $list[1]) {
                foreach ($k in $list[2]) {
                    @{'Items' = @($i, $j, $k)}
                }
            }
        }
    }
    
    function areEqual($a, $b)
    {
        if ($null -eq $a) {
            $null -eq $b
        } else {
            $a.Equals($b)
        }
    }

    foreach ($list in $lists) {
        $expectedType = oracleType $list.Items
        $expectedOutput = @(oracleOutput $list.Items)
        $actualOutput = New-Object -TypeName 'System.Collections.ArrayList'

        Group-ListItem -CartesianProduct $list.Items -OutVariable actualOutput | Out-Null

        Assert-True ($actualOutput.Count -eq $expectedOutput.Count)
        Assert-True ($actualOutput.Count -gt 0)

        @(0..$($actualOutput.Count - 1)) |
            Assert-PipelineAll {param($row) $actualOutput[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $actualOutput[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $actualOutput[$row].Items.Length -eq 3} |
            Assert-PipelineAll {param($row) Test-All @(0..2) {param($col) areEqual $actualOutput[$row].Items[$col] $expectedOutput[$row].Items[$col]}} |
            Assert-PipelineAny |
            Out-Null
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CartesianProduct with 4 lists' -Verbose:$headerVerbosity

    $list1 = [System.String[]]@('a')
    $list2 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@($null, @()))
    $list3 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('0.00', '2.72', '3.14'))
    $list4 = [System.String[]]@('100', '200', '300', '400')
    $list5 = New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList @(,@(@($null), @(), 'hi', $null, 5))
    $list6 = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@('hello', 'world', 'how', 'are', 'you', 'today'))

    $lists = Group-ListItem -Permute @($list1, $list2, $list3, $list4, $list5, $list6) -Size 4

    function oracleType($list)
    {
        if ($list[0].Equals($list2) -or $list[0].Equals($list5)) {
            return [System.Object[]]
        } elseif ($list[1].Equals($list2) -or $list[1].Equals($list5)) {
            return [System.Object[]]
        } elseif ($list[2].Equals($list2) -or $list[2].Equals($list5)) {
            return [System.Object[]]
        } elseif ($list[3].Equals($list2) -or $list[3].Equals($list5)) {
            return [System.Object[]]
        } else {
            return [System.String[]]
        }
    }

    function oracleOutput($list)
    {
        foreach ($i in $list[0]) {
            foreach ($j in $list[1]) {
                foreach ($k in $list[2]) {
                    foreach ($l in $list[3]) {
                        @{'Items' = @($i, $j, $k, $l)}
                    }
                }
            }
        }
    }
    
    function areEqual($a, $b)
    {
        if ($null -eq $a) {
            $null -eq $b
        } else {
            $a.Equals($b)
        }
    }

    foreach ($list in $lists) {
        $expectedType = oracleType $list.Items
        $expectedOutput = @(oracleOutput $list.Items)
        $actualOutput = New-Object -TypeName 'System.Collections.ArrayList'

        Group-ListItem -CartesianProduct $list.Items -OutVariable actualOutput | Out-Null

        Assert-True ($actualOutput.Count -eq $expectedOutput.Count)
        Assert-True ($actualOutput.Count -gt 0)

        @(0..$($actualOutput.Count - 1)) |
            Assert-PipelineAll {param($row) $actualOutput[$row] -isnot [System.Collections.IEnumerable]} |
            Assert-PipelineAll {param($row) $actualOutput[$row].Items -is $expectedType} |
            Assert-PipelineAll {param($row) $actualOutput[$row].Items.Length -eq 4} |
            Assert-PipelineAll {param($row) Test-All @(0..3) {param($col) areEqual $actualOutput[$row].Items[$col] $expectedOutput[$row].Items[$col]}} |
            Assert-PipelineAny |
            Out-Null
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CoveringArray with nulls' -Verbose:$headerVerbosity

    $lists = @(
        $null
        @($null)
        New-Object -TypeName 'System.Collections.ArrayList' -ArgumentList (,@(@(1,2,3), $null))
        New-Object -TypeName 'System.Collections.Generic.List[System.Object]' -ArgumentList (,@($null, @(4,5,6)))
    )

    foreach ($list in $lists) {
        $outputSize_  = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize0  = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize1  = New-Object -TypeName 'System.Collections.ArrayList'
        $outputSize1m = New-Object -TypeName 'System.Collections.ArrayList'

        $er_  = try {Group-ListItem -CoveringArray $null          -OutVariable outputSize_ | Out-Null} catch {$_}
        $er0  = try {Group-ListItem -CoveringArray $null -Size  0 -OutVariable outputSize0 | Out-Null} catch {$_}
        $er1  = try {Group-ListItem -CoveringArray $null -Size  1 -OutVariable outputSize1 | Out-Null} catch {$_}
        $er1m = try {Group-ListItem -CoveringArray $null -Size -1 -OutVariable outputSize1m | Out-Null} catch {$_}

        @($outputSize_, $outputSize0, $outputSize1, $outputSize1m) |
            Assert-PipelineAll {param($output) $output.Count -eq 0} |
            Out-Null

        @($er_, $er0, $er1, $er1m) |
            Assert-PipelineAll {param($er) $er -is [System.Management.Automation.ErrorRecord]} |
            Assert-PipelineAll {param($er) $er.FullyQualifiedErrorId.Equals('ParameterArgumentValidationError,Group-ListItem', [System.StringComparison]::OrdinalIgnoreCase)} |
            Assert-PipelineAll {param($er) $er.Exception.ParameterName.Equals('CoveringArray', [System.StringComparison]::OrdinalIgnoreCase)} |
            Out-Null
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CoveringArray with lists of length 0' -Verbose:$headerVerbosity

    $lists = @(
        @(,@()),
        @(@(), (New-Object -TypeName 'System.Collections.Generic.List[System.String]')),
        @(@(), @($null)),
        @(@($null), @()),
        @(@(1,2), (New-Object -TypeName 'System.Collections.ArrayList')),
        @(@(), (New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @(,[System.String[]]@(1,2)))),
        @(@(), @(), @()),
        @(@(), @($null), @(1,2)),
        @(@(1,2), @(), @($null)),
        @(@($null), @(1,2), @()),
        @(@(), @(), @(), @()),
        @(@(), @($null), @(1,2), @('a','b','c')),
        @(@($null), @(), @(1,2), @('a','b','c')),
        @(@($null), @(1,2), @(), @('a','b','c')),
        @(@($null), @(1,2), @('a','b','c'), @())
    )

    foreach ($list in $lists) {
        Group-ListItem -CoveringArray $list              | Assert-PipelineEmpty
        Group-ListItem -CoveringArray $list -Strength  0 | Assert-PipelineEmpty
        Group-ListItem -CoveringArray $list -Strength  1 | Assert-PipelineEmpty
        Group-ListItem -CoveringArray $list -Strength  2 | Assert-PipelineEmpty
        Group-ListItem -CoveringArray $list -Strength  3 | Assert-PipelineEmpty
        Group-ListItem -CoveringArray $list -Strength  4 | Assert-PipelineEmpty
        Group-ListItem -CoveringArray $list -Strength  5 | Assert-PipelineEmpty
        Group-ListItem -CoveringArray $list -Strength -1 | Assert-PipelineEmpty
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CoveringArray with no lists' -Verbose:$headerVerbosity

    $lists = @(
        @(),
        (New-Object -TypeName 'System.Collections.ArrayList'),
        (New-Object -TypeName 'System.Collections.Generic.List[System.Byte[]]')
    )

    foreach ($list in $lists) {
        Group-ListItem -CoveringArray $list              | Assert-PipelineEmpty
        Group-ListItem -CoveringArray $list -Strength  0 | Assert-PipelineEmpty
        Group-ListItem -CoveringArray $list -Strength  1 | Assert-PipelineEmpty
        Group-ListItem -CoveringArray $list -Strength -1 | Assert-PipelineEmpty
    }
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CoveringArray with 1 list' -Verbose:$headerVerbosity

    #foreach list in ...
        #foreach strength in ...
            #covering array algorithm is deterministic
            #if strength < 1
                #no output
            #else
                #all values in list are found in at least one row in covering array
    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CoveringArray with 2 lists' -Verbose:$headerVerbosity

    #foreach list in ...
        #foreach strength in ...
            #covering array algorithm is deterministic
            #if strength < 1
                #no output
            #else if strength = 1
                #all values in both lists are found in at least one row in covering array
            #else
                #all combinations of values from both lists are found in at least one row in covering array
    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CoveringArray with 3 lists' -Verbose:$headerVerbosity

    #foreach list in ...
        #foreach strength in ...
            #covering array algorithm is deterministic
            #if strength < 1
                #no output
            #else if strength = 1
                #all values in three lists are found in at least one row in covering array
            #else if strength = 2
                #all combinations of values from any 2 lists are found in at least one row in covering array
            #else
                #all combinations of values from any 3 lists are found in at least one row in covering array
    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Group-ListItem -CoveringArray with 4 lists' -Verbose:$headerVerbosity

    #foreach list in ...
        #foreach strength in ...
            #covering array algorithm is deterministic
            #if strength < 1
                #no output
            #else if strength = 1
                #all values in three lists are found in at least one row in covering array
            #else if strength = 2
                #all combinations of values from any 2 lists are found in at least one row in covering array
            #else if strength = 3
                #all combinations of values from any 3 lists are found in at least one row in covering array
            #else
                #all combinations of values from any 4 lists are found in at least one row in covering array
    Write-Warning -Message 'Not implemented here.' -WarningAction 'Continue'
}

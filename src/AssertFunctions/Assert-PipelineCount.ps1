<#
.Synopsis
Assert the number of objects in the pipeline.
.Description
This function is useful for asserting that a function outputs the correct number of objects.

See the -Equals, -Minimum, and -Maximum parameters for more details.

Note:
This function will output all pipeline objects it receives until an error is thrown, or until there are no more objects left in the pipeline.
.Parameter InputObject
The object from the pipeline.

Note:
The argument for this parameter must come from the pipeline.
.Parameter Equals
This function will throw an error if the number of objects in the pipeline is not equal to the number specified by this parameter.

Note:
A negative number will always cause this assertion to fail.
.Parameter Minimum
This function will throw an error if the number of objects in the pipeline is less than the number specified by this parameter.

Note:
A negative number will always cause this assertion to pass.
.Parameter Maximum
This function will throw an error if the number of objects in the pipeline is more than the number specified by this parameter.

Note:
A negative number will always cause this assertion to fail.
.Example
$nums = 1..100 | Get-Random -Count 10 | Assert-PipelineCount 10
Throws an error if Get-Random -Count 10 does not return exactly ten objects.
.Example
$nums = 1..100 | Get-Random -Count 10 | Assert-PipelineCount -Maximum 10
Throws an error if Get-Random -Count 10 returns more than ten objects.
.Example
$nums = 1..100 | Get-Random -Count 10 | Assert-PipelineCount -Minimum 10
Throws an error if Get-Random -Count 10 returns less than ten objects.
.Example
$nums = 1..100 | Get-Random -Count 10 | Assert-PipelineCount 10 -Verbose
Throws an error if Get-Random -Count 10 does not return exactly ten objects.
The -Verbose switch will output the result of the assertion to the Verbose stream.
.Example
$nums = 1..100 | Get-Random -Count 10 | Assert-PipelineCount 10 -Debug
Throws an error if Get-Random -Count 10 does not return exactly ten objects.
The -Debug switch gives you a chance to investigate a failing assertion before an error is thrown.
.Example
$a = Get-ChildItem 'a*' | Assert-PipelineCount -Minimum 5 | Assert-PipelineCount -Maximum 10
Throws an error if Get-ChildItem 'a*' either returns less than five objects, or returns more than 10 objects.
.Inputs
System.Object
.Outputs
System.Object
.Notes
An example of how this function might be used in a unit test.

#display passing assertions
$VerbosePreference = [System.Management.Automation.ActionPreference]::Continue

#display debug prompt on failing assertions
$DebugPreference = [System.Management.Automation.ActionPreference]::Inquire

$a = myFunc1 | Assert-PipelineCount 10
$b = myFunc2 | Assert-PipelineCount -Minimum 1
$c = myFunc3 | Assert-PipelineCount -Maximum 2
$d = myFunc4 | Assert-PipelineCount -Minimum 3 | Assert-PipelineCount -Maximum 14
.Link
Assert-True
Assert-False
Assert-Null
Assert-NotNull
Assert-PipelineEmpty
Assert-PipelineAny
Assert-PipelineSingle
#>
function Assert-PipelineCount
{
    [CmdletBinding(DefaultParameterSetName='Equals')]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [AllowNull()]
        [System.Object]
        $InputObject,

        [Parameter(Mandatory=$true, ParameterSetName='Equals', Position=0)]
        [System.Int64]
        $Equals,

        [Parameter(Mandatory=$true, ParameterSetName='Minimum')]
        [System.Int64]
        $Minimum,

        [Parameter(Mandatory=$true, ParameterSetName='Maximum')]
        [System.Int64]
        $Maximum
    )

    Begin
    {
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
            if ($null -eq $VerbosePreference) {
                $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
            }
        }
        if (-not $PSBoundParameters.ContainsKey('Debug')) {
            $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference]
            if ($null -eq $DebugPreference) {
                $DebugPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
            }
        }

        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                (New-Object -TypeName 'System.ArgumentException' -ArgumentList @(
                    'Assert-PipelineCount must take its input from the pipeline.',
                    'InputObject'
                )),
                'PipelineArgumentOnly',
                [System.Management.Automation.ErrorCategory]::InvalidArgument,
                $InputObject
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }

        #Make sure we can count higher than -Equals, -Minimum, and -Maximum.
        [System.UInt64]$inputCount = 0

        if ($PSCmdlet.ParameterSetName -eq 'Equals') {
            $failEarly  = {$inputCount -gt $Equals}
            $failAssert = {$inputCount -ne $Equals}
        } elseif ($PSCmdlet.ParameterSetName -eq 'Maximum') {
            $failEarly  = {$inputCount -gt $Maximum}
            $failAssert = $failEarly
        } else {
            $failEarly  = {$false}
            $failAssert = {$inputCount -lt $Minimum}
        }
    }

    Process
    {
        $inputCount++

        if ((& $failEarly)) {
            #fail immediately
            #do not wait for all pipeline objects

            $message = 'Assertion failed: {0}, file {1}, line {2}' -f @(
                $MyInvocation.Line.Trim(),
                $MyInvocation.ScriptName,
                $MyInvocation.ScriptLineNumber
            )

            Write-Verbose -Message $message
            Write-Debug -Message $message

            $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                (New-Object -TypeName 'System.Exception' -ArgumentList @($message)),
                'AssertionFailed',
                [System.Management.Automation.ErrorCategory]::OperationStopped,
                $InputObject
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }

        ,$InputObject
    }

    End
    {
        $fail = & $failAssert

        if ($fail -or ($VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue)) {
            $message = 'Assertion {0}: {1}, file {2}, line {3}' -f @(
                $(if ($fail) {'failed'} else {'passed'}),
                $MyInvocation.Line.Trim(),
                $MyInvocation.ScriptName,
                $MyInvocation.ScriptLineNumber
            )

            Write-Verbose -Message $message

            if ($fail) {
                Write-Debug -Message $message

                $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                    (New-Object -TypeName 'System.Exception' -ArgumentList @($message)),
                    'AssertionFailed',
                    [System.Management.Automation.ErrorCategory]::OperationStopped,
                    $InputObject
                )
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }
        }
    }
}

function Assert-PipelineSingle
{
<#
.Synopsis
Assert that the pipeline only contains one object.
.Description
This function is useful for asserting that a function only returns a single object.

This function throws an error if any of the following conditions are met:
    *the pipeline contains less than one object
    *the pipeline contains more than one object
.Example
$letter = 'a', 'b', 'c' | Get-Random | Assert-PipelineSingle
Throws an error if Get-Random does not return a single object.
.Example
$letter = 'a', 'b', 'c' | Get-Random | Assert-PipelineSingle -Verbose
Throws an error if Get-Random does not return a single object.
The -Verbose switch will output the result of the assertion to the Verbose stream.
.Example
$letter = 'a', 'b', 'c' | Get-Random | Assert-PipelineSingle -Debug
Throws an error if Get-Random does not return a single object.
The -Debug switch gives you a chance to investigate a failing assertion before an error is thrown.
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

$a = myFunc1 | Assert-PipelineSingle
$b = myFunc2 | Assert-PipelineSingle
$c = myFunc3 | Assert-PipelineSingle
.Link
Assert-True
Assert-False
Assert-Null
Assert-NotNull
Assert-PipelineEmpty
Assert-PipelineAny
Assert-PipelineCount
#>
    [CmdletBinding()]
    Param(
        #The object from the pipeline.
        #
        #Note:
        #The argument for this parameter must come from the pipeline.
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [AllowNull()]
        [System.Object]
        $InputObject
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
                    'Assert-PipelineSingle must take its input from the pipeline.',
                    'InputObject'
                )),
                'PipelineArgumentOnly',
                [System.Management.Automation.ErrorCategory]::InvalidArgument,
                $InputObject
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }

        $anyItems = $false
    }

    Process
    {
        if ($anyItems) {
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

        $anyItems = $true
        ,$InputObject
    }

    End
    {
        $fail = -not $anyItems

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

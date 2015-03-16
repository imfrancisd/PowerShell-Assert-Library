function Assert-PipelineAny
{
<#
.Synopsis
Assert that the pipeline contains one or more objects.
.Description
This function is useful for asserting that a function returns one or more objects.

This function throws an error if any of the following conditions are met:
    *the pipeline contains less than one object
.Example
$letter = 'a', 'b', 'c' | Get-Random | Assert-PipelineAny
Throws an error if Get-Random does not return any objects.
.Example
$letter = 'a', 'b', 'c' | Get-Random | Assert-PipelineAny -Verbose
Throws an error if Get-Random does not return any objects.
The -Verbose switch will output the result of the assertion to the Verbose stream.
.Example
$letter = 'a', 'b', 'c' | Get-Random | Assert-PipelineAny -Debug
Throws an error if Get-Random does not return any objects.
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

$a = myFunc1 | Assert-PipelineAny
$b = myFunc2 | Assert-PipelineAny
$c = myFunc3 | Assert-PipelineAny
.Link
Assert-True
Assert-False
Assert-Null
Assert-NotNull
Assert-PipelineEmpty
Assert-PipelineSingle
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
                    'Assert-PipelineAny must take its input from the pipeline.',
                    'InputObject'
                )),
                'PipelineArgumentOnly',
                [System.Management.Automation.ErrorCategory]::InvalidArgument,
                $InputObject
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }

        $fail = $true
    }

    Process
    {
        $fail = $false
        ,$InputObject
    }

    End
    {
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

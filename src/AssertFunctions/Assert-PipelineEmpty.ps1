function Assert-PipelineEmpty
{
<#
.Synopsis
Assert that the pipeline does not contain any objects.
.Description
This function is useful for asserting that a function does not output any objects.

This function throws an error if any of the following conditions are met:
    *the pipeline contains an object
.Example
Get-ChildItem 'aFileThatDoesNotExist*' | Assert-PipelineEmpty
Throws an error if Get-ChildItem 'aFileThatDoesNotExist*' returns an object.
.Example
Get-ChildItem 'aFileThatDoesNotExist*' | Assert-PipelineEmpty -Verbose
Throws an error if Get-ChildItem 'aFileThatDoesNotExist*' returns an object.
The -Verbose switch will output the result of the assertion to the Verbose stream.
.Example
Get-ChildItem 'aFileThatDoesNotExist*' | Assert-PipelineEmpty -Debug
Throws an error if Get-ChildItem 'aFileThatDoesNotExist*' returns an object.
The -Debug switch gives you a chance to investigate a failing assertion before an error is thrown.
.Inputs
System.Object
.Outputs
None
.Notes
An example of how this function might be used in a unit test.

#display passing assertions
$VerbosePreference = [System.Management.Automation.ActionPreference]::Continue

#display debug prompt on failing assertions
$DebugPreference = [System.Management.Automation.ActionPreference]::Inquire

myFunc1 | Assert-PipelineEmpty
myFunc2 | Assert-PipelineEmpty
myFunc3 | Assert-PipelineEmpty
.Link
Assert-True
Assert-False
Assert-Null
Assert-NotNull
Assert-PipelineAny
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
                    'Assert-PipelineEmpty must take its input from the pipeline.',
                    'InputObject'
                )),
                'PipelineArgumentOnly',
                [System.Management.Automation.ErrorCategory]::InvalidArgument,
                $InputObject
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }

    Process
    {
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

    End
    {
        if ($VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue) {
            $message = 'Assertion passed: {0}, file {1}, line {2}' -f @(
                $MyInvocation.Line.Trim(),
                $MyInvocation.ScriptName,
                $MyInvocation.ScriptLineNumber
            )
            Write-Verbose -Message $message
        }
    }
}

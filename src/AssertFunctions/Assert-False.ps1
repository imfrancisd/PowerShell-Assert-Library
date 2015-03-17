function Assert-False
{
<#
.Synopsis
Assert that a value is the Boolean value $false.
.Description
This function throws an error if any of the following conditions are met:
    *the value being asserted is $null
    *the value being asserted is not of type System.Boolean
    *the value being asserted is not $false
.Example
Assert-False ($a -eq $b)
Throws an error if the expression ($a -eq $b) does not evaluate to $false.
.Example
Assert-False ($a -eq $b) -Verbose
Throws an error if the expression ($a -eq $b) does not evaluate to $false.
The -Verbose switch will output the result of the assertion to the Verbose stream.
.Example
Assert-False ($a -eq $b) -Debug
Throws an error if the expression ($a -eq $b) does not evaluate to $false.
The -Debug switch gives you a chance to investigate a failing assertion before an error is thrown.
.Inputs
System.Boolean
System.Object
.Outputs
None
.Notes
An example of how this function might be used in a unit test.

#display passing assertions
$VerbosePreference = [System.Management.Automation.ActionPreference]::Continue

#display debug prompt on failing assertions
$DebugPreference = [System.Management.Automation.ActionPreference]::Inquire

Assert-False ($null -eq $a)
Assert-False ($null -eq $b)
Assert-False ($a -eq $b)
.Link
Assert-True
Assert-Null
Assert-NotNull
Assert-PipelineEmpty
Assert-PipelineAny
Assert-PipelineSingle
Assert-PipelineCount
#>
    [CmdletBinding()]
    Param(
        #The value to assert.
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
        if ($null -eq $VerbosePreference) {
            $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
        }
    }

    $fail = -not (($Value -is [System.Boolean]) -and (-not $Value))

    if ($fail -or ($VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue)) {
        $message = 'Assertion {0}: {1}, file {2}, line {3}' -f @(
            $(if ($fail) {'failed'} else {'passed'}),
            $MyInvocation.Line.Trim(),
            $MyInvocation.ScriptName,
            $MyInvocation.ScriptLineNumber
        )

        Write-Verbose -Message $message

        if ($fail) {
            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference]
                if ($null -eq $DebugPreference) {
                    $DebugPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                }
            }
            Write-Debug -Message $message

            $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                (New-Object -TypeName 'System.Exception' -ArgumentList @($message)),
                'AssertionFailed',
                [System.Management.Automation.ErrorCategory]::OperationStopped,
                $Value
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }
}

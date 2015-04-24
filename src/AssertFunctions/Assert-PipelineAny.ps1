function Assert-PipelineAny
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [AllowNull()]
        [System.Object]
        $InputObject
    )

    Begin
    {
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
        _7ddd17460d1743b2b6e683ef649e01b7_setVerbosePreference -cmdlet $PSCmdlet

        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newPipelineArgumentOnlyError -functionName 'Assert-PipelineAny' -argumentName 'InputObject' -argumentValue $InputObject))
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
            $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

            Write-Verbose -Message $message

            if ($fail) {
                _7ddd17460d1743b2b6e683ef649e01b7_setDebugPreference -cmdlet $PSCmdlet
                Write-Debug -Message $message
                $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $InputObject))
            }
        }
    }
}

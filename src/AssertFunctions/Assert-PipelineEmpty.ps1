function Assert-PipelineEmpty
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowNull()]
        [System.Object]
        $InputObject
    )

    begin
    {
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
        }

        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newPipelineArgumentOnlyError -functionName $PSCmdlet.MyInvocation.MyCommand.Name -argumentName 'InputObject' -argumentValue $InputObject))
        }
    }

    process
    {
        #fail immediately
        #do not wait for all pipeline objects

        $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail

        $PSCmdlet.WriteVerbose($message)

        if (-not $PSBoundParameters.ContainsKey('Debug')) {
            $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
        }
        $PSCmdlet.WriteDebug($message)
        $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $InputObject))
    }

    end
    {
        if (([System.Int32]$VerbosePreference)) {
            $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation
            $PSCmdlet.WriteVerbose($message)
        }
    }
}

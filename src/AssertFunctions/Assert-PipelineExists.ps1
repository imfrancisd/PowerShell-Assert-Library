function Assert-PipelineExists
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [AllowNull()]
        [System.Object]
        $InputObject,

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [System.Management.Automation.ScriptBlock]
        $Predicate
    )

    Begin
    {
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = [System.Int32]($PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference])
        }

        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newPipelineArgumentOnlyError -functionName 'Assert-PipelineCount' -argumentName 'InputObject' -argumentValue $InputObject))
        }

        $fail = $true
    }

    Process
    {
        if ($fail) {
            try   {$result = & $Predicate $InputObject}
            catch {$PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newPredicateFailedError -errorRecord $_ -predicate $Predicate))}
        
            if (($result -is [System.Boolean]) -and $result) {
                $fail = $false
            }
        }
        ,$InputObject
    }

    End
    {
        if ($fail -or $VerbosePreference) {
            $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

            Write-Verbose -Message $message

            if ($fail) {
                if (-not $PSBoundParameters.ContainsKey('Debug')) {
                    $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
                }
                Write-Debug -Message $message
                $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $null))
            }
        }
    }
}
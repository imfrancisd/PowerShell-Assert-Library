function Assert-PipelineCount
{
    [CmdletBinding(DefaultParameterSetName='Equals')]
    [OutputType([System.Object])]
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
        }

        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newPipelineArgumentOnlyError -functionName 'Assert-PipelineCount' -argumentName 'InputObject' -argumentValue $InputObject))
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

            $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail

            Write-Verbose -Message $message

            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $InputObject))
        }

        ,$InputObject
    }

    End
    {
        $fail = & $failAssert

        if ($fail -or ([System.Int32]$VerbosePreference)) {
            $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

            Write-Verbose -Message $message

            if ($fail) {
                if (-not $PSBoundParameters.ContainsKey('Debug')) {
                    $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
                }
                Write-Debug -Message $message
                $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $InputObject))
            }
        }
    }
}

function Assert-PipelineCount
{
    [CmdletBinding(DefaultParameterSetName = 'Equals')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowNull()]
        [System.Object]
        $InputObject,

        [Parameter(Mandatory = $true, ParameterSetName = 'Equals', Position = 0)]
        [Alias('eq')]
        [System.Int64]
        $Equals,

        [Parameter(Mandatory = $true, ParameterSetName = 'Maximum')]
        [Alias('max')]
        [System.Int64]
        $Maximum,

        [Parameter(Mandatory = $true, ParameterSetName = 'Minimum')]
        [Alias('min')]
        [System.Int64]
        $Minimum,

        [Parameter(Mandatory = $true, ParameterSetName = 'NotEquals')]
        [Alias('ne')]
        [System.Int64]
        $NotEquals
    )

    begin
    {
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
        }

        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newPipelineArgumentOnlyError -functionName $PSCmdlet.MyInvocation.MyCommand.Name -argumentName 'InputObject' -argumentValue $InputObject))
        } else {
            #NOTE
            #
            #If StrictMode is on, and the $InputObject pipeline variable has no value (because process block does not run),
            #then using the $InputObject variable in the end block will generate an error.
            #Specifying a default value for $InputObject in the param block does not work.
            #Specifying a default value for $InputObject in the begin block is the least confusing option.
            #Even if the $InputObject pipeline variable is not used in the end block, just set it anyway so StrictMode will definitely work.
            $InputObject = $null
        }

        #Make sure we can count higher than -Equals, -Minimum, and -Maximum.
        [System.UInt64]$inputCount = 0

        if ($PSCmdlet.ParameterSetName -eq 'Equals') {
            $failEarly  = {$inputCount -gt $Equals}
            $failAssert = {$inputCount -ne $Equals}
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'NotEquals') {
            $failEarly  = {$false}
            $failAssert = {$inputCount -eq $NotEquals}
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'Maximum') {
            $failEarly  = {$inputCount -gt $Maximum}
            $failAssert = $failEarly
        }
        else {
            $failEarly  = {$false}
            $failAssert = {$inputCount -lt $Minimum}
        }
    }

    process
    {
        $inputCount++

        if ((& $failEarly)) {
            #fail immediately
            #do not wait for all pipeline objects

            $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail

            Write-Verbose -Message $message

            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $InputObject))
        }

        ,$InputObject
    }

    end
    {
        $fail = & $failAssert

        if ($fail -or ([System.Int32]$VerbosePreference)) {
            $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

            Write-Verbose -Message $message

            if ($fail) {
                if (-not $PSBoundParameters.ContainsKey('Debug')) {
                    $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
                }
                Write-Debug -Message $message
                $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $InputObject))
            }
        }
    }
}

function Assert-All
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [System.Collections.ICollection]
        $Collection,

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=1)]
        [System.Management.Automation.ScriptBlock]
        $Predicate
    )

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

    $fail = $false

    foreach ($item in $Collection.psbase.GetEnumerator()) {
        try   {$result = & $Predicate $item}
        catch {
            $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                (New-Object -TypeName 'System.InvalidOperationException' -ArgumentList @('Could not invoke predicate.', $_.Exception)),
                'PredicateError',
                [System.Management.Automation.ErrorCategory]::OperationStopped,
                $Predicate
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
        
        if (-not (($result -is [System.Boolean]) -and $result)) {
            $fail = $true
            break
        }
    }

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
                $Collection
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }
}

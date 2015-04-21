function Assert-All
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [System.Collections.ICollection]
        $private:Collection,

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=1)]
        [System.Management.Automation.ScriptBlock]
        $private:Predicate
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

    $private:fail = $false

    foreach ($private:item in $private:Collection.psbase.GetEnumerator()) {
        try   {$private:result = & $private:Predicate $private:item}
        catch {
            $private:errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                (New-Object -TypeName 'System.InvalidOperationException' -ArgumentList @('Could not invoke predicate.', $_.Exception)),
                'PredicateError',
                [System.Management.Automation.ErrorCategory]::OperationStopped,
                $private:Predicate
            )
            $PSCmdlet.ThrowTerminatingError($private:errorRecord)
        }
        
        if (-not (($private:result -is [System.Boolean]) -and $private:result)) {
            $private:fail = $true
            break
        }
    }

    if ($private:fail -or ($VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue)) {
        $private:message = 'Assertion {0}: {1}, file {2}, line {3}' -f @(
            $(if ($fail) {'failed'} else {'passed'}),
            $MyInvocation.Line.Trim(),
            $MyInvocation.ScriptName,
            $MyInvocation.ScriptLineNumber
        )

        Write-Verbose -Message $private:message

        if ($private:fail) {
            Write-Debug -Message $private:message

            $private:errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                (New-Object -TypeName 'System.Exception' -ArgumentList @($private:message)),
                'AssertionFailed',
                [System.Management.Automation.ErrorCategory]::OperationStopped,
                $private:Collection
            )
            $PSCmdlet.ThrowTerminatingError($private:errorRecord)
        }
    }
}

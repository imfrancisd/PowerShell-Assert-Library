function Assert-Exists
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Collection,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 1)]
        [System.Management.Automation.ScriptBlock]
        $Predicate,

        [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
        [ValidateSet('Any', 'Single', 'Multiple')]
        [System.String]
        $Quantity = 'Any'
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
    }
    $fail = $true

    if ($Collection -is [System.Collections.ICollection]) {
        $exists = $false
        $found = 0
        $enumerator = & $_7ddd17460d1743b2b6e683ef649e01b7_getEnumerator $Collection
        [System.Int32]$index = -1

        foreach ($item in $enumerator) {
            $index++
            $result = $null
            try   {$result = do {& $Predicate $item $index} while ($false)}
            catch {$PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newPredicateFailedError -errorRecord $_ -predicate $Predicate))}

            if (($result -is [System.Boolean]) -and $result) {
                $found++
                if ($Quantity -eq 'Any') {
                    $exists = $true
                    break
                }
                if ($found -gt 1) {
                    $exists = $Quantity -eq 'Multiple'
                    break
                }
            }
        }

        $fail = -not ($exists -or (($found -eq 1) -and ($Quantity -eq 'Single')))
    }

    if ($fail -or ([System.Int32]$VerbosePreference)) {
        $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

        Write-Verbose -Message $message

        if ($fail) {
            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $Collection))
        }
    }
}

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
    _7ddd17460d1743b2b6e683ef649e01b7_setVerbosePreference -cmdlet $PSCmdlet

    $fail = $false

    foreach ($item in $Collection.psbase.GetEnumerator()) {
        try   {$result = & $Predicate $item}
        catch {$PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newPredicateFailedError -errorRecord $_ -predicate $Predicate))}
        
        if (-not (($result -is [System.Boolean]) -and $result)) {
            $fail = $true
            break
        }
    }

    if ($fail -or ($VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue)) {
        $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

        Write-Verbose -Message $message
        if ($fail) {
            _7ddd17460d1743b2b6e683ef649e01b7_setDebugPreference -cmdlet $PSCmdlet
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $Collection))
        }
    }
}

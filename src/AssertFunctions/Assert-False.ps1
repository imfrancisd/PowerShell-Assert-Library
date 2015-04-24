function Assert-False
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    _7ddd17460d1743b2b6e683ef649e01b7_setVerbosePreference -cmdlet $PSCmdlet

    $fail = -not (($Value -is [System.Boolean]) -and (-not $Value))

    if ($fail -or ($VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue)) {
        $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

        Write-Verbose -Message $message

        if ($fail) {
            _7ddd17460d1743b2b6e683ef649e01b7_setDebugPreference -cmdlet $PSCmdlet
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $Value))
        }
    }
}

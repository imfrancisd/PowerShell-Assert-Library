function _7ddd17460d1743b2b6e683ef649e01b7_setVerbosePreference
{
    Param(
        [System.Management.Automation.PSCmdlet]
        $cmdlet
    )
    if (-not $cmdlet.MyInvocation.BoundParameters.ContainsKey('Verbose')) {
        $preference = $cmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
        if ($null -eq $preference) {
            Set-Variable -Name 'VerbosePreference' -Scope 1 -Value ([System.Management.Automation.ActionPreference]::SilentlyContinue)
        } else {
            Set-Variable -Name 'VerbosePreference' -Scope 1 -Value $preference
        }
    }
}

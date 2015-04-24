function _7ddd17460d1743b2b6e683ef649e01b7_setDebugPreference
{
    Param(
        [System.Management.Automation.PSCmdlet]
        $cmdlet
    )
    if (-not $cmdlet.MyInvocation.BoundParameters.ContainsKey('Debug')) {
        $preference = $cmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference]
        if ($null -eq $preference) {
            Set-Variable -Name 'DebugPreference' -Scope 1 -Value ([System.Management.Automation.ActionPreference]::SilentlyContinue)
        } else {
            Set-Variable -Name 'DebugPreference' -Scope 1 -Value $preference
        }
    }
}

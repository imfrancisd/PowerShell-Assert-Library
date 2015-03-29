[CmdletBinding()]
Param(
    [System.Management.Automation.SwitchParameter]
    $Silent
)

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
if ($Silent) {
    $headerVerbosity = [System.Management.Automation.ActionPreference]::SilentlyContinue
    $VerbosePreference = $headerVerbosity
} else {
    $headerVerbosity = [System.Management.Automation.ActionPreference]::Continue
}

& {
    Write-Verbose -Message 'Test Test-Guid -IsGuid' -Verbose:$headerVerbosity

    $guids = [System.Guid[]]@('00000000-0000-0000-0000-000000000000', '7ddd1746-0d17-43b2-b6e6-83ef649e01b7')
    $nonGuids = @(@($guids[0]), @($guids[1]), $true, $false, $null, 0, 1, '00000000-0000-0000-0000-000000000000', '7ddd1746-0d17-43b2-b6e6-83ef649e01b7')

    foreach ($guid in $guids) {
        Assert-True  (Test-Guid $guid)
        Assert-True  (Test-Guid $guid -IsGuid)
        Assert-True  (Test-Guid $guid -IsGuid:$true)
        Assert-False (Test-Guid $guid -IsGuid:$false)

        Assert-True  (Test-Guid -Value $guid)
        Assert-True  (Test-Guid -Value $guid -IsGuid)
        Assert-True  (Test-Guid -Value $guid -IsGuid:$true)
        Assert-False (Test-Guid -Value $guid -IsGuid:$false)
    }

    foreach ($nonGuid in $nonGuids) {
        Assert-False (Test-Guid $nonGuid)
        Assert-False (Test-Guid $nonGuid -IsGuid)
        Assert-False (Test-Guid $nonGuid -IsGuid:$true)
        Assert-True  (Test-Guid $nonGuid -IsGuid:$false)

        Assert-False (Test-Guid -Value $nonGuid)
        Assert-False (Test-Guid -Value $nonGuid -IsGuid)
        Assert-False (Test-Guid -Value $nonGuid -IsGuid:$true)
        Assert-True  (Test-Guid -Value $nonGuid -IsGuid:$false)
    }
}

Write-Warning -Message 'Remaining tests not implemented here.' -WarningAction 'Continue'

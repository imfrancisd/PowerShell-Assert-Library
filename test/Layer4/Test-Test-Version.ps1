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
    Write-Verbose -Message 'Test Test-Version -IsVersion' -Verbose:$headerVerbosity

    $versions = [System.Version[]]@('0.0', '1.0', '2.7.2', '3.1.41.6')
    $nonVersions = @(@($versions[0]), @($versions[1]), $true, $false, $null, 0.0, 1.0, '0.0', '1.0')

    foreach ($version in $versions) {
        Assert-True  (Test-Version $version)
        Assert-True  (Test-Version $version -IsVersion)
        Assert-True  (Test-Version $version -IsVersion:$true)
        Assert-False (Test-Version $version -IsVersion:$false)

        Assert-True  (Test-Version -Value $version)
        Assert-True  (Test-Version -Value $version -IsVersion)
        Assert-True  (Test-Version -Value $version -IsVersion:$true)
        Assert-False (Test-Version -Value $version -IsVersion:$false)
    }

    foreach ($nonVersion in $nonVersions) {
        Assert-False (Test-Version $nonVersion)
        Assert-False (Test-Version $nonVersion -IsVersion)
        Assert-False (Test-Version $nonVersion -IsVersion:$true)
        Assert-True  (Test-Version $nonVersion -IsVersion:$false)

        Assert-False (Test-Version -Value $nonVersion)
        Assert-False (Test-Version -Value $nonVersion -IsVersion)
        Assert-False (Test-Version -Value $nonVersion -IsVersion:$true)
        Assert-True  (Test-Version -Value $nonVersion -IsVersion:$false)
    }
}

Write-Warning -Message 'Remaining tests not implemented here.' -WarningAction 'Continue'

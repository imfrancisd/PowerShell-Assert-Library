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
    Write-Verbose -Message 'Test Test-TimeSpan -IsTimeSpan' -Verbose:$headerVerbosity

    $timeSpans = [System.TimeSpan[]]@(0, '1', 76200000000, 116550000000)
    $nonTimeSpans = @(@($timeSpans[0]), @($timeSpans[1]), $true, $false, $null, 0.0, 1.0, '00:00:00', '1.00:00:00')

    foreach ($timeSpan in $timeSpans) {
        Assert-True  (Test-TimeSpan $timeSpan)
        Assert-True  (Test-TimeSpan $timeSpan -IsTimeSpan)
        Assert-True  (Test-TimeSpan $timeSpan -IsTimeSpan:$true)
        Assert-False (Test-TimeSpan $timeSpan -IsTimeSpan:$false)

        Assert-True  (Test-TimeSpan -Value $timeSpan)
        Assert-True  (Test-TimeSpan -Value $timeSpan -IsTimeSpan)
        Assert-True  (Test-TimeSpan -Value $timeSpan -IsTimeSpan:$true)
        Assert-False (Test-TimeSpan -Value $timeSpan -IsTimeSpan:$false)
    }

    foreach ($nonTimeSpan in $nonTimeSpans) {
        Assert-False (Test-TimeSpan $nonTimeSpan)
        Assert-False (Test-TimeSpan $nonTimeSpan -IsTimeSpan)
        Assert-False (Test-TimeSpan $nonTimeSpan -IsTimeSpan:$true)
        Assert-True  (Test-TimeSpan $nonTimeSpan -IsTimeSpan:$false)

        Assert-False (Test-TimeSpan -Value $nonTimeSpan)
        Assert-False (Test-TimeSpan -Value $nonTimeSpan -IsTimeSpan)
        Assert-False (Test-TimeSpan -Value $nonTimeSpan -IsTimeSpan:$true)
        Assert-True  (Test-TimeSpan -Value $nonTimeSpan -IsTimeSpan:$false)
    }
}

Write-Warning -Message 'Remaining tests not implemented here.' -WarningAction 'Continue'

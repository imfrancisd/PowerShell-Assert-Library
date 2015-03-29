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
    Write-Verbose -Message 'Test Test-DateTime -IsDateTime' -Verbose:$headerVerbosity

    $dateTimes = [System.DateTime[]]@(0, 1, '2015-06-28', '2016-03-14')
    $nonDateTimes = @(@($dateTimes[0]), @($dateTimes[1]), $true, $false, $null, 0, 1, '2015-06-28', '2016-03-14')

    foreach ($dateTime in $dateTimes) {
        Assert-True  (Test-DateTime $dateTime)
        Assert-True  (Test-DateTime $dateTime -IsDateTime)
        Assert-True  (Test-DateTime $dateTime -IsDateTime:$true)
        Assert-False (Test-DateTime $dateTime -IsDateTime:$false)

        Assert-True  (Test-DateTime -Value $dateTime)
        Assert-True  (Test-DateTime -Value $dateTime -IsDateTime)
        Assert-True  (Test-DateTime -Value $dateTime -IsDateTime:$true)
        Assert-False (Test-DateTime -Value $dateTime -IsDateTime:$false)
    }

    foreach ($nonDateTime in $nonDateTimes) {
        Assert-False (Test-DateTime $nonDateTime)
        Assert-False (Test-DateTime $nonDateTime -IsDateTime)
        Assert-False (Test-DateTime $nonDateTime -IsDateTime:$true)
        Assert-True  (Test-DateTime $nonDateTime -IsDateTime:$false)

        Assert-False (Test-DateTime -Value $nonDateTime)
        Assert-False (Test-DateTime -Value $nonDateTime -IsDateTime)
        Assert-False (Test-DateTime -Value $nonDateTime -IsDateTime:$true)
        Assert-True  (Test-DateTime -Value $nonDateTime -IsDateTime:$false)
    }
}

Write-Warning -Message 'Remaining tests not implemented here.' -WarningAction 'Continue'

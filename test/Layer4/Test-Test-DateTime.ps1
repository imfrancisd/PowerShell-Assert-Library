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
    Write-Verbose -Message 'Test Test-DateTime with get-help -full' -Verbose:$headerVerbosity

    $err = try {$fullHelp = Get-Help Test-DateTime -Full} catch {$_}

    Assert-Null $err
    Assert-True ($fullHelp.Name -is [System.String])
    Assert-True ($fullHelp.Name.Equals('Test-DateTime', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($fullHelp.description -is [System.Collections.ICollection])
    Assert-True ($fullHelp.description.Count -gt 0)
    Assert-NotNull $fullHelp.examples
    Assert-True (0 -lt @($fullHelp.examples.example).Count)
    Assert-True ('' -ne @($fullHelp.examples.example)[0].code)
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

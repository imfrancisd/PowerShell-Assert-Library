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
    Write-Verbose -Message 'Test Test-Number with get-help -full' -Verbose:$headerVerbosity

    $err = try {$fullHelp = Get-Help Test-Number -Full} catch {$_}

    Assert-Null $err
    Assert-True ($fullHelp.Name -is [System.String])
    Assert-True ($fullHelp.Name.Equals('Test-Number', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($fullHelp.description -is [System.Collections.ICollection])
    Assert-True ($fullHelp.description.Count -gt 0)
    Assert-NotNull $fullHelp.examples
    Assert-True (0 -lt @($fullHelp.examples.example).Count)
    Assert-True ('' -ne @($fullHelp.examples.example)[0].code)
}

& {
    Write-Verbose -Message 'Test Test-Number -IsNumber' -Verbose:$headerVerbosity

    $numbers = [System.Object[]]@(0, [System.Single]1.0, 2.718, [System.Decimal]3.1416)
    $nonNumbers = @(@($numbers[0]), @($numbers[1]), $true, $false, $null, '2.718', '3.1416')

    foreach ($number in $numbers) {
        Assert-True  (Test-Number $number)
        Assert-True  (Test-Number $number -IsNumber)
        Assert-True  (Test-Number $number -IsNumber:$true)
        Assert-False (Test-Number $number -IsNumber:$false)

        Assert-True  (Test-Number -Value $number)
        Assert-True  (Test-Number -Value $number -IsNumber)
        Assert-True  (Test-Number -Value $number -IsNumber:$true)
        Assert-False (Test-Number -Value $number -IsNumber:$false)
    }

    foreach ($nonNumber in $nonNumbers) {
        Assert-False (Test-Number $nonNumber)
        Assert-False (Test-Number $nonNumber -IsNumber)
        Assert-False (Test-Number $nonNumber -IsNumber:$true)
        Assert-True  (Test-Number $nonNumber -IsNumber:$false)

        Assert-False (Test-Number -Value $nonNumber)
        Assert-False (Test-Number -Value $nonNumber -IsNumber)
        Assert-False (Test-Number -Value $nonNumber -IsNumber:$true)
        Assert-True  (Test-Number -Value $nonNumber -IsNumber:$false)
    }
}

Write-Warning -Message 'Remaining tests not implemented here.' -WarningAction 'Continue'

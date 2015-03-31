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
    Write-Verbose -Message 'Test Test-String with get-help -full' -Verbose:$headerVerbosity

    $err = try {$fullHelp = Get-Help Test-String -Full} catch {$_}

    Assert-Null $err
    Assert-True ($fullHelp.Name -is [System.String])
    Assert-True ($fullHelp.Name.Equals('Test-String', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($fullHelp.description -is [System.Collections.ICollection])
    Assert-True ($fullHelp.description.Count -gt 0)
    Assert-NotNull $fullHelp.examples
    Assert-True (0 -lt @($fullHelp.examples.example).Count)
    Assert-True ('' -ne @($fullHelp.examples.example)[0].code)
}

& {
    Write-Verbose -Message 'Test Test-String -IsString' -Verbose:$headerVerbosity

    $strings = [System.String[]]@('', ' ', '  ', '2.72', '2015-03-14', 'hello world')
    $nonStrings = @(@($strings[0]), @($strings[1]), $true, $false, $null, 0, 1)

    foreach ($string in $strings) {
        Assert-True  (Test-String $string)
        Assert-True  (Test-String $string -IsString)
        Assert-True  (Test-String $string -IsString:$true)
        Assert-False (Test-String $string -IsString:$false)

        Assert-True  (Test-String -Value $string)
        Assert-True  (Test-String -Value $string -IsString)
        Assert-True  (Test-String -Value $string -IsString:$true)
        Assert-False (Test-String -Value $string -IsString:$false)
    }

    foreach ($nonString in $nonStrings) {
        Assert-False (Test-String $nonString)
        Assert-False (Test-String $nonString -IsString)
        Assert-False (Test-String $nonString -IsString:$true)
        Assert-True  (Test-String $nonString -IsString:$false)

        Assert-False (Test-String -Value $nonString)
        Assert-False (Test-String -Value $nonString -IsString)
        Assert-False (Test-String -Value $nonString -IsString:$true)
        Assert-True  (Test-String -Value $nonString -IsString:$false)
    }
}

Write-Warning -Message 'Remaining tests not implemented here.' -WarningAction 'Continue'

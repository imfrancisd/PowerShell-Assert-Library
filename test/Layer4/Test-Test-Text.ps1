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
    Write-Verbose -Message 'Test Test-Text with get-help -full' -Verbose:$headerVerbosity

    $err = try {$fullHelp = Get-Help Test-Text -Full} catch {$_}

    Assert-Null $err
    Assert-True ($fullHelp.Name -is [System.String])
    Assert-True ($fullHelp.Name.Equals('Test-Text', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($fullHelp.description -is [System.Collections.ICollection])
    Assert-True ($fullHelp.description.Count -gt 0)
    Assert-NotNull $fullHelp.examples
    Assert-True (0 -lt @($fullHelp.examples.example).Count)
    Assert-True ('' -ne @($fullHelp.examples.example)[0].code)
}

& {
    Write-Verbose -Message 'Test Test-Text -IsText' -Verbose:$headerVerbosity

    $texts = [System.String[]]@('', ' ', '  ', '2.72', '2015-03-14', 'hello world')
    $nonTexts = @(@($texts[0]), @($texts[1]), $true, $false, $null, 0, 1)

    foreach ($text in $texts) {
        Assert-True  (Test-Text $text)
        Assert-True  (Test-Text $text -IsText)
        Assert-True  (Test-Text $text -IsText:$true)
        Assert-False (Test-Text $text -IsText:$false)

        Assert-True  (Test-Text -Value $text)
        Assert-True  (Test-Text -Value $text -IsText)
        Assert-True  (Test-Text -Value $text -IsText:$true)
        Assert-False (Test-Text -Value $text -IsText:$false)
    }

    foreach ($nonText in $nonTexts) {
        Assert-False (Test-Text $nonText)
        Assert-False (Test-Text $nonText -IsText)
        Assert-False (Test-Text $nonText -IsText:$true)
        Assert-True  (Test-Text $nonText -IsText:$false)

        Assert-False (Test-Text -Value $nonText)
        Assert-False (Test-Text -Value $nonText -IsText)
        Assert-False (Test-Text -Value $nonText -IsText:$true)
        Assert-True  (Test-Text -Value $nonText -IsText:$false)
    }
}

Write-Warning -Message 'Remaining tests not implemented here.' -WarningAction 'Continue'

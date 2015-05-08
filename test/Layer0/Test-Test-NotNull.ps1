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

$nonBooleanFalse = @(
    0, '', @($null), @(0), @(''), @($false), @(), @(,@())
)
$nonBooleanTrue = @(
    1, 'True', 'False', @(1), @('True'), @('False'), @($true), @(,@(1)), @(,@($true))
)

& {
    Write-Verbose -Message 'Test Test-NotNull with get-help -full' -Verbose:$headerVerbosity

    $err = try {$fullHelp = Get-Help Test-NotNull -Full} catch {$_}

    $pass =
        ($null -eq $err) -and
        ($fullHelp.Name -is [System.String]) -and
        ($fullHelp.Name.Equals('Test-NotNull', [System.StringComparison]::OrdinalIgnoreCase)) -and
        ($fullHelp.description -is [System.Collections.ICollection]) -and
        ($fullHelp.description.Count -gt 0) -and
        ($null -ne $fullHelp.examples) -and
        (0 -lt @($fullHelp.examples.example).Count) -and
        ('' -ne @($fullHelp.examples.example)[0].code)

    if (-not $pass) {
        $message = 'Test-NotNull failed with get-help -full.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    Write-Verbose -Message 'Test Test-NotNull parameters' -Verbose:$headerVerbosity

    $message = 'Test-NotNull failed parameter tests.'

    $paramSets = @((Get-Command -Name Test-NotNull).ParameterSets)
    if (1 -ne $paramSets.Count) {
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }

    $valueParam = $paramSets[0].Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)}
    if ($null -eq $valueParam) {
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }

    $pass =
        ($valueParam.IsMandatory) -and
        ($valueParam.ParameterType -eq [System.Object]) -and
        (-not $valueParam.ValueFromPipeline) -and
        (-not $valueParam.ValueFromPipelineByPropertyName) -and
        (-not $valueParam.ValueFromRemainingArguments) -and
        (0 -eq $valueParam.Position) -and
        (0 -eq $valueParam.Aliases.Count)

    if (-not $pass) {
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    Write-Verbose -Message 'Test Test-NotNull with Boolean $null' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {Test-NotNull $null -OutVariable out1 | Out-Null} catch {$_}

    $pass =
        ($out1.Count -eq 1) -and
        ($out1[0] -is [System.Boolean]) -and
        (-not $out1[0]) -and
        ($null -eq $er1)

    if (-not $pass) {
        $message = 'Test-NotNull failed with $null value.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    Write-Verbose -Message 'Test Test-NotNull with Boolean $false' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {Test-NotNull $false -OutVariable out1 | Out-Null} catch {$_}

    $pass =
        ($out1.Count -eq 1) -and
        ($out1[0] -is [System.Boolean]) -and
        ($out1[0]) -and
        ($null -eq $er1)

    if (-not $pass) {
        $message = 'Test-NotNull failed with $false value.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    Write-Verbose -Message 'Test Test-NotNull with $true' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {Test-NotNull $true -OutVariable out1 | Out-Null} catch {$_}

    $pass =
        ($out1.Count -eq 1) -and
        ($out1[0] -is [System.Boolean]) -and
        ($out1[0]) -and
        ($null -eq $er1)

    if (-not $pass) {
        $message = 'Test-NotNull failed with $true value.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    Write-Verbose -Message 'Test Test-NotNull with Non-Booleans that are convertible to $true' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanTrue) {
        $out1 = New-Object -TypeName 'System.Collections.ArrayList'
        $er1 = try {Test-NotNull $item -OutVariable out1 | Out-Null} catch {$_}

        $pass =
            ($out1.Count -eq 1) -and
            ($out1[0] -is [System.Boolean]) -and
            ($out1[0]) -and
            ($null -eq $er1)

        if (-not $pass) {
            $message = 'Test-NotNull failed with Non-Boolean that is convertible to $true: ' + "$item"
            throw New-Object 'System.Exception' -ArgumentList @($message)
        }
    }
}

& {
    Write-Verbose -Message 'Test Test-NotNull with Non-Booleans that are convertible to $false' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanFalse) {
        $out1 = New-Object -TypeName 'System.Collections.ArrayList'
        $er1 = try {Test-NotNull $item -OutVariable out1 | Out-Null} catch {$_}

        $pass =
            ($out1.Count -eq 1) -and
            ($out1[0] -is [System.Boolean]) -and
            ($out1[0]) -and
            ($null -eq $er1)

        if (-not $pass) {
            $message = 'Test-NotNull failed with Non-Boolean that is convertible to $false: ' + "$item"
            throw New-Object 'System.Exception' -ArgumentList @($message)
        }
    }
}

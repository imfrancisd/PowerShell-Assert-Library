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
    Write-Verbose -Message 'Test Assert-NotNull with get-help -full' -Verbose:$headerVerbosity

    $err = try {$fullHelp = Get-Help Assert-NotNull -Full} catch {$_}

    $pass =
        ($null -eq $err) -and
        ($fullHelp.Name -is [System.String]) -and
        ($fullHelp.Name.Equals('Assert-NotNull', [System.StringComparison]::OrdinalIgnoreCase)) -and
        ($fullHelp.description -is [System.Collections.ICollection]) -and
        ($fullHelp.description.Count -gt 0) -and
        ($null -ne $fullHelp.examples) -and
        (0 -lt @($fullHelp.examples.example).Count) -and
        ('' -ne @($fullHelp.examples.example)[0].code)

    if (-not $pass) {
        $message = 'Assert-NotNull failed with get-help -full.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    Write-Verbose -Message 'Test Assert-NotNull with Boolean $null' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {Assert-NotNull $null -OutVariable out1 | Out-Null} catch {$_}
    $er2 = try {Assert-NotNull -Value $null -OutVariable out2 | Out-Null} catch {$_}

    $pass =
        ($out1.Count -eq 0) -and
        ($out2.Count -eq 0) -and
        ($er1 -is [System.Management.Automation.ErrorRecord]) -and
        ($er1.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-NotNull', [System.StringComparison]::OrdinalIgnoreCase)) -and
        ($er2 -is [System.Management.Automation.ErrorRecord]) -and
        ($er2.FullyQualifiedErrorId.Equals('AssertionFailed,Assert-NotNull', [System.StringComparison]::OrdinalIgnoreCase))

    if (-not $pass) {
        $message = 'Assert-NotNull failed with $null value.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    Write-Verbose -Message 'Test Assert-NotNull with Boolean $false' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {Assert-NotNull $false -OutVariable out1 | Out-Null} catch {$_}
    $er2 = try {Assert-NotNull -Value $false -OutVariable out2 | Out-Null} catch {$_}

    $pass =
        ($out1.Count -eq 0) -and
        ($out2.Count -eq 0) -and
        ($null -eq $er1) -and
        ($null -eq $er2)

    if (-not $pass) {
        $message = 'Assert-NotNull failed with $false value.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    Write-Verbose -Message 'Test Assert-NotNull with $true' -Verbose:$headerVerbosity

    $out1 = New-Object -TypeName 'System.Collections.ArrayList'
    $out2 = New-Object -TypeName 'System.Collections.ArrayList'
    $er1 = try {Assert-NotNull $true -OutVariable out1 | Out-Null} catch {$_}
    $er2 = try {Assert-NotNull -Value $true -OutVariable out2 | Out-Null} catch {$_}

    $pass =
        ($out1.Count -eq 0) -and
        ($out2.Count -eq 0) -and
        ($null -eq $er1) -and
        ($null -eq $er2)

    if (-not $pass) {
        $message = 'Assert-NotNull failed with $true value.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    Write-Verbose -Message 'Test Assert-NotNull with Non-Booleans that are convertible to $true' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanTrue) {
        $out1 = New-Object -TypeName 'System.Collections.ArrayList'
        $out2 = New-Object -TypeName 'System.Collections.ArrayList'
        $er1 = try {Assert-NotNull $item -OutVariable out1 | Out-Null} catch {$_}
        $er2 = try {Assert-NotNull -Value $item -OutVariable out2 | Out-Null} catch {$_}

        $pass =
            ($out1.Count -eq 0) -and
            ($out2.Count -eq 0) -and
            ($null -eq $er1) -and
            ($null -eq $er2)

        if (-not $pass) {
            $message = 'Assert-NotNull failed with Non-Boolean that is convertible to $true: ' + "$item"
            throw New-Object 'System.Exception' -ArgumentList @($message)
        }
    }
}

& {
    Write-Verbose -Message 'Test Assert-NotNull with Non-Booleans that are convertible to $false' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanFalse) {
        $out1 = New-Object -TypeName 'System.Collections.ArrayList'
        $out2 = New-Object -TypeName 'System.Collections.ArrayList'
        $er1 = try {Assert-NotNull $item -OutVariable out1 | Out-Null} catch {$_}
        $er2 = try {Assert-NotNull -Value $item -OutVariable out2 | Out-Null} catch {$_}

    $pass =
        ($out1.Count -eq 0) -and
        ($out2.Count -eq 0) -and
        ($null -eq $er1) -and
        ($null -eq $er2)

        if (-not $pass) {
            $message = 'Assert-NotNull failed with Non-Boolean that is convertible to $false: ' + "$item"
            throw New-Object 'System.Exception' -ArgumentList @($message)
        }
    }
}

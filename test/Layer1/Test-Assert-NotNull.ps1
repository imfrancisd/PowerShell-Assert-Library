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
    Write-Verbose -Message 'Test Assert-NotNull with $null' -Verbose:$headerVerbosity

    $e1 = try {Assert-NotNull $null | Out-Null} catch {$_.Exception}
    $e2 = try {Assert-NotNull -Value $null | Out-Null} catch {$_.Exception}

    $fail =
        ($null -eq $e1) -or
        ($null -eq $e2) -or
        (-not $e1.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)) -or
        (-not $e2.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase))

    if ($fail) {
        $message = 'Assert-NotNull failed with $null value.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    Write-Verbose -Message 'Test Assert-NotNull with Boolean $false' -Verbose:$headerVerbosity

    $e1 = try {Assert-NotNull $false | Out-Null} catch {$_.Exception}
    $e2 = try {Assert-NotNull -Value $false | Out-Null} catch {$_.Exception}

    $fail = ($null -ne $e1) -or ($null -ne $e2)

    if ($fail) {
        $message = 'Assert-NotNull failed with $false value.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    Write-Verbose -Message 'Test Assert-NotNull with Boolean $true' -Verbose:$headerVerbosity

    $e1 = try {Assert-NotNull $true | Out-Null} catch {$_.Exception}
    $e2 = try {Assert-NotNull -Value $true | Out-Null} catch {$_.Exception}

    $fail = ($null -ne $e1) -or ($null -ne $e2)

    if ($fail) {
        $message = 'Assert-NotNull failed with $true value.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    Write-Verbose -Message 'Test Assert-NotNull with Non-Booleans that are convertible to $true' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanTrue) {
        $e1 = try {Assert-NotNull $item | Out-Null} catch {$_.Exception}
        $e2 = try {Assert-NotNull -Value $item | Out-Null} catch {$_.Exception}

        $fail = ($null -ne $e1) -or ($null -ne $e2)

        if ($fail) {
            $message = 'Assert-NotNull failed with Non-Boolean that is convertible to $true: ' + "$item"
            throw New-Object 'System.Exception' -ArgumentList @($message)
        }
    }
}

& {
    Write-Verbose -Message 'Test Assert-NotNull with Non-Booleans that are convertible to $false' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanFalse) {
        $e1 = try {Assert-NotNull $item | Out-Null} catch {$_.Exception}
        $e2 = try {Assert-NotNull -Value $item | Out-Null} catch {$_.Exception}

        $fail = ($null -ne $e1) -or ($null -ne $e2)

        if ($fail) {
            $message = 'Assert-NotNull failed with Non-Boolean that is convertible to $false: ' + "$item"
            throw New-Object 'System.Exception' -ArgumentList @($message)
        }
    }
}

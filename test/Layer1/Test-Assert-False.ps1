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
    Write-Verbose -Message 'Test Assert-False with Boolean $false' -Verbose:$headerVerbosity

    $e1 = try {Assert-False $false | Out-Null} catch {$_.Exception}
    $e2 = try {Assert-False -Value $false | Out-Null} catch {$_.Exception}

    $fail = ($null -ne $e1) -or ($null -ne $e2)

    if ($fail) {
        $message = 'Assert-False failed with $false value.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    Write-Verbose -Message 'Test Assert-False with Boolean $true' -Verbose:$headerVerbosity

    $e1 = try {Assert-False $true | Out-Null} catch {$_.Exception}
    $e2 = try {Assert-False -Value $true | Out-Null} catch {$_.Exception}

    $fail =
        ($null -eq $e1) -or
        ($null -eq $e2) -or
        (-not $e1.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)) -or
        (-not $e2.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase))

    if ($fail) {
        $message = 'Assert-False failed with $true value.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    Write-Verbose -Message 'Test Assert-False with $null' -Verbose:$headerVerbosity

    $e1 = try {Assert-False $null | Out-Null} catch {$_.Exception}
    $e2 = try {Assert-False -Value $null | Out-Null} catch {$_.Exception}

    $fail =
        ($null -eq $e1) -or
        ($null -eq $e2) -or
        (-not $e1.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)) -or
        (-not $e2.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase))

    if ($fail) {
        $message = 'Assert-False failed with $null value.'
        throw New-Object 'System.Exception' -ArgumentList @($message)
    }
}

& {
    Write-Verbose -Message 'Test Assert-False with Non-Booleans that are convertible to $true' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanTrue) {
        $e1 = try {Assert-False $item | Out-Null} catch {$_.Exception}
        $e2 = try {Assert-False -Value $item | Out-Null} catch {$_.Exception}

        $fail =
            ($null -eq $e1) -or
            ($null -eq $e2) -or
            (-not $e1.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)) -or
            (-not $e2.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase))

        if ($fail) {
            $message = 'Assert-False failed with Non-Boolean that is convertible to $true: ' + "$item"
            throw New-Object 'System.Exception' -ArgumentList @($message)
        }
    }
}

& {
    Write-Verbose -Message 'Test Assert-False with Non-Booleans that are convertible to $false' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanFalse) {
        $e1 = try {Assert-False $item | Out-Null} catch {$_.Exception}
        $e2 = try {Assert-False -Value $item | Out-Null} catch {$_.Exception}

        $fail =
            ($null -eq $e1) -or
            ($null -eq $e2) -or
            (-not $e1.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)) -or
            (-not $e2.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase))

        if ($fail) {
            $message = 'Assert-False failed with Non-Boolean that is convertible to $false: ' + "$item"
            throw New-Object 'System.Exception' -ArgumentList @($message)
        }
    }
}

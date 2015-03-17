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
    Write-Verbose -Message 'Test Assert-PipelineEmpty with Boolean $true' -Verbose:$headerVerbosity

    $e = try {$true | Assert-PipelineEmpty | Out-Null} catch {$_.Exception}

    Assert-NotNull $e
    Assert-True $e.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
}

& {
    Write-Verbose -Message 'Test Assert-PipelineEmpty with Boolean $false' -Verbose:$headerVerbosity

    $e = try {$false | Assert-PipelineEmpty | Out-Null} catch {$_.Exception}

    Assert-NotNull $e
    Assert-True $e.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
}

& {
    Write-Verbose -Message 'Test Assert-PipelineEmpty with $null' -Verbose:$headerVerbosity

    $e = try {$null | Assert-PipelineEmpty | Out-Null} catch {$_.Exception}

    Assert-NotNull $e
    Assert-True $e.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
}

& {
    Write-Verbose -Message 'Test Assert-PipelineEmpty with Non-Booleans that are convertible to $true' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanTrue) {
        $e = try {,$item | Assert-PipelineEmpty | Out-Null} catch {$_.Exception}

        Assert-NotNull $e
        Assert-True $e.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    }
}

& {
    Write-Verbose -Message 'Test Assert-PipelineEmpty with Non-Booleans that are convertible to $false' -Verbose:$headerVerbosity

    foreach ($item in $nonBooleanFalse) {
        $e = try {,$item | Assert-PipelineEmpty | Out-Null} catch {$_.Exception}

        Assert-NotNull $e
        Assert-True $e.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    }
}

& {
    Write-Verbose -Message 'Test Assert-PipelineEmpty with pipelines that contain zero objects' -Verbose:$headerVerbosity

    Assert-Null (@() | Assert-PipelineEmpty)
    Assert-Null (& {@()} | Assert-PipelineEmpty)

    function f1 {}
    Assert-Null (f1 | Assert-PipelineEmpty)
}

& {
    Write-Verbose -Message 'Test Assert-PipelineEmpty with a pipeline that contains many objects' -Verbose:$headerVerbosity

    $objectCount = 0
    $e = try {1..10 | foreach-object {$objectCount++; $_;} | Assert-PipelineEmpty | Out-Null} catch {$_.Exception}

    Assert-NotNull $e
    Assert-True $e.Message.StartsWith('Assertion failed:', [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True (1 -eq $objectCount)
}

& {
    Write-Verbose -Message 'Test Assert-PipelineEmpty with a non-pipeline input' -Verbose:$headerVerbosity

    $e1 = try {Assert-PipelineEmpty -InputObject $true | Out-Null} catch {$_.Exception}
    $e2 = try {Assert-PipelineEmpty -InputObject $false | Out-Null} catch {$_.Exception}
    $e3 = try {Assert-PipelineEmpty -InputObject $null | Out-Null} catch {$_.Exception}
    $e4 = try {Assert-PipelineEmpty -InputObject @() | Out-Null} catch {$_.Exception}
    $e5 = try {Assert-PipelineEmpty -InputObject @(0) | Out-Null} catch {$_.Exception}

    $errorMessage = 'Assert-PipelineEmpty must take its input from the pipeline.'

    Assert-True ($e1 -is [System.ArgumentException])
    Assert-True ($e2 -is [System.ArgumentException])
    Assert-True ($e3 -is [System.ArgumentException])
    Assert-True ($e4 -is [System.ArgumentException])
    Assert-True ($e5 -is [System.ArgumentException])

    Assert-True $e1.Message.StartsWith($errorMessage, [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True $e2.Message.StartsWith($errorMessage, [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True $e3.Message.StartsWith($errorMessage, [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True $e4.Message.StartsWith($errorMessage, [System.StringComparison]::OrdinalIgnoreCase)
    Assert-True $e5.Message.StartsWith($errorMessage, [System.StringComparison]::OrdinalIgnoreCase)
}

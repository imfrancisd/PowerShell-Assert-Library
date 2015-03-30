#requires -version 2

<#
.Synopsis
Build a single script or a single module from the files in the "src" directory.
.Description
Build a single script or a single module from the files in the "src" directory.

The output will be in a directory called "Release".
.Example
.\build.ps1 -All -Verbose
Build a script and a module and store them in the "Release" directory.
.Example
.\build.ps1 -Clean -Verbose
Remove the "Release" directory.
.Example
.\build.ps1 -All -WhatIf
See which files and directories will be modified without actually modifying those files and directories.
#>
[CmdletBinding(DefaultParameterSetName='All', SupportsShouldProcess=$true)]
Param(
    #Clean "Release\" and build "Release\Script\" and build "Release\Module\".
    [Parameter(Mandatory=$false, ParameterSetName='All')]
    [System.Management.Automation.SwitchParameter]
    $All,

    #Build "Release\Script\".
    [Parameter(Mandatory=$true, ParameterSetName='Script')]
    [System.Management.Automation.SwitchParameter]
    $Script,

    #Build "Release\Module\".
    [Parameter(Mandatory=$true, ParameterSetName='Module')]
    [System.Management.Automation.SwitchParameter]
    $Module,

    #Clean "Release\".
    [Parameter(Mandatory=$true, ParameterSetName='Clean')]
    [System.Management.Automation.SwitchParameter]
    $Clean,

    #The version number to attach to the built script and module.
    [Parameter(Mandatory=$false)]
    [System.Version]
    $LibraryVersion = '1.0.0.11',

    #The minimum PowerShell version required by this library.
    [Parameter(Mandatory=$false)]
    [System.Version]
    $PowerShellVersion = '2.0'
)

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

$basePath = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

$outDir = Join-Path -Path $basePath -ChildPath 'Release'
$outScriptDir = Join-Path -Path $outDir -ChildPath 'Script'
$outModuleDir = Join-Path -Path $outDir -ChildPath 'Module\AssertLibrary'

$All =
    $All -or
    (($PSCmdlet.ParameterSetName -eq 'All') -and (-not $PSBoundParameters.ContainsKey('All')))

if ($Clean) {
    if (Test-Path -LiteralPath $outDir) {
        Remove-Item -LiteralPath $outDir -Recurse -Verbose:$VerbosePreference
    }
}

if ($All -or $Script -or $Module) {
    $inputFiles = @(
        'LICENSE.txt',
        'src\AssertFunctions\Assert-False.ps1',
        'src\AssertFunctions\Assert-NotNull.ps1',
        'src\AssertFunctions\Assert-Null.ps1',
        'src\AssertFunctions\Assert-PipelineAny.ps1',
        'src\AssertFunctions\Assert-PipelineCount.ps1',
        'src\AssertFunctions\Assert-PipelineEmpty.ps1',
        'src\AssertFunctions\Assert-PipelineSingle.ps1',
        'src\AssertFunctions\Assert-True.ps1',
        'src\CollectionFunctions\Group-ListItem.ps1',
        'src\ComparisonFunctions\Test-DateTime.ps1',
        'src\ComparisonFunctions\Test-Guid.ps1',
        'src\ComparisonFunctions\Test-Number.ps1',
        'src\ComparisonFunctions\Test-String.ps1',
        'src\ComparisonFunctions\Test-Text.ps1',
        'src\ComparisonFunctions\Test-TimeSpan.ps1',
        'src\ComparisonFunctions\Test-Version.ps1'
    ) | ForEach-Object -Process {Join-Path -Path $basePath -ChildPath $_}

    $compiledLines = $inputFiles | ForEach-Object -Process {
        $isLicense = $_.EndsWith('LICENSE.txt', [System.StringComparison]::OrdinalIgnoreCase)
        if ($isLicense) {'<#'}
        Get-Content -LiteralPath $_
        if ($isLicense) {
            '#>'
            ''
            "#Assert Library version $($LibraryVersion.ToString())"
            '#'
            '#PowerShell requirements'
            "#requires -version $($PowerShellVersion.ToString(2))"
        }
        ''
    }
}

if ($All -or $Script) {
    if (Test-Path -LiteralPath $outScriptDir) {
        Remove-Item -LiteralPath $outScriptDir -Recurse -Verbose:$VerbosePreference
    }
    New-Item -Path $outScriptDir -ItemType Directory -Force -Verbose:$VerbosePreference | Out-Null

    $compiledLines | Out-File -FilePath (Join-Path -Path $outScriptDir -ChildPath 'AssertLibrary.ps1') -Encoding ascii -Verbose:$VerbosePreference
}

if ($All -or $Module) {
    if (Test-Path -LiteralPath $outModuleDir) {
        Remove-Item -LiteralPath $outModuleDir -Recurse -Verbose:$VerbosePreference
    }
    New-Item -Path $outModuleDir -ItemType Directory -Force -Verbose:$VerbosePreference | Out-Null

    $compiledLines | Out-File -FilePath (Join-Path -Path $outModuleDir -ChildPath 'AssertLibrary.psm1') -Encoding ascii -Verbose:$VerbosePreference
@"
@{

# Script module or binary module file associated with this manifest.
ModuleToProcess = 'AssertLibrary.psm1'

# Version number of this module.
ModuleVersion = '$($LibraryVersion.ToString())'

# ID used to uniquely identify this module
GUID = '7ddd1746-0d17-43b2-b6e6-83ef649e01b7'

# Author of this module
Author = 'Francis de la Cerna'

# Copyright statement for this module
Copyright = 'Copyright (c) 2015 Francis de la Cerna, licensed under the MIT License (MIT).'

# Description of the functionality provided by this module
Description = 'A library of PowerShell functions that gives testers complete control over the meaning of their assertions.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '$($PowerShellVersion.ToString(2))'

}
"@ | Out-File -FilePath (Join-Path -Path $outModuleDir -ChildPath 'AssertLibrary.psd1') -Encoding ascii -Verbose:$VerbosePreference

    Get-ChildItem -LiteralPath (Join-Path -Path $basePath -ChildPath 'help') |
        Where-Object {$_.PSIsContainer} |
        Copy-Item -Destination $outModuleDir -Recurse -Verbose:$VerbosePreference
}

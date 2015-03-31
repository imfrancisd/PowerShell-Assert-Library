#requires -version 2

<#
.Synopsis
Build a single script or a single module from the files in the "src" directory.
.Description
Build a single script or a single module from the files in the "src" directory.

The output will be in a directory called "Debug".

Use the -Release switch to build the "Release" directory.
.Example
.\build.ps1 -All -Verbose
Build a script and a module and store them in the "Debug" directory.
.Example
.\build.ps1 -Clean -Verbose
Remove the "Debug" directory.
.Example
.\build.ps1 -All -WhatIf
See which files and directories will be modified without actually modifying those files and directories.
#>
[CmdletBinding(DefaultParameterSetName='All', SupportsShouldProcess=$true)]
Param(
    #Clean "Debug\" and build "Debug\Script\" and build "Debug\Module\".
    [Parameter(Mandatory=$false, ParameterSetName='All')]
    [System.Management.Automation.SwitchParameter]
    $All = $true,

    #Build "Debug\Script\".
    [Parameter(Mandatory=$true, ParameterSetName='Script')]
    [System.Management.Automation.SwitchParameter]
    $Script,

    #Build "Debug\Module\".
    [Parameter(Mandatory=$true, ParameterSetName='Module')]
    [System.Management.Automation.SwitchParameter]
    $Module,

    #Clean "Debug\".
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
    $PowerShellVersion = '2.0',

    #Build the "Release" folder.
    [Parameter(Mandatory=$true, ParameterSetName='Release')]
    [System.Management.Automation.SwitchParameter]
    $Release
)

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

$basePath = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

$debugDir = Join-Path -Path $basePath -ChildPath 'Debug'
$debugScriptDir = Join-Path -Path $debugDir -ChildPath 'Script'
$debugModuleDir = Join-Path -Path $debugDir -ChildPath 'Module\AssertLibrary'

$releaseDir = Join-Path -Path $basePath -ChildPath 'Release'
$releaseScriptDir = Join-Path -Path $releaseDir -ChildPath 'Script'
$releaseModuleDir = Join-Path -Path $releaseDir -ChildPath 'Module\AssertLibrary'

$localizedHelpDir = Join-Path -Path $basePath -ChildPath 'help'

$licenseFile = Join-Path -Path $basePath -ChildPath 'LICENSE.txt'

$inputFiles = @(
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

function main($target)
{
    switch ($target) {
        'All' {
            if ($All) {
                clean $debugDir
                buildScript $debugScriptDir
                buildModule $debugModuleDir
            }
            return
        }
        'Clean' {
            if ($Clean) {
                clean $debugDir
            }
            return
        }
        'Script' {
            if ($Script) {
                clean $debugScriptDir
                buildScript $debugScriptDir
            }
            return
        }
        'Module' {
            if ($Module) {
                clean $debugModuleDir
                buildModule $debugModuleDir
            }
            return
        }
        'Release' {
            if ($Release) {
                clean $releaseDir
                buildScript $releaseScriptDir
                buildModule $releaseModuleDir
            }
            return
        }
        default {
            throw "Cannot build target unknown target: $target."
        }
    }
}

function clean($fullPath)
{
    if (Test-Path -LiteralPath $fullPath) {
        Remove-Item -LiteralPath $fullPath -Recurse -Verbose:$VerbosePreference
    }
}

function buildHeader
{
    '<#'
    Get-Content -LiteralPath $licenseFile
    '#>'
    ''
    "#Assert Library version $($LibraryVersion.ToString())"
    '#'
    '#PowerShell requirements'
    "#requires -version $($PowerShellVersion.ToString(2))"
    ''
}

function buildScript($scriptDir)
{
    $ps1 = Join-Path -Path $scriptDir -ChildPath 'AssertLibrary.ps1'
    $null = New-Item -Path $scriptDir -ItemType Directory -Force -Verbose:$VerbosePreference

    $(& {
        buildHeader
        foreach ($item in $inputFiles) {
            Get-Content -LiteralPath $item
            ''
        }
    }) | Out-File -FilePath $ps1 -Encoding ascii -Verbose:$VerbosePreference
}

function buildModule($moduleDir)
{
    $psm1 = Join-Path -Path $moduleDir -ChildPath 'AssertLibrary.psm1'
    $psd1 = Join-Path -Path $moduleDir -ChildPath 'AssertLibrary.psd1'
    $null = New-Item -Path $moduleDir -ItemType Directory -Force -Verbose:$VerbosePreference

    Copy-Item -LiteralPath $licenseFile -Destination $moduleDir -Verbose:$VerbosePreference

    $(& {
        buildHeader
        foreach ($item in $inputFiles) {
            $e = @(Get-Content -LiteralPath $item).GetEnumerator()

            #------- Uncomment lines below when external help files are ready -------

            #while ($e.MoveNext()) {
            #    if ($e.Current.Trim().EndsWith('#>', [System.StringComparison]::OrdinalIgnoreCase)) {
            #        break
            #    }
            #}
            #'#.ExternalHelp AssertLibrary.psm1-help.xml'

            #------- Uncomment lines above when external help files are ready -------

            while ($e.MoveNext()) {
                $e.Current
            }
            ''
        }
    }) | Out-File -FilePath $psm1 -Encoding ascii -Verbose:$VerbosePreference

    @(
        "@{"
        ""
        "# Script module or binary module file associated with this manifest."
        "ModuleToProcess = 'AssertLibrary.psm1'"
        ""
        "# Version number of this module."
        "ModuleVersion = '$($LibraryVersion.ToString())'"
        ""
        "# ID used to uniquely identify this module"
        "GUID = '7ddd1746-0d17-43b2-b6e6-83ef649e01b7'"
        ""
        "# Author of this module"
        "Author = 'Francis de la Cerna'"
        ""
        "# Copyright statement for this module"
        "Copyright = 'Copyright (c) 2015 Francis de la Cerna, licensed under the MIT License (MIT).'"
        ""
        "# Description of the functionality provided by this module"
        "Description = 'A library of PowerShell functions that gives testers complete control over the meaning of their assertions.'"
        ""
        "# Minimum version of the Windows PowerShell engine required by this module"
        "PowerShellVersion = '$($PowerShellVersion.ToString(2))'"
        ""
        "}"
    ) | Out-File -FilePath $psd1 -Encoding ascii -Verbose:$VerbosePreference

    foreach ($item in (Get-ChildItem -LiteralPath $localizedHelpDir)) {
        if ($item.PSIsContainer) {
            $item | Copy-Item -Destination $moduleDir -Recurse -Verbose:$VerbosePreference
        }
    }
}

main $PSCmdlet.ParameterSetName

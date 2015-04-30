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
    #Build "Debug\".
    #Build "Release\" if the -Release switch is used.
    [Parameter(Mandatory=$false, ParameterSetName='All')]
    [System.Management.Automation.SwitchParameter]
    $All = $true,

    #Build "Debug\Script\".
    #Build "Release\Script\" if the -Release switch is used.
    [Parameter(Mandatory=$true, ParameterSetName='Script')]
    [System.Management.Automation.SwitchParameter]
    $Script,

    #Build "Debug\Module\".
    #Build "Release\Module\" if the -Release switch is used.
    [Parameter(Mandatory=$true, ParameterSetName='Module')]
    [System.Management.Automation.SwitchParameter]
    $Module,

    #Clean "Debug\".
    #Clean "Release\" if the -Release switch is used.
    [Parameter(Mandatory=$true, ParameterSetName='Clean')]
    [System.Management.Automation.SwitchParameter]
    $Clean,

    #The version number to attach to the built script and module.
    [Parameter(Mandatory=$false)]
    [System.Version]
    $LibraryVersion = '1.5.1.0',

    #The minimum PowerShell version required by this library.
    [Parameter(Mandatory=$false)]
    [System.Version]
    $PowerShellVersion = '2.0',

    #Perform actions on "Release\" directory.
    [System.Management.Automation.SwitchParameter]
    $Release
)

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

$basePath = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

$buildDir = Join-Path -Path $basePath -ChildPath $(if ($Release) {'Release'} else {'Debug'})
$buildScriptDir = Join-Path -Path $buildDir -ChildPath 'Script'
$buildModuleDir = Join-Path -Path $buildDir -ChildPath 'Module\AssertLibrary'

$licenseFile   = Join-Path -Path $basePath -ChildPath 'LICENSE.txt'
$scriptHelpDir = Join-Path -Path $basePath -ChildPath 'help\Script'
$moduleHelpDir = Join-Path -Path $basePath -ChildPath 'help\Module'

$functionFiles = @(
    Get-ChildItem -LiteralPath (Join-Path -Path $basePath -ChildPath 'src') -Filter *.ps1 -Recurse |
        Sort-Object -Property 'Name'
)

function main($target)
{
    switch ($target) {
        'All' {
            if ($All) {
                cleanAll
                buildScript
                buildModule
            }
            return
        }
        'Clean' {
            if ($Clean) {
                cleanAll
            }
            return
        }
        'Script' {
            if ($Script) {
                cleanScript
                buildScript
            }
            return
        }
        'Module' {
            if ($Module) {
                cleanModule
                buildModule
            }
            return
        }
        default {
            throw "Cannot build unknown target: $target."
        }
    }
}

function cleanAll
{
    if (Test-Path -LiteralPath $buildDir) {
        Remove-Item -LiteralPath $buildDir -Recurse -Verbose:$VerbosePreference
    }
}

function cleanScript
{
    if (Test-Path -LiteralPath $buildScriptDir) {
        Remove-Item -LiteralPath $buildScriptDir -Recurse -Verbose:$VerbosePreference
    }
}

function cleanModule
{
    if (Test-Path -LiteralPath $buildModuleDir) {
        Remove-Item -LiteralPath $buildModuleDir -Recurse -Verbose:$VerbosePreference
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

function buildScript
{
    $null = New-Item -Path $buildScriptDir -ItemType Directory -Force -Verbose:$VerbosePreference

    foreach ($dir in @(Get-ChildItem -LiteralPath $scriptHelpDir | Where-Object {$_.PSIsContainer})) {
        $scriptLocalizedHelpDir = Join-Path -Path $scriptHelpDir -ChildPath $dir.BaseName

        $lines = @(& {
            buildHeader
            ''
            'New-Module -Name {0} -ScriptBlock {{' -f "'AssertLibrary_$($dir.BaseName)_v$LibraryVersion'"
            ''
            foreach ($item in $functionFiles) {
                if (-not $item.BaseName.StartsWith('_', [System.StringComparison]::OrdinalIgnoreCase)) {
                    Get-Content -LiteralPath (Join-Path -Path $scriptLocalizedHelpDir -ChildPath ($item.BaseName + '.psd1'))
                }
                Get-Content -LiteralPath $item.PSPath
                ''
            }
            "Export-ModuleMember -Function '*-*'} | Import-Module"
        })

        $ps1 = Join-Path -Path $buildScriptDir -ChildPath ('AssertLibrary_{0}.ps1' -f $dir.BaseName)
        $lines | Out-File -FilePath $ps1 -Encoding ascii -Verbose:$VerbosePreference

        if ($dir.BaseName.Equals('en-US', [System.StringComparison]::OrdinalIgnoreCase)) {
            $ps1 = Join-Path -Path $buildScriptDir -ChildPath 'AssertLibrary.ps1'
            $lines | Out-File -FilePath $ps1 -Encoding ascii -Verbose:$VerbosePreference
        }
    }
}

function buildModule
{
    $psm1 = Join-Path -Path $buildModuleDir -ChildPath 'AssertLibrary.psm1'
    $psd1 = Join-Path -Path $buildModuleDir -ChildPath 'AssertLibrary.psd1'
    $null = New-Item -Path $buildModuleDir -ItemType Directory -Force -Verbose:$VerbosePreference

    Copy-Item -LiteralPath $licenseFile -Destination $buildModuleDir -Verbose:$VerbosePreference

    $(& {
        buildHeader
        foreach ($item in $functionFiles) {
            if (-not $item.BaseName.StartsWith('_', [System.StringComparison]::OrdinalIgnoreCase)) {
                "#.ExternalHelp $($item.BaseName)_help.xml"
            }
            Get-Content -LiteralPath $item.PSPath
            ''
        }
        "Export-ModuleMember -Function '*-*'"
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

    foreach ($item in (Get-ChildItem -LiteralPath $moduleHelpDir)) {
        if ($item.PSIsContainer) {
            $item | Copy-Item -Destination $buildModuleDir -Recurse -Verbose:$VerbosePreference
        }
    }
}

main $PSCmdlet.ParameterSetName

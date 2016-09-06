#requires -version 2

<#
.Synopsis
Create scripts and module from the files in the "src" directory.
.Description
Create scripts and module from the files in the "src" directory.
.Example
.\build.ps1
Create scripts and module and store them in the "Debug" directory.

Use "-Configuration Release" to create scripts and module in the "Release" directory.
.Example
.\build.ps1 -Clean
Remove the "Debug" directory.

Use "-Configuration Release" to remove the "Release" directory.
.Example
.\build.ps1 -Target All -Configuration Release -Clean -WhatIf
See which files and directories will be modified without actually modifying those files and directories.
#>
[CmdletBinding(SupportsShouldProcess=$true)]
Param(
    #Create all, script, or module.
    [Parameter(Mandatory = $false, Position = 0)]
    [ValidateSet('All', 'Docs', 'Module', 'Script')]
    [System.String]
    $Target = 'All',

    #Create all, script, or module, in "Debug" or "Release" directory.
    [Parameter(Mandatory = $false)]
    [ValidateSet('Debug', 'Release')]
    [System.String]
    $Configuration = 'Debug',

    #Clean all, script, or module, in "Debug" or "Release" directory.
    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]
    $Clean,

    #The tags applied to the module version of this library.
    #The tags help with module discovery in online galleries.
    [Parameter(Mandatory=$false)]
    [System.String[]]
    $LibraryTags = @('Assert', 'Test', 'List Processing', 'Combinatorial'),

    #The URL to the main website for this project.
    [Parameter(Mandatory=$false)]
    [System.Uri]
    $LibraryUri = 'https://github.com/imfrancisd/PowerShell-Assert-Library',

    #The version number to attach to the built script and module.
    [Parameter(Mandatory=$false)]
    [System.Version]
    $LibraryVersion = '1.7.7.0',

    #The minimum PowerShell version required by this library.
    [Parameter(Mandatory=$false)]
    [System.Version]
    $PowerShellVersion = '2.0',

    #Which version of Strict Mode should be used for this library.
    [Parameter(Mandatory=$false)]
    [ValidateSet('Off', '1.0', '2.0', 'Latest', 'Scope')]
    [System.String]
    $StrictMode = 'Off'
)



$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

$basePath = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

$buildDir = Join-Path -Path $basePath -ChildPath $(if ($Configuration -eq 'Release') {'Release'} else {'Debug'})
$buildScriptDir = Join-Path -Path $buildDir -ChildPath 'Script'
$buildModuleDir = Join-Path -Path $buildDir -ChildPath 'Module\AssertLibrary'

$githubDocsDir = Join-Path -Path $basePath -ChildPath 'docs'

$licenseFile   = Join-Path -Path $basePath -ChildPath 'LICENSE.txt'
$scriptHelpDir = Join-Path -Path $basePath -ChildPath 'help\Script'
$moduleHelpDir = Join-Path -Path $basePath -ChildPath 'help\Module'
$suppressMsgDir = Join-Path -Path $basePath -ChildPath 'scriptanalyzer\suppressMessage'

$functionFiles = @(
    Get-ChildItem -LiteralPath (Join-Path -Path $basePath -ChildPath 'src') -Filter *.ps1 -Recurse |
        Sort-Object -Property 'Name'
)



function main
{
    $action = if ($Clean) {'clean'} else {'build'}

    switch ("$action-$Target") {
        'clean-All'    {cleanAll}
        'clean-Docs'   {cleanDocs}
        'clean-Script' {cleanScript}
        'clean-Module' {cleanModule}

        'build-All'    {cleanAll; buildAll}
        'build-Docs'   {cleanDocs; buildDocs}
        'build-Script' {cleanScript; buildScript}
        'build-Module' {cleanModule; buildModule}

        default {throw "Cannot $action unknown target: $target."}
    }
}

function cleanAll
{
    if (Test-Path -LiteralPath $buildDir) {
        Remove-Item -LiteralPath $buildDir -Recurse -Verbose:$VerbosePreference
    }

    if ($Configuration -eq 'Release') {
        cleanDocs
    }
}

function cleanDocs
{
    if (Test-Path -LiteralPath $githubDocsDir) {
        Remove-Item -LiteralPath $githubDocsDir -Recurse -Verbose:$VerbosePreference
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

function buildAll
{
    buildScript
    buildModule

    if ($Configuration -eq 'Release') {
        buildDocs
    }
}

function buildDocs
{
    $scriptEnUs = Join-Path -Path $buildScriptDir -ChildPath 'AssertLibrary_en-US.ps1'
    $aboutTxt = Join-Path -Path $buildModuleDir -ChildPath (Join-Path -Path 'en-US' -ChildPath 'about_AssertLibrary.help.txt')
    $readmeTxt = Join-Path -Path $githubDocsDir -ChildPath 'README.txt'

    if ($Configuration -ne 'Release') {
        throw "Docs can only be created from the Release directory.`r`nTry: .\build.ps1 -Target Docs -Configuration Release"
    }
    if (-not (Test-Path -Path $scriptEnUs)) {
        throw "Cannot build docs directory without the file '$scriptEnUs'."
    }
    if (-not (Test-Path -Path $aboutTxt)) {
        throw "Cannot build docs directory without the file '$aboutTxt'."
    }
    $null = New-Item -Path $githubDocsDir -ItemType Directory -Force -Verbose:$VerbosePreference

    $command = @"
        `$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
        `$PSDefaultParameterValues = @{}
        `$WhatIfPreference = `$$WhatIfPreference
        `$oldSize = `$Host.UI.RawUI.BufferSize 
        try {
            if (`$oldSize.Width -ne 120) {
                try {`$Host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size -ArgumentList @(120, 9001)}
                catch {Write-Warning -Message 'Could not change the width of the PowerShell buffer to 120.`r`nDocs may changed unnecessarily.'}
            }

            Set-Location -Path '$basePath'
            Remove-Module assertlibrary*
            & '$scriptEnUs'

            `$VerbosePreference = [System.Management.Automation.ActionPreference]::$VerbosePreference
            Copy-Item -Path '$aboutTxt' -Destination '$readmeTxt' -verbose:`$verbosepreference
            (Get-Module assertlibrary*).exportedfunctions.getenumerator() |
                ForEach-Object {
                    `$githubDoc = Join-Path -Path '$githubDocsDir' -ChildPath (`$_.Key + '.txt')
                    Get-Help `$_.Key -full |
                        Out-File `$githubDoc -encoding utf8 -force -verbose:`$verbosepreference}
        }
        finally {try {`$Host.UI.RawUI.BufferSize = `$oldSize} catch{}}
"@

    powershell.exe -noprofile -noninteractive -executionpolicy remotesigned -command $command
}

function buildScript
{
    $null = New-Item -Path $buildScriptDir -ItemType Directory -Force -Verbose:$VerbosePreference

    foreach ($dir in @(Get-ChildItem -LiteralPath $scriptHelpDir | Where-Object {$_.PSIsContainer})) {
        $scriptLocalizedHelpDir = Join-Path -Path $scriptHelpDir -ChildPath $dir.BaseName

        $lines = @(& {
            '<#'
            Get-Content -LiteralPath $licenseFile
            '#>'
            ''
            "#Assert Library version $($LibraryVersion.ToString())"
            "#$LibraryUri"
            '#'
            '#PowerShell requirements'
            "#requires -version $($PowerShellVersion.ToString(2))"
            ''
            ''
            ''
            Get-ChildItem -LiteralPath $suppressMsgDir -Filter '*.psd1' -Recurse |
                Get-Content |
                Sort-Object
            '[CmdletBinding()]'
            'Param()'
            ''
            ''
            ''
            'New-Module -Name {0} -ScriptBlock {{' -f "'AssertLibrary_$($dir.BaseName)_v$LibraryVersion'"
            ''
            'if ($PSVersionTable.PSVersion.Major -gt 2) {'
            '    $PSDefaultParameterValues.Clear()'
            '}'
            switch ($StrictMode) {
                'Off'       {'Microsoft.PowerShell.Core\Set-StrictMode -Off'}
                '1.0'       {"Microsoft.PowerShell.Core\Set-StrictMode -Version '1.0'"}
                '2.0'       {"Microsoft.PowerShell.Core\Set-StrictMode -Version '2.0'"}
                'Latest'    {"Microsoft.PowerShell.Core\Set-StrictMode -Version 'Latest'"}
                'Scope'     {'#WARNING: StrictMode setting is inherited from a higher scope.'}
                default     {throw "Unknown Strict Mode '$StrictMode'."}
            }
            ''
            foreach ($item in $functionFiles) {
                ''
                if (-not $item.BaseName.StartsWith('_', [System.StringComparison]::OrdinalIgnoreCase)) {
                    $scriptHelpFile = Join-Path -Path $scriptLocalizedHelpDir -ChildPath ($item.BaseName + '.psd1')
                    if ((Test-Path -LiteralPath $scriptHelpFile)) {
                        Get-Content -LiteralPath $scriptHelpFile
                    } else {
                        Write-Warning -Message "Missing help file: $scriptHelpFile"
                    }
                }
                Get-Content -LiteralPath $item.PSPath
                ''
            }
            ''
            "Export-ModuleMember -Function '*-*'} | Import-Module"
        })

        $ps1 = Join-Path -Path $buildScriptDir -ChildPath ('AssertLibrary_{0}.ps1' -f $dir.BaseName)
        $lines | Out-File -FilePath $ps1 -Encoding utf8 -Verbose:$VerbosePreference

        if ($dir.BaseName.Equals('en-US', [System.StringComparison]::OrdinalIgnoreCase)) {
            $ps1 = Join-Path -Path $buildScriptDir -ChildPath 'AssertLibrary.ps1'
            $lines | Out-File -FilePath $ps1 -Encoding utf8 -Verbose:$VerbosePreference
        }
    }
}

function buildModule
{
    $psm1 = Join-Path -Path $buildModuleDir -ChildPath 'AssertLibrary.psm1'
    $psd1 = Join-Path -Path $buildModuleDir -ChildPath 'AssertLibrary.psd1'
    $null = New-Item -Path $buildModuleDir -ItemType Directory -Force -Verbose:$VerbosePreference
    $publicFunctions = New-Object -TypeName 'System.Collections.Generic.List[System.String]'

    Copy-Item -LiteralPath $licenseFile -Destination $buildModuleDir -Verbose:$VerbosePreference

    $(& {
        '<#'
        Get-Content -LiteralPath $licenseFile
        '#>'
        ''
        "#Assert Library version $($LibraryVersion.ToString())"
        "#$LibraryUri"
        '#'
        '#PowerShell requirements'
        "#requires -version $($PowerShellVersion.ToString(2))"
        ''
        ''
        ''
        Get-ChildItem -LiteralPath $suppressMsgDir -Filter '*.psd1' -Recurse |
            Get-Content |
            Sort-Object
        '[CmdletBinding()]'
        'Param()'
        ''
        ''
        ''
        'if ($PSVersionTable.PSVersion.Major -gt 2) {'
        '    $PSDefaultParameterValues.Clear()'
        '}'
        switch ($StrictMode) {
            'Off'       {'Microsoft.PowerShell.Core\Set-StrictMode -Off'}
            '1.0'       {"Microsoft.PowerShell.Core\Set-StrictMode -Version '1.0'"}
            '2.0'       {"Microsoft.PowerShell.Core\Set-StrictMode -Version '2.0'"}
            'Latest'    {"Microsoft.PowerShell.Core\Set-StrictMode -Version 'Latest'"}
            'Scope'     {'#WARNING: StrictMode setting is inherited from a higher scope.'}
            default     {throw "Unknown Strict Mode '$StrictMode'."}
        }
        ''
        foreach ($item in $functionFiles) {
            ''
            if (-not $item.BaseName.StartsWith('_', [System.StringComparison]::OrdinalIgnoreCase)) {
                $publicFunctions.Add($item.BaseName)
                '#.ExternalHelp AssertLibrary.psm1-help.xml'
            }
            Get-Content -LiteralPath $item.PSPath
            ''
        }
        ''
        "Export-ModuleMember -Function '*-*'"
    }) | Out-File -FilePath $psm1 -Encoding utf8 -Verbose:$VerbosePreference

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
        "# Functions to export from this module"
        "FunctionsToExport = @($(@($publicFunctions | ForEach-Object {"'$_'"}) -join ', '))"
        ""
        "# Cmdlets to export from this module"
        "CmdletsToExport = @()"
        ""
        "# Variables to export from this module"
        "VariablesToExport = @()"
        ""
        "# Aliases to export from this module"
        "AliasesToExport = @()"
        ""
        "# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell."
        "PrivateData = @{"
        ""
        "    PSData = @{"
        ""
        "        # Tags applied to this module. These help with module discovery in online galleries."
        "        Tags = @($(($LibraryTags | Where-Object {($null -ne $_) -and ('' -ne $_.Trim())} | ForEach-Object {"'$($_.Trim())'"}) -join ', '))"
        ""
        "        # A URL to the main website for this project."
        "        ProjectUri = '$LibraryUri'"
        ""
        "    } # End of PSData hashtable"
        ""
        "} # End of PrivateData hashtable"
        ""
        "}"
    ) | Out-File -FilePath $psd1 -Encoding utf8 -Verbose:$VerbosePreference

    foreach ($item in (Get-ChildItem -LiteralPath $moduleHelpDir)) {
        if ($item.PSIsContainer) {
            $item | Copy-Item -Destination $buildModuleDir -Recurse -Verbose:$VerbosePreference
        }
    }
}

main

@{

# Script module or binary module file associated with this manifest.
ModuleToProcess = 'AssertLibrary.psm1'

# Version number of this module.
ModuleVersion = '1.7.6.0'

# ID used to uniquely identify this module
GUID = '7ddd1746-0d17-43b2-b6e6-83ef649e01b7'

# Author of this module
Author = 'Francis de la Cerna'

# Copyright statement for this module
Copyright = 'Copyright (c) 2015 Francis de la Cerna, licensed under the MIT License (MIT).'

# Description of the functionality provided by this module
Description = 'A library of PowerShell functions that gives testers complete control over the meaning of their assertions.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '2.0'

# Functions to export from this module
FunctionsToExport = @('Assert-All', 'Assert-Exists', 'Assert-False', 'Assert-NotExists', 'Assert-NotFalse', 'Assert-NotNull', 'Assert-NotTrue', 'Assert-Null', 'Assert-PipelineAll', 'Assert-PipelineAny', 'Assert-PipelineCount', 'Assert-PipelineEmpty', 'Assert-PipelineExists', 'Assert-PipelineNotExists', 'Assert-PipelineSingle', 'Assert-True', 'Group-ListItem', 'Test-All', 'Test-DateTime', 'Test-Exists', 'Test-False', 'Test-Guid', 'Test-NotExists', 'Test-NotFalse', 'Test-NotNull', 'Test-NotTrue', 'Test-Null', 'Test-Number', 'Test-String', 'Test-Text', 'Test-TimeSpan', 'Test-True', 'Test-Version')

# Cmdlets to export from this module
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module
AliasesToExport = @()

}

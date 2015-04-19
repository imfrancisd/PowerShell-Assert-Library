<#
.Synopsis
Assert that the pipeline does not contain any objects.
.Description
This function is useful for asserting that a function does not output any objects.

This function throws an error if any of the following conditions are met:
    *the pipeline contains an object
.Parameter InputObject
The object from the pipeline.

Note:
The argument for this parameter must come from the pipeline.
.Example
Get-ChildItem 'aFileThatDoesNotExist*' | Assert-PipelineEmpty
Throws an error if Get-ChildItem 'aFileThatDoesNotExist*' returns an object.
.Example
Get-ChildItem 'aFileThatDoesNotExist*' | Assert-PipelineEmpty -Verbose
Throws an error if Get-ChildItem 'aFileThatDoesNotExist*' returns an object.
The -Verbose switch will output the result of the assertion to the Verbose stream.
.Example
Get-ChildItem 'aFileThatDoesNotExist*' | Assert-PipelineEmpty -Debug
Throws an error if Get-ChildItem 'aFileThatDoesNotExist*' returns an object.
The -Debug switch gives you a chance to investigate a failing assertion before an error is thrown.
.Inputs
System.Object

This function accepts any kind of object from the pipeline.
.Outputs
None
.Notes
An example of how this function might be used in a unit test.

#display passing assertions
$VerbosePreference = [System.Management.Automation.ActionPreference]::Continue

#display debug prompt on failing assertions
$DebugPreference = [System.Management.Automation.ActionPreference]::Inquire

myFunc1 | Assert-PipelineEmpty
myFunc2 | Assert-PipelineEmpty
myFunc3 | Assert-PipelineEmpty
.Link
Assert-True
.Link
Assert-False
.Link
Assert-Null
.Link
Assert-NotTrue
.Link
Assert-NotFalse
.Link
Assert-NotNull
.Link
Assert-PipelineAny
.Link
Assert-PipelineSingle
.Link
Assert-PipelineCount
#>

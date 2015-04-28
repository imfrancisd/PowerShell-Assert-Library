<#
.Synopsis
Assert that the pipeline contains one or more objects.
.Description
This function is useful for asserting that a function returns one or more objects.

This function throws an error if any of the following conditions are met:
    *the pipeline contains less than one object
.Parameter InputObject
The object from the pipeline.

Note:
The argument for this parameter must come from the pipeline.
.Example
$letter = 'a', 'b', 'c' | Get-Random | Assert-PipelineAny
Throws an error if Get-Random does not return any objects.
.Example
$letter = 'a', 'b', 'c' | Get-Random | Assert-PipelineAny -Verbose
Throws an error if Get-Random does not return any objects.
The -Verbose switch will output the result of the assertion to the Verbose stream.
.Example
$letter = 'a', 'b', 'c' | Get-Random | Assert-PipelineAny -Debug
Throws an error if Get-Random does not return any objects.
The -Debug switch gives you a chance to investigate a failing assertion before an error is thrown.
.Inputs
System.Object

This function accepts any kind of object from the pipeline.
.Outputs
System.Object

If the assertion passes, this function outputs the objects from the pipeline input.
.Notes
An example of how this function might be used in a unit test.

#display passing assertions
$VerbosePreference = [System.Management.Automation.ActionPreference]::Continue

#display debug prompt on failing assertions
$DebugPreference = [System.Management.Automation.ActionPreference]::Inquire

$a = myFunc1 | Assert-PipelineAny
$b = myFunc2 | Assert-PipelineAny
$c = myFunc3 | Assert-PipelineAny
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
Assert-All
.Link
Assert-Exists
.Link
Assert-NotExists
.Link
Assert-PipelineAll
.Link
Assert-PipelineExists
.Link
Assert-PipelineNotExists
.Link
Assert-PipelineEmpty
.Link
Assert-PipelineSingle
.Link
Assert-PipelineCount
#>

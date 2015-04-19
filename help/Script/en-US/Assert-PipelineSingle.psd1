<#
.Synopsis
Assert that the pipeline only contains one object.
.Description
This function is useful for asserting that a function only returns a single object.

This function throws an error if any of the following conditions are met:
    *the pipeline contains less than one object
    *the pipeline contains more than one object
.Parameter InputObject
The object from the pipeline.

Note:
The argument for this parameter must come from the pipeline.
.Example
$letter = 'a', 'b', 'c' | Get-Random | Assert-PipelineSingle
Throws an error if Get-Random does not return a single object.
.Example
$letter = 'a', 'b', 'c' | Get-Random | Assert-PipelineSingle -Verbose
Throws an error if Get-Random does not return a single object.
The -Verbose switch will output the result of the assertion to the Verbose stream.
.Example
$letter = 'a', 'b', 'c' | Get-Random | Assert-PipelineSingle -Debug
Throws an error if Get-Random does not return a single object.
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

$a = myFunc1 | Assert-PipelineSingle
$b = myFunc2 | Assert-PipelineSingle
$c = myFunc3 | Assert-PipelineSingle
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
Assert-PipelineEmpty
.Link
Assert-PipelineAny
.Link
Assert-PipelineCount
#>

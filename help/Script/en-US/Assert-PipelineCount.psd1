<#
.Synopsis
Assert the number of objects in the pipeline.
.Description
This function is useful for asserting that a function outputs the correct number of objects.

See the -Equals, -Minimum, and -Maximum parameters for more details.

Note:
This function will output all pipeline objects it receives until an error is thrown, or until there are no more objects left in the pipeline.
.Parameter InputObject
The object from the pipeline.

Note:
The argument for this parameter must come from the pipeline.
.Parameter Equals
This function will throw an error if the number of objects in the pipeline is not equal to the number specified by this parameter.

Note:
A negative number will always cause this assertion to fail.
.Parameter Minimum
This function will throw an error if the number of objects in the pipeline is less than the number specified by this parameter.

Note:
A negative number will always cause this assertion to pass.
.Parameter Maximum
This function will throw an error if the number of objects in the pipeline is more than the number specified by this parameter.

Note:
A negative number will always cause this assertion to fail.
.Example
$nums = 1..100 | Get-Random -Count 10 | Assert-PipelineCount 10
Throws an error if Get-Random -Count 10 does not return exactly ten objects.
.Example
$nums = 1..100 | Get-Random -Count 10 | Assert-PipelineCount -Maximum 10
Throws an error if Get-Random -Count 10 returns more than ten objects.
.Example
$nums = 1..100 | Get-Random -Count 10 | Assert-PipelineCount -Minimum 10
Throws an error if Get-Random -Count 10 returns less than ten objects.
.Example
$nums = 1..100 | Get-Random -Count 10 | Assert-PipelineCount 10 -Verbose
Throws an error if Get-Random -Count 10 does not return exactly ten objects.
The -Verbose switch will output the result of the assertion to the Verbose stream.
.Example
$nums = 1..100 | Get-Random -Count 10 | Assert-PipelineCount 10 -Debug
Throws an error if Get-Random -Count 10 does not return exactly ten objects.
The -Debug switch gives you a chance to investigate a failing assertion before an error is thrown.
.Example
$a = Get-ChildItem 'a*' | Assert-PipelineCount -Minimum 5 | Assert-PipelineCount -Maximum 10
Throws an error if Get-ChildItem 'a*' either returns less than five objects, or returns more than 10 objects.
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

$a = myFunc1 | Assert-PipelineCount 10
$b = myFunc2 | Assert-PipelineCount -Minimum 1
$c = myFunc3 | Assert-PipelineCount -Maximum 2
$d = myFunc4 | Assert-PipelineCount -Minimum 3 | Assert-PipelineCount -Maximum 14
.Link
Assert-True
.Link
Assert-False
.Link
Assert-Null
.Link
Assert-NotNull
.Link
Assert-PipelineEmpty
.Link
Assert-PipelineAny
.Link
Assert-PipelineSingle
#>

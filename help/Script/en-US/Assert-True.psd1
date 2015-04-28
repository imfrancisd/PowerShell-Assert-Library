<#
.Synopsis
Assert that a value is the Boolean value $true.
.Description
This function throws an error if any of the following conditions are met:
    *the value being asserted is $null
    *the value being asserted is not of type System.Boolean
    *the value being asserted is not $true
.Parameter Value
The value to assert.
.Example
Assert-True ($a -eq $b)
Throws an error if the expression ($a -eq $b) does not evaluate to $true.
.Example
Assert-True ($a -eq $b) -Verbose
Throws an error if the expression ($a -eq $b) does not evaluate to $true.
The -Verbose switch will output the result of the assertion to the Verbose stream.
.Example
Assert-True ($a -eq $b) -Debug
Throws an error if the expression ($a -eq $b) does not evaluate to $true.
The -Debug switch gives you a chance to investigate a failing assertion before an error is thrown.
.Inputs
None

This function does not accept input from the pipeline.
.Outputs
None
.Notes
An example of how this function might be used in a unit test.

#display passing assertions
$VerbosePreference = [System.Management.Automation.ActionPreference]::Continue

#display debug prompt on failing assertions
$DebugPreference = [System.Management.Automation.ActionPreference]::Inquire

Assert-True ($a -is [System.Int32])
Assert-True ($b -is [System.Int32])
Assert-True ($a -eq $b)
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
Assert-PipelineAny
.Link
Assert-PipelineSingle
.Link
Assert-PipelineCount
#>

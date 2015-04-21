<#
.Synopsis
Assert that a value is $null.
.Description
This function throws an error if any of the following conditions are met:
    *the value being asserted is not $null
.Parameter Value
The value to assert.
.Example
Assert-Null $a
Throws an error if $a does not evaluate to $null.
.Example
Assert-Null $a -Verbose
Throws an error if $a does not evaluate to $null.
The -Verbose switch will output the result of the assertion to the Verbose stream.
.Example
Assert-Null $a -Debug
Throws an error if $a does not evaluate to $null.
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

Assert-Null $a
Assert-Null $b
Assert-Null $c
.Link
Assert-True
.Link
Assert-False
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
Assert-PipelineEmpty
.Link
Assert-PipelineAny
.Link
Assert-PipelineSingle
.Link
Assert-PipelineCount
#>

<#
.Synopsis
Assert that a value is not $null.
.Description
This function throws an error if any of the following conditions are met:
    *the value being asserted is $null
.Parameter Value
The value to assert.
.Example
Assert-NotNull $a
Throws an error if $a evaluates to $null.
.Example
Assert-NotNull $a -Verbose
Throws an error if $a evaluates to $null.
The -Verbose switch will output the result of the assertion to the Verbose stream.
.Example
Assert-NotNull $a -Debug
Throws an error if $a evaluates to $null.
The -Debug switch gives you a chance to investigate a failing assertion before an error is thrown.
.Inputs
System.Object
.Outputs
None
.Notes
An example of how this function might be used in a unit test.

#display passing assertions
$VerbosePreference = [System.Management.Automation.ActionPreference]::Continue

#display debug prompt on failing assertions
$DebugPreference = [System.Management.Automation.ActionPreference]::Inquire

Assert-NotNull $a
Assert-NotNull $b
Assert-NotNull $c
.Link
Assert-True
Assert-False
Assert-Null
Assert-PipelineEmpty
Assert-PipelineAny
Assert-PipelineSingle
Assert-PipelineCount
#>

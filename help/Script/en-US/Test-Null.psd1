<#
.Synopsis
Test that a value is $null.
.Description
This function tests if a value is $null without the filtering semantics from the PowerShell comparison operators.

    Return Value   Condition
    ------------   ---------
    $null          never
    $false         value is not $null
    $true          value is $null
.Parameter Value
The value to test.
.Example
Test-Null @(1)
Test if the value is $null without filtering semantics.

Note:
Compare the example above with the following expressions:
    1 -eq $null
    @(1) -eq $null
and see how tests can become confusing if the value is stored in a variable or if the value is not expected to be an array.
.Inputs
None

This function does not accept input from the pipeline.
.Outputs
System.Boolean
.Notes
An example of how this function might be used in a unit test.

#recommended alias
set-alias 'null?' 'test-null'

assert-all    $items {param($a) (null? $a.b) -and (null? $a.c)}
assert-exists $items {param($a) (null? $a.d) -xor (null? $a.e)}
.Link
Test-True
.Link
Test-False
.Link
Test-NotTrue
.Link
Test-NotFalse
.Link
Test-NotNull
.Link
Test-All
.Link
Test-Exists
.Link
Test-NotExists
#>

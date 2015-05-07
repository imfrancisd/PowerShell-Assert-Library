<#
.Synopsis
Test that a value is not $null.
.Description
This function tests if a value is not $null without the filtering semantics from the PowerShell comparison operators.

    Return Value   Condition
    ------------   ---------
    $null          never
    $false         value is $null
    $true          value is not $null
.Parameter Value
The value to test.
.Example
Test-NotNull @(1)
Test if the value is not $null without filtering semantics.

Note:
Compare the example above with the following expressions:
    10 -ne $null
    @(10) -ne $null
and see how tests can become confusing if the value is stored in a variable or if the value is not expected to be an array.
.Inputs
None

This function does not accept input from the pipeline.
.Outputs
System.Boolean
.Notes
An example of how this function might be used in a unit test.

#recommended alias
set-alias 'notNull?' 'test-notnull'

assert-all    $items {param($a) (notNull? $a.b) -and (notNull? $a.c)}
assert-exists $items {param($a) (notNull? $a.d) -xor (notNull? $a.e)}
.Link
Test-True
.Link
Test-False
.Link
Test-Null
.Link
Test-NotTrue
.Link
Test-NotFalse
.Link
Test-All
.Link
Test-Exists
.Link
Test-NotExists
#>

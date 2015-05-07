<#
.Synopsis
Test that a value is the Boolean value $false.
.Description
This function tests if a value is $false without the implicit conversions or the filtering semantics from the PowerShell comparison operators.

    Return Value   Condition
    ------------   ---------
    $null          never
    $false         value is not of type System.Boolean
                   value is not $false
    $true          value is $false
.Parameter Value
The value to test.
.Example
Test-False 0
Test if the number 0 is $false without performing any implicit conversions.

Note:
Compare the example above with the following expressions:
    0 -eq $false
    '0' -eq $false
and see how tests can become confusing if those numbers were stored in variables.
.Example
Test-False @($false)
Test if the array is $false without filtering semantics.

Note:
Compare the example above with the following expressions:
    @(0, $false) -eq $false
    @(-1, 0, 1, 2, 3) -eq $false
and see how tests can become confusing if the value is stored in a variable or if the value is not expected to be an array.
.Inputs
None

This function does not accept input from the pipeline.
.Outputs
System.Boolean
.Notes
An example of how this function might be used in a unit test.

#recommended alias
set-alias 'false?' 'test-false'

assert-all    $items {param($a) (false? $a.b) -and (false? $a.c)}
assert-exists $items {param($a) (false? $a.d) -xor (false? $a.e)}
.Link
Test-True
.Link
Test-Null
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

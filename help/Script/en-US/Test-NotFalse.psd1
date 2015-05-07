<#
.Synopsis
Test that a value is not the Boolean value $false.
.Description
This function tests if a value is not $false without the implicit conversions or the filtering semantics from the PowerShell comparison operators.

    Return Value   Condition
    ------------   ---------
    $null          never
    $false         value is not the System.Boolean value $false
    $true          value is not of type System.Boolean
                   value is $true
.Parameter Value
The value to test.
.Example
Test-NotFalse 0
Test if the number 0 is not $false without performing any implicit conversions.

Note:
Compare the example above with the following expressions:
    0 -ne $false
    '0' -ne $false
and see how tests can become confusing if those numbers were stored in variables.
.Example
Test-NotFalse @($false)
Test if the array is not $false without filtering semantics.

Note:
Compare the example above with the following expressions:
    @(0, $false) -ne $false
    @(-1, 0, 1, 2, 3) -ne $false
and see how tests can become confusing if the value is stored in a variable or if the value is not expected to be an array.
.Inputs
None

This function does not accept input from the pipeline.
.Outputs
System.Boolean
.Notes
An example of how this function might be used in a unit test.

#recommended alias
set-alias 'notFalse?' 'test-notfalse'

assert-all    $items {param($a) (notFalse? $a.b) -and (notFalse? $a.c)}
assert-exists $items {param($a) (notFalse? $a.d) -xor (notFalse? $a.e)}
.Link
Test-True
.Link
Test-False
.Link
Test-Null
.Link
Test-NotTrue
.Link
Test-NotNull
.Link
Test-All
.Link
Test-Exists
.Link
Test-NotExists
#>

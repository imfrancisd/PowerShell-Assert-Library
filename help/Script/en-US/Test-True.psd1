<#
.Synopsis
Test that a value is the Boolean value $true.
.Description
This function tests if a value is $true without the implicit conversions or the filtering semantics from the PowerShell comparison operators.

    Return Value   Condition
    ------------   ---------
    $null          never
    $false         value is not of type System.Boolean
                   value is not $true
    $true          value is $true
.Parameter Value
The value to test.
.Example
Test-True 1
Test if the number 1 is $true without performing any implicit conversions.

Note:
Compare the example above with the following expressions:
    1 -eq $true
    10 -eq $true
and see how tests can become confusing if those numbers were stored in variables.
.Example
Test-True @($true)
Test if the array is $true without filtering semantics.

Note:
Compare the example above with the following expressions:
    @(1, $true) -eq $true
    @(-1, 0, 1, 2, 3) -eq $true
and see how tests can become confusing if the value is stored in a variable or if the value is not expected to be an array.
.Inputs
None

This function does not accept input from the pipeline.
.Outputs
System.Boolean
.Notes
An example of how this function might be used in a unit test.

#recommended alias
set-alias 'true?' 'test-true'

assert-all    $items {param($a) (true? $a.b) -and (true? $a.c)}
assert-exists $items {param($a) (true? $a.d) -xor (true? $a.e)}
.Link
Test-False
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

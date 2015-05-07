<#
.Synopsis
Test that a value is not the Boolean value $true.
.Description
This function tests if a value is not $true without the implicit conversions or the filtering semantics from the PowerShell comparison operators.

    Return Value   Condition
    ------------   ---------
    $null          never
    $false         value is not the System.Boolean value $true
    $true          value is not of type System.Boolean
                   value is $false
.Parameter Value
The value to test.
.Example
Test-NotTrue 1
Test if the number 1 is not $true without performing any implicit conversions.

Note:
Compare the example above with the following expressions:
    1 -ne $true
    10 -ne $true
and see how tests can become confusing if those numbers were stored in variables.
.Example
Test-NotTrue @($true)
Test if the array is not $true without filtering semantics.

Note:
Compare the example above with the following expressions:
    @(1, $true) -ne $true
    @(-1, 0, 1, 2, 3) -ne $true
and see how tests can become confusing if the value is stored in a variable or if the value is not expected to be an array.
.Inputs
None

This function does not accept input from the pipeline.
.Outputs
System.Boolean
.Notes
An example of how this function might be used in a unit test.

#recommended alias
set-alias 'notTrue?' 'test-notTrue'

assert-all    $items {param($a) (notTrue? $a.b) -and (notTrue? $a.c)}
assert-exists $items {param($a) (notTrue? $a.d) -xor (notTrue? $a.e)}
.Link
Test-True
.Link
Test-False
.Link
Test-Null
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

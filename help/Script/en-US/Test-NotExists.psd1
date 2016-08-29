<#
.Synopsis
Test that a predicate is never true for any item in a collection.
.Description
This function tests if a predicate is never $true for any item in a collection.

    Return Value   Condition
    ------------   ---------
    $null          the collection is not of type System.Collections.ICollection
    $false         there exists* an item in the collection that makes the predicate true
    $true          there does not exist* an item in the collection that makes the predicate true
                   the collection is empty

    *The meaning of "to exist" can be modified with the -Quantity parameter.

*See the -Collection, -Predicate, and -Quantity parameters for more details.
.Parameter Collection
The collection of items used to test the predicate.

The order in which the items in the collection are tested is determined by the collection's GetEnumerator method.
.Parameter Predicate
The script block that will be invoked on each item in the collection.

The script block must take one argument and return a value.

Note:
The -ErrorAction parameter has NO effect on the predicate.
An InvalidOperationException is thrown if the predicate throws an error.
.Parameter Quantity
The quantity of items ('Any', 'Single', 'Multiple') that must make the predicate true to make the test return $false.

The default is 'Any'.
.Example
Test-NotExists @(1, 2, 3, 4, 5) {param($n) $n -gt 10}
Test that no item in the array is greater than 10.
.Example
Test-NotExists @() {param($n) $n -gt 10}
Test that no item in the array is greater than 10.

Note:
This test will always return $true because the array is empty.
.Example
Test-NotExists @('H', 'E', 'L', 'L', 'O') {param($c) $c -eq 'H'} -Quantity Multiple
Test that it is not the case that there are multiple 'H' in the array.
.Example
Test-NotExists @('H', 'E', 'L', 'L', 'O') {param($c) $c -eq 'L'} -Quantity Single
Test that it is not the case that there is only a single 'L' in the array.
.Example
Test-NotExists @{a0 = 10; a1 = 20; a2 = 30} {param($entry) $entry.Value -lt 0}
Test that no entry in the hashtable has a value less than 0.
.Inputs
None

This function does not accept input from the pipeline.
.Outputs
System.Boolean

This function returns a Boolean if the test can be performed.
.Outputs
$null

This function returns $null if the test cannot be performed.
.Notes
An example of how this function might be used in a unit test.

#recommended alias
set-alias 'notExists?' 'test-notexists'

assert-all    $items {param($a) notExists? $a.bArray {param($b) $b -gt 10}}
assert-exists $items {param($a) notExists? $a.cArray {param($c) $c -eq 0}}
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
Test-NotNull
.Link
Test-All
.Link
Test-Exists
#>

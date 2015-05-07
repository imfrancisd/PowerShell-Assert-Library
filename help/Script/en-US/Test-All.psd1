<#
.Synopsis
Test that a predicate is true for all items in a collection.
.Description
This function tests if a predicate is $true for all items in a collection.

    Return Value   Condition
    ------------   ---------
    $null          the collection is not of type System.Collections.ICollection
    $false         the predicate never returns the System.Boolean value $true
    $true          the predicate always returns the System.Boolean value $true
                   the collection is empty

*See the -Collection and -Predicate parameters for more details.
.Parameter Collection
The collection of items used to test the predicate.

The order in which the items in the collection are tested is determined by the collection's GetEnumerator method.
.Parameter Predicate
The script block that will be invoked on each item in the collection.

The script block must take one argument and return a value.

Note:
The -ErrorAction parameter has NO effect on the predicate.
An InvalidOperationException is thrown if the predicate throws an error.
.Example
Test-All @(1, 2, 3, 4, 5) {param($n) $n -gt 0}
Test that all items in the array are greater than 0.
.Example
Test-All @() {param($n) $n -gt 0}
Test that all items in the array are greater than 0.

Note:
This test will always return $true because the array is empty.
This is known as vacuous truth.
.Example
Test-All @{a0=10; a1=20; a2=30} {param($entry) $entry.Value -gt 5}
Test that all entries in the hashtable have a value greater than 5.
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
set-alias 'all?' 'test-all'

assert-all    $items {param($a) all? $a.bArray {param($b) $b -gt 10}}
assert-exists $items {param($a) all? $a.cArray {param($c) $c -eq 0}}
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
Test-Exists
.Link
Test-NotExists
#>

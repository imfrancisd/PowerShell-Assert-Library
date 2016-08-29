<#
.Synopsis
Assert that a predicate is not true for any item in a collection.
.Description
This function throws an error if there exists an item in the collection that makes predicate true.

The meaning of "to exist" can be modified with the -Quantity parameter.

Note:
The assertion will always pass if the collection is empty.

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
The quantity of items ('Any', 'Single', 'Multiple') that must make the predicate true to make the assertion fail.

The default is 'Any'.
.Example
Assert-NotExists @(1, 2, 3, 4, 5) {param($n) $n -gt 10}
Assert that no item in the array is greater than 10.
.Example
Assert-NotExists @() {param($n) $n -gt 10}
Assert that no item in the array is greater than 10.

Note:
This assertion will always pass because the array is empty.
.Example
Assert-NotExists @('H', 'E', 'L', 'L', 'O') {param($c) $c -eq 'H'} -Quantity Multiple
Assert that it is not the case that there are multiple 'H' in the array.
.Example
Assert-NotExists @('H', 'E', 'L', 'L', 'O') {param($c) $c -eq 'L'} -Quantity Single
Assert that it is not the case that there is only a single 'L' in the array.
.Example
Assert-NotExists @{a0 = 10; a1 = 20; a2 = 30} {param($entry) $entry.Value -lt 0} -Verbose
Assert that no entry in the hashtable has a value less than 0.
The -Verbose switch will output the result of the assertion to the Verbose stream.
.Example
Assert-NotExists @{a0 = 10; a1 = 20; a2 = 30} {param($entry) $entry.Value -lt 0} -Debug
Assert that no entry in the hashtable has a value less than 0.
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

Assert-NotExists $numbers {param($n) $n -isnot [system.int32]}
Assert-NotExists $numbers {param($n) $n % 2 -ne 0}
.Link
Assert-True
.Link
Assert-False
.Link
Assert-Null
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
Assert-PipelineAll
.Link
Assert-PipelineExists
.Link
Assert-PipelineNotExists
.Link
Assert-PipelineEmpty
.Link
Assert-PipelineAny
.Link
Assert-PipelineSingle
.Link
Assert-PipelineCount
#>

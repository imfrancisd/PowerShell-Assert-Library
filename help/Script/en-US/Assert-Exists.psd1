<#
.Synopsis
Assert that a predicate is true for some of the items in a collection.
.Description
This function throws an error if there does not exist an item in the collection that makes predicate true.

The meaning of "to exist" can be modified with the -Quantity parameter.

Note:
The assertion will always fail if the collection is empty.

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
The quantity of items ('Any', 'Single', 'Multiple') that must make the predicate true to make the assertion pass.

The default is 'Any'.
.Example
Assert-Exists @(1, 2, 3, 4, 5) {param($n) $n -gt 3}
Assert that at least one item in the array is greater than 3.
.Example
Assert-Exists @() {param($n) $n -gt 3}
Assert that at least one item in the array is greater than 3.

Note:
This assertion will always fail because the array is empty.
.Example
Assert-Exists @('H', 'E', 'L', 'L', 'O') {param($c) $c -eq 'L'} -Quantity Multiple
Assert that there are multiple 'L' in the array.
.Example
Assert-Exists @('H', 'E', 'L', 'L', 'O') {param($c) $c -eq 'H'} -Quantity Single
Assert that there is only a single 'H' in the array.
.Example
Assert-Exists @{a0 = 10; a1 = 20; a2 = 30} {param($entry) $entry.Value -gt 25} -Verbose
Assert that at least one entry in the hashtable has a value greater than 25.
The -Verbose switch will output the result of the assertion to the Verbose stream.
.Example
Assert-Exists @{a0 = 10; a1 = 20; a2 = 30} {param($entry) $entry.Value -gt 25} -Debug
Assert that at least one entry in the hashtable has a value greater than 25.
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

Assert-Exists $numbers {param($n) $n -is [system.int32]}
Assert-Exists $numbers {param($n) $n % 2 -eq 0}
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
Assert-NotExists
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

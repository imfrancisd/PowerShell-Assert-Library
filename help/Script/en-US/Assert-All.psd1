<#
.Synopsis
Assert that a predicate is true for all items in a collection.
.Description
This function throws an error if any of the following conditions are met:
    *the predicate is not true for at least one item in the collection

Note:
The assertion will always pass if the collection is empty.

*See the -Collection and -Predicate parameters for more details.
.Parameter private:Collection
The collection of items used to test the predicate.

The order in which the items in the collection are tested is determined by the collection's GetEnumerator method.
.Parameter private:Predicate
The script block that will be invoked on each item in the collection.

The script block must take one argument and return a value.

Note:
The -ErrorAction parameter has NO effect on the predicate.
An InvalidOperationException is thrown if the predicate throws an error.
Set the $ErrorActionPreference variable inside the predicate if you need to use that variable.

Important:
The $ErrorActionPreference variable outside of the predicate may or may not have an effect on the predicate.

A predicate throwing an error is very rare, but it is recommended that you set the $ErrorActionPreference variable to 'Stop' before calling Assert-All.
.Example
Assert-All @(1, 2, 3, 4, 5) {param($n) $n -gt 0}
Assert that all items in the array are greater than 0.
.Example
Assert-All @() {param($n) $n -gt 0}
Assert that all items in the array are greater than 0.

Note:
This assertion will always pass because the array is empty.
This is known as vacuous truth.
.Example
Assert-All @{a0=10; a1=20; a2=30} {param($entry) $entry.Value -gt 5} -Verbose
Assert that all entries in the hashtable have a value greater than 5.
The -Verbose switch will output the result of the assertion to the Verbose stream.
.Example
Assert-All @{a0=10; a1=20; a2=30} {param($entry) $entry.Value -gt 5} -Debug
Assert that all entries in the hashtable have a value greater than 5.
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

#set $ErrorActionPreference to stop in case the predicate fails
$ErrorActionPreference = 'Stop'

Assert-All $numbers {param($n) $n -is [system.int32]}
Assert-All $numbers {param($n) $n % 2 -eq 0}
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
Assert-Exists
.Link
Assert-NotExists
.Link
Assert-PipelineEmpty
.Link
Assert-PipelineAny
.Link
Assert-PipelineSingle
.Link
Assert-PipelineCount
#>

<#
.Synopsis
Assert that a predicate is not true for any item in a collection.
.Description
This function throws an error if any of the following conditions are met:
    *the predicate is true for some of the items in the collection

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

A predicate throwing an error is very rare, but it is recommended that you set the $ErrorActionPreference variable to 'Stop' before calling Assert-NotExists.
.Example
Assert-NotExists @(1, 2, 3, 4, 5) {param($n) $n -gt 10}
Assert that no item in the array is greater than 10.
.Example
Assert-NotExists @() {param($n) $n -gt 10}
Assert that no item in the array is greater than 10.

Note:
This assertion will always pass because the array is empty.
.Example
Assert-NotExists @{a0=10; a1=20; a2=30} {param($entry) $entry.Value -lt 0} -Verbose
Assert that no entry in the hashtable has a value less than 0.
The -Verbose switch will output the result of the assertion to the Verbose stream.
.Example
Assert-NotExists @{a0=10; a1=20; a2=30} {param($entry) $entry.Value -lt 0} -Debug
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

#set $ErrorActionPreference to stop in case the predicate fails
$ErrorActionPreference = 'Stop'

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
Assert-PipelineEmpty
.Link
Assert-PipelineAny
.Link
Assert-PipelineSingle
.Link
Assert-PipelineCount
#>

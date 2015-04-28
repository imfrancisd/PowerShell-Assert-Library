<#
.Synopsis
Assert that a predicate is not true for any object in the pipeline.
.Description
This function throws an error if any of the following conditions are met:
    *the predicate is true for some of the objects in the pipeline

Note:
The assertion will always pass if the pipeline is empty.

*See the -InputObject and -Predicate parameters for more details.
.Parameter InputObject
The object that is used to test the predicate.
.Parameter Predicate
The script block that will be invoked for each object in the pipeline.

The script block must take one argument and return a value.

Note:
The -ErrorAction parameter has NO effect on the predicate.
An InvalidOperationException is thrown if the predicate throws an error.
.Example
@(1, 2, 3, 4, 5) | Assert-PipelineNotExists {param($n) $n -gt 10}
Assert that no item in the array is greater than 10, and outputs each item one at a time.
.Example
@() | Assert-PipelineNotExists {param($n) $n -gt 10}
Assert that no item in the array is greater than 10, and outputs each item one at a time.

Note:
This assertion will always pass because the array is empty.
.Example
@{a0=10; a1=20; a2=30}.GetEnumerator() | Assert-PipelineNotExists {param($entry) $entry.Value -lt 0} -Verbose
Assert that no entry in the hashtable has a value less than 0, and outputs each entry one at a time.
The -Verbose switch will output the result of the assertion to the Verbose stream.

Note:
The GetEnumerator() method must be used in order to pipe the entries of a hashtable into a function.
.Example
@{a0=10; a1=20; a2=30}.GetEnumerator() | Assert-PipelineNotExists {param($entry) $entry.Value -lt 0} -Debug
Assert that no entry in the hashtable has a value less than 0, and outputs each entry one at a time.
The -Debug switch gives you a chance to investigate a failing assertion before an error is thrown.

Note:
The GetEnumerator() method must be used in order to pipe the entries of a hashtable into a function.
.Inputs
System.Object

This function accepts any kind of object from the pipeline.
.Outputs
System.Object

If the assertion passes, this function outputs the objects from the pipeline input.
.Notes
An example of how this function might be used in a unit test.

#display passing assertions
$VerbosePreference = [System.Management.Automation.ActionPreference]::Continue

#display debug prompt on failing assertions
$DebugPreference = [System.Management.Automation.ActionPreference]::Inquire

$numbers = myNumberGenerator |
    Assert-PipelineNotExists {param($n) $n -isnot [system.int32]} |
    Assert-PipelineNotExists {param($n) $n % 2 -ne 0} |
    Assert-PipelineNotExists {param($n) $n -gt 0}
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

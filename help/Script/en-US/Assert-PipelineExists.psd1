<#
.Synopsis
Assert that a predicate is true for some objects in the pipeline.
.Description
This function throws an error if there does not exist an item in the pipeline that makes predicate true.

The meaning of "to exist" can be modified with the -Quantity parameter.

Note:
The assertion will always fail if the pipeline is empty.

*See the -InputObject, -Predicate, and -Quantity parameters for more details.
.Parameter InputObject
The object that is used to test the predicate.
.Parameter Predicate
The script block that will be invoked for each object in the pipeline.

The script block must take one argument and return a value.

Note:
The -ErrorAction parameter has NO effect on the predicate.
An InvalidOperationException is thrown if the predicate throws an error.
.Parameter Quantity
The quantity of items ('Any', 'Single', 'Multiple') that must make the predicate true to make the assertion pass.

The default is 'Any'.
.Example
@(1, 2, 3, 4, 5) | Assert-PipelineExists {param($n) $n -gt 3}
Assert that at least one item in the array is greater than 3, and outputs each item one at a time.
.Example
@() | Assert-PipelineExists {param($n) $n -gt 3}
Assert that at least one item in the array is greater than 3, and outputs each item one at a time.

Note:
This assertion will always fail because the array is empty.
.Example
@('H', 'E', 'L', 'L', 'O') | Assert-PipelineExists {param($c) $c -eq 'L'} -Quantity Multiple
Assert that there are multiple 'L' in the array.
.Example
@('H', 'E', 'L', 'L', 'O') | Assert-PipelineExists {param($c) $c -eq 'H'} -Quantity Single
Assert that there is only a single 'H' in the array.
.Example
@{a0 = 10; a1 = 20; a2 = 30}.GetEnumerator() | Assert-PipelineExists {param($entry) $entry.Value -gt 25} -Verbose
Assert that at least one entry in the hashtable has a value greater than 25, and outputs each entry one at a time.
The -Verbose switch will output the result of the assertion to the Verbose stream.

Note:
The GetEnumerator() method must be used in order to pipe the entries of a hashtable into a function.
.Example
@{a0 = 10; a1 = 20; a2 = 30}.GetEnumerator() | Assert-PipelineExists {param($entry) $entry.Value -gt 25} -Debug
Assert that at least one entry in the hashtable has a value greater than 25, and outputs each entry one at a time.
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
    Assert-PipelineExists {param($n) $n -is [system.int32]} |
    Assert-PipelineExists {param($n) $n % 2 -eq 0} |
    Assert-PipelineExists {param($n) $n -gt 0}
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
Assert-NotExists
.Link
Assert-PipelineAll
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

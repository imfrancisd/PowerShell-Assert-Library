<#
.Synopsis
Generates groups of items (such as combinations, permutations, and Cartesian products) from lists that make common testing tasks easy and simple.
.Description
Generates groups of items from lists that can be used to create test input data, or to analyze test output data.

Here are the names of the list processing functions:

    Pair, Window,
    RotateLeft, RotateRight,
    Combine, Permute,
    CartesianProduct, CoveringArray, and Zip.

With these functions, many tasks that would require nested loops can be simplified to a single loop or a single pipeline. Here is an example of testing multiple scripts using different PowerShell configurations.

    $versions     = @(2, 4)
    $apStates     = @('-sta', '-mta')
    $execPolicies = @('remotesigned')
    $fileNames    = @('.\script1.ps1', '.\script2.ps1', '.\script3.ps1')

    Group-ListItem -CartesianProduct $versions, $apStates, $execPolicies, $fileNames | % {
        $ver, $aps, $exp, $file = $_.Items
        if (($ver -le 2) -and ($aps -eq '-mta')) {$aps = ''}    #PS2 has no -mta switch

        powershell -version $ver $aps -noprofile -noninteractive -executionpolicy $exp -file $file
    }

This kind of task typically requires nested loops (one loop for each parameter), but this example uses Group-ListItem -CartesianProduct to generate the parameter values for powershell.exe.
.Parameter Pair
Groups adjacent items inside a list.
Each group has two items.

Note:
This function does not return any groups if:
    *the length of the list is less than 2.

The input list is never modified by this function.
.Parameter Window
Groups adjacent items inside a list.
The number of items in each group is specified with the -Size parameter.
If the -Size parameter is not specified, the number of items in each group is the same as the length of the list.

Note:
This function does not return any groups if:
    *the value of the -Size parameter is less than 0
    *the value of the -Size parameter is greater than the length of the list.

This function will return 1 group with 0 items if:
    *the value of the -Size parameter is 0.

The input list is never modified by this function.
.Parameter RotateLeft
Groups items in a list by rotating them to the left until they return to their original position.

    Example:
    Group-ListItem -RotateLeft @(1, 2, 3)

    Items
    -----
    {1, 2, 3}
    {2, 3, 1}
    {3, 1, 2}

    Notice how the last item (3) moves to the left.

Note:
This function will return 1 group with 0 items if:
    *the length of the list is 0.

The input list is never modified by this function.
.Parameter RotateRight
Groups items in a list by rotating them to the right until they return to their original position.

    Example:
    Group-ListItem -RotateRight @(1, 2, 3)

    Items
    -----
    {1, 2, 3}
    {3, 1, 2}
    {2, 3, 1}

    Notice how the first item (1) moves to the right.

Note:
This function will return 1 group with 0 items if:
    *the length of the list is 0.

The input list is never modified by this function.
.Parameter Combine
Groups items inside a list into combinations.
The number of items in each group is specified with the -Size parameter.
If the -Size parameter is not specified, the number of items in each group is the same as the length of the list.

Note:
This function does not return any groups if:
    *the value of the -Size parameter is less than 0
    *the value of the -Size parameter is greater than the length of the list.

This function will return 1 group with 0 items if:
    *the value of the -Size parameter is 0.

The input list is never modified by this function.
.Parameter Permute
Groups items inside a list into permutations.
The number of items in each group is specified with the -Size parameter.
If the -Size parameter is not specified, the number of items in each group is the same as the length of the list.

Note:
This function does not return any groups if:
    *the value of the -Size parameter is less than 0
    *the value of the -Size parameter is greater than the length of the list.

This function will return 1 group with 0 items if:
    *the value of the -Size parameter is 0.

The input list is never modified by this function.
.Parameter CartesianProduct
Groups items from 0 or more lists into cartesian products.
Each group has the same number of items as the number of lists specified.

Note:
This function does not return any groups if:
    *no lists are specified
    *any of the specified lists are empty.

The lists do not need to have the same number of items.

The lists (and the list that contains them) are never modified by this function.
.Parameter CoveringArray
Groups items from 0 or more lists into a filtered output of cartesian product for t-way testing.
Each group has the same number of items as the number of lists specified.

See the -Strength parameter for more details.

Note:
This function does not return any groups if:
    *no lists are specified
    *any of the specified lists are empty
    *the value of the -Strength parameter is negative or 0.

This function will return the cartesian product if:
    *the -Strength parameter is not specified
    *the value of the -Strength parameter is greater than or equal to the number of lists.

The lists do not need to have the same number of items.

The lists (and the list that contains them) are never modified by this function.


Implementation Notes:
    *does not always create the smallest covering array possible
    *repeatable covering array output (no randomization)
    *streaming covering array output (no unnecessary waiting)


=======================================================================
See nist.gov for more details about covering arrays:
    Practical Combinatorial Testing
    by D. Richard Kuhn, Raghu N. Kacker, and Yu Lei
    http://csrc.nist.gov/groups/SNS/acts/documents/SP800-142-101006.pdf

    NIST Covering Array Tables - What is a covering array?
    http://math.nist.gov/coveringarrays/coveringarray.html
=======================================================================
.Parameter Zip
Groups items from 0 or more lists that have the same index.
Each group has the same number of items as the number of lists specified.

Note:
This function does not return any groups if:
    *no lists are specified
    *any of the specified lists are empty.

If the lists do not have the same number of items, the number of groups in the output is equal to the number of items in the list with the fewest items.

The lists (and the list that contains them) are never modified by this function.
.Parameter Size
The number of items per group for combinations, permutations, and windows.
.Parameter Strength
The strength of the covering array.

A covering array of strength n is a filtered form of Cartesian product where all n-tuple of values from any n lists appears in at least 1 row of the output.

Example:

    $aList = @('a1','a2')
    $bList = @('b1','b2')
    $cList = @('c1','c2')
    $dList = @('d1','d2','d3')

    group-listItem -coveringArray $aList, $bList, $cList, $dList -strength 2

Outputs the covering array:

    Items
    -----
    {a1, b1, c1, d1}
    {a1, b1, c1, d2}
    {a1, b1, c1, d3}
    {a1, b1, c2, d1}
    {a1, b1, c2, d2}
    {a1, b1, c2, d3}
    {a1, b2, c1, d1}
    {a1, b2, c1, d2}
    {a1, b2, c1, d3}
    {a1, b2, c2, d1}
    {a2, b1, c1, d1}
    {a2, b1, c1, d2}
    {a2, b1, c1, d3}
    {a2, b1, c2, d1}
    {a2, b2, c1, d1}

The covering array above has a strength of 2 because if you take any 2 lists from the input, all the ways that the values from those 2 lists can be grouped appears in one or more rows in the output.
    $aList, $bList: (a1, b1) (a1, b2) (a2, b1) (a2, b2)
    $aList, $cList: (a1, c1) (a1, c2) (a2, c1) (a2, c2)
    $aList, $dList: (a1, d1) (a1, d2) (a1, d3) (a2, d1) (a2, d2) (a2, d3)
    $bList, $cList: (b1, c1) (b1, c2) (b2, c1) (b2, c2)
    $bList, $dList: (b1, d1) (b1, d2) (b1, d3) (b2, d1) (b2, d2) (b2, d3)
    $cList, $dList: (c1, d1) (c1, d2) (c1, d3) (c2, d1) (c2, d2) (c2, d3)

The covering array above DOES NOT have a strength of 3 because if you take any 3 lists from the input, the output DOES NOT contain all the ways that the values from those 3 lists can be grouped.
    $aList, $bList, $cList: (a2, b2, c2) missing
    $aList, $bList, $dList: (a2, b2, d2) (a2, b2, d3) missing
    $aList, $cList, $dList: (a2, c2, d2) (a2, c2, d3) missing
    $bList, $cList, $dList: (b2, c2, d2) (b2, c2, d3) missing

In general, covering arrays with a high strength have more rows than covering arrays with a low strength, and the Cartesian product is a covering array with the highest strength possible.


=======================================================================
See nist.gov for more details about covering arrays:
    Practical Combinatorial Testing
    by D. Richard Kuhn, Raghu N. Kacker, and Yu Lei
    http://csrc.nist.gov/groups/SNS/acts/documents/SP800-142-101006.pdf

    NIST Covering Array Tables - What is a covering array?
    http://math.nist.gov/coveringarrays/coveringarray.html
=======================================================================
.Example
group-listItem -pair @(10, 20, 30, 40, 50)
Outputs the following arrays:

    Items
    -----
    {10, 20}
    {20, 30}
    {30, 40}
    {40, 50}
.Example
group-listItem -pair $numbers | assert-pipelineall {param($pair) $a, $b = $pair.Items; $a -le $b} | out-null
Asserts that the items in $numbers are sorted in ascending order using the PowerShell -le operator for comparisons.

If $numbers were defined as

    $numbers = @(10, 20, 30, 40, 50)

then the this example is equivalent to

    assert-true (10 -le 20)
    assert-true (20 -le 30)
    assert-true (30 -le 40)
    assert-true (40 -le 50)
.Example
group-listItem -window @(1, 2, 3, 5, 8, 13, 21) -size 3
Outputs the following arrays:

    Items
    -----
    {1, 2, 3}
    {2, 3, 5}
    {3, 5, 8}
    {5, 8, 13}
    {8, 13, 21}
.Example
group-listItem -window $numbers -size 3 | assert-pipelineall {param($window) $a, $b, $c = $window.Items; ($a + $b) -eq $c} | out-null
Asserts that the numbers in the sequence is the sum of the two previous numbers in the sequence (Fibonacci sequence) using the PowerShell -eq operator for comparisons.

If $numbers were defined as

    $numbers = @(1, 2, 3, 5, 8, 13, 21)

then the example is equivalent to

    assert-true ((1 + 2) -eq 3)
    assert-true ((2 + 3) -eq 5)
    assert-true ((3 + 5) -eq 8)
    assert-true ((5 + 8) -eq 13)
    assert-true ((8 + 13) -eq 21)
.Example
group-listItem -rotateLeft @('a', 'b', 'c', $null)
Outputs the following arrays:

    Items
    -----
    {a, b, c, $null}
    {b, c, $null, a}
    {c, $null, a, b}
    {$null, a, b, c}

See also the -RotateRight parameter.
.Example
group-listItem -rotateLeft $strings | assert-pipelineall {param($rotations) (sortedJoin $rotations.Items) -eq 'abc'} | out-null
Asserts that the result of "sortedJoin" will be equal to "abc", regardless of the order items in $strings, using the PowerShell -eq operator for comparisons.

If $strings and sortedJoin were defined as

    $strings = @('a', 'b', 'c', $null)
    function sortedJoin($list) {return ($list | sort-object) -join ''}

then the example is equivalent to

    assert-true ((sortedJoin @('a', 'b', 'c', $null)) -eq 'abc')
    assert-true ((sortedJoin @('b', 'c', $null, 'a')) -eq 'abc')
    assert-true ((sortedJoin @('c', $null, 'a', 'b')) -eq 'abc')
    assert-true ((sortedJoin @($null, 'a', 'b', 'c')) -eq 'abc')

See also the -RotateRight parameter.
.Example
group-listItem -combine @('a', 'b', 'c', 'd', 'e') -size 3
Outputs the following arrays:

    Items
    -----
    {a, b, c}
    {a, b, d}
    {a, b, e}
    {a, c, d}
    {a, c, e}
    {a, d, e}
    {b, c, d}
    {b, c, e}
    {b, d, e}
    {c, d, e}
.Example
group-listItem -combine $words -size 3 | assert-pipelineall {param($combinations) ($combinations.Items -join ' ').length -lt 10} | out-null
Asserts that if any 3 items from $words are joined, the length of the string is less than 10, using the PowerShell -lt operator for comparisons.

If $words were defined as

    $words = @('a', 'b', 'c', 'd', 'e')

then the example is equivalent to

    assert-true (('a', 'b', 'c' -join ' ').length -lt 10)
    assert-true (('a', 'b', 'd' -join ' ').length -lt 10)
    assert-true (('a', 'b', 'e' -join ' ').length -lt 10)
    assert-true (('a', 'c', 'd' -join ' ').length -lt 10)
    assert-true (('a', 'c', 'e' -join ' ').length -lt 10)
    assert-true (('a', 'd', 'e' -join ' ').length -lt 10)
    assert-true (('b', 'c', 'd' -join ' ').length -lt 10)
    assert-true (('b', 'c', 'e' -join ' ').length -lt 10)
    assert-true (('b', 'd', 'e' -join ' ').length -lt 10)
    assert-true (('c', 'd', 'e' -join ' ').length -lt 10)
.Example
group-listItem -permute @(10, 20, 30)
Outputs the following arrays:

    Items
    -----
    {10, 20, 30}
    {10, 30, 20}
    {20, 10, 30}
    {20, 30, 10}
    {30, 10, 20}
    {30, 20, 10}
.Example
group-listItem -permute $numbers | assert-pipelineall {param($permutations) (add $permutations.Items) -eq 60} | out-null
Asserts that the result of "add" will be equal to 60, regardless of the order of the items in $numbers, using the PowerShell -eq operator for comparisons.

If $numbers and add were defined as

    $numbers = @(10, 20, 30)
    function add($list) {return ($list | measure -sum).sum}

then the example is equivalent to

    assert-true ((add @(10, 20, 30)) -eq 60)
    assert-true ((add @(10, 30, 20)) -eq 60)
    assert-true ((add @(20, 10, 30)) -eq 60)
    assert-true ((add @(20, 30, 10)) -eq 60)
    assert-true ((add @(30, 10, 20)) -eq 60)
    assert-true ((add @(30, 20, 10)) -eq 60)
.Example
group-listItem -cartesianProduct @(0), @(-2, -1, 0, 1, 2), @('stop', 'silentlycontinue')
Outputs the following arrays:

    Items
    -----
    {0, -2, stop}
    {0, -2, silentlycontinue}
    {0, -1, stop}
    {0, -1, silentlycontinue}
    {0, 0, stop}
    {0, 0, silentlycontinue}
    {0, 1, stop}
    {0, 1, silentlycontinue}
    {0, 2, stop}
    {0, 2, silentlycontinue}
.Example
group-listItem -cartesianProduct @(0), $numbers, $ea | assert-pipelineall {param($cProduct) $a, $b, $c = $cProduct.Items; (add $a $b -erroraction $c) -eq $b} | out-null
Asserts that the result of (add 0 $number) is equal to $number, using the PowerShell -eq operator for comparisons.

If $numbers, $ea, and add were defined as

    $numbers = @(-2, -1, 0, 1, 2)
    $ea = @('stop', 'silentlycontinue')
    function add {[cmdletbinding()]param($a, $b) return $a + $b}

then the example is equivalent to

    assert-true ((add 0 -2 -erroraction stop) -eq -2)
    assert-true ((add 0 -2 -erroraction silentlycontinue) -eq -2)
    assert-true ((add 0 -1 -erroraction stop) -eq -1)
    assert-true ((add 0 -1 -erroraction silentlycontinue) -eq -1)
    assert-true ((add 0 0 -erroraction stop) -eq 0)
    assert-true ((add 0 0 -erroraction silentlycontinue) -eq 0)
    assert-true ((add 0 1 -erroraction stop) -eq 1)
    assert-true ((add 0 1 -erroraction silentlycontinue) -eq 1)
    assert-true ((add 0 2 -erroraction stop) -eq 2)
    assert-true ((add 0 2 -erroraction silentlycontinue) -eq 2)
.Example
group-listItem -coveringArray @('a1','a2','a3'), @('b1','b2','b3','b4','b5'), @('c1','c2') -strength 1
Outputs the following arrays:

    Items
    -----
    {a1, b1, c1}
    {a2, b2, c2}
    {a3, b3, c1}
    {a1, b4, c2}
    {a2, b5, c1}

Notice the following:
    *a1, a2, and a3 all appear in at least one row
    *b1, b2, b3, b4, and b5 all appear in at least one row
    *c1 and c2 all appear in at least one row

See the -Strength parameter for more details.
.Example
group-listItem -coveringArray $aList, $bList, $cList -strength 1 | assert-pipelineall {param($cArray) $a, $b, $c = $cArray.Items; $null -ne (f $a $b $c)} | out-null
Asserts that the result of (f $a $b $c) is never $null, using the covering array of strength 1 generated from the lists.

If $aList, $bList, $cList, and f were defined as

    $aList = @('a1','a2','a3')
    $bList = @('b1','b2','b3','b4','b5')
    $cList = @('c1','c2')
    function f($a, $b, $c) {"$a $b $c"}

then the example is equivalent to

    assert-true ($null -ne (f 'a1' 'b1' 'c1'))
    assert-true ($null -ne (f 'a2' 'b2' 'c2'))
    assert-true ($null -ne (f 'a3' 'b3' 'c1'))
    assert-true ($null -ne (f 'a1' 'b4' 'c2'))
    assert-true ($null -ne (f 'a2' 'b5' 'c1'))
.Example
group-listItem -zip @('a', 'b', 'c'), @(1, 2, 3, 4, 5)
Outputs the following arrays:

    Items
    -----
    {a, 1}
    {b, 2}
    {c, 3}

Note:
Zip takes 0 or more lists, and the list with the fewest items determines the number of arrays that zip outputs.

In this example, the list with the fewest items (@('a', 'b', 'c')) only has 3 items, so zip outputs 3 arrays.
.Example
group-listItem -zip $aList, $bList | assert-pipelineall {param($zipped) $a, $b = $zipped.Items; $a -eq $b} | out-null
Asserts that the first items in $aList are equal to the first items in $bList using the PowerShell -eq operator for comparisons.

If $aList and $bList were defined as

    $aList = @(1, 2, 3, 4, 5)
    $bList = @(1, 2, 3, 4, 5, 6, 7, 8, 9)

then the example is equivalent to

    assert-true (1 -eq 1)
    assert-true (2 -eq 2)
    assert-true (3 -eq 3)
    assert-true (4 -eq 4)
    assert-true (5 -eq 5)
.Inputs
None

This function does not accept input from the pipeline.
.Outputs
System.Management.Automation.PSCustomObject

The PSCustomObject has a property called 'Items' which will always be an array.

None of the input lists are ever used as the 'Items' property in any of the outputs.

None of the outputs will ever have an 'Items' property that is referentially equal to another 'Items' property from another output.

The array in the 'Items' property has a type of [System.Object[]] by default. However, the 'Items' property may be constrained with a specific type, such as [System.Int32[]], if the list input to -RotateLeft, -RotateRight, -Pair, -Window, -Combine, or -Permute is constrained to a specific type, or if the list inputs to -CartesianProduct or -Zip are constrained to the same specific type.
.Notes
Why not output a list of lists?

The ideal output for this function is a list of lists. That would allow, for example, to take the output of (Group-ListItem -Zip ...) and later on, feed it directly as input to (Group-ListItem -Zip ...). This is useful because if you look at multiple lists of the same length as rows and columns of data, then -Zip can be used to transpose the rows into columns, and calling -Zip a second time allows you to "undo" the transpose operation.

This was not done for this function because in PowerShell, functions returning lists can be error-prone when used in a pipeline. Also, by convention, public functions in PowerShell do not return lists, but return the contents of the list one at a time.

If you want the output to be a list of lists, then I suggest you create wrapper functions like this:

    function zip($listOfLists)
    {
        $a = @(Group-ListItem -Zip $listOfLists)
        for ($i = 0; $i -lt $a.length; $i++) {
            $a[$i] = $a[$i].Items
        }
        ,$a
    }

Note that using nested lists in the PowerShell pipeline will cause subtle bugs, so these wrapper functions should never be used in a pipeline and their implementations should never use the pipeline.
.Link
Test-True
.Link
Test-All
.Link
Test-Exists
.Link
Test-NotExists
.Link
Assert-True
.Link
Assert-All
.Link
Assert-Exists
.Link
Assert-NotExists
.Link
Assert-PipelineAll
.Link
Assert-PipelineExists
.Link
Assert-PipelineNotExists
.Link
Assert-PipelineCount
#>

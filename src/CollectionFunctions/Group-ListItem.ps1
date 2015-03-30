<#
.Synopsis
Generates groups of items (such as combinations, permutations, and Cartesian products) from lists that make common testing tasks easy and simple.
.Description
The following list processing functions can be used to generate test data, to run functions and scripts with different parameter values, or even to generate parts of test scripts.

Function            Description
--------            -----------
Pair                groups adjacent items in a list into groups of 2 items
Window              groups adjacent items in a list into groups of 0 or more items
Combine             groups items in a list into combinations of 0 or more items
Permute             groups items in a list into permutations of 0 or more items
CoveringArray       groups items from n lists into a covering array for t-way tests
CartesianProduct    groups items from n lists into cartesian products of n items
Zip                 groups items from n lists with the same index into groups of n items

With these functions, many tasks that would require nested loops can be simplified to a single loop or a single pipeline.

Here is an example of testing multiple scripts using different PowerShell configurations. This kind of task typically requires nested loops (one loop for each parameter), but this example uses Group-ListItem -CartesianProduct to generate the parameter values for powershell.exe.

  $versions     = @(2, 4)
  $apStates     = @('-sta', '-mta')
  $execPolicies = @('remotesigned')
  $fileNames    = @('.\script1.ps1', '.\script2.ps1', '.\script3.ps1')

  Group-ListItem -CartesianProduct $versions, $apStates, $execPolicies, $fileNames | % {
    $ver, $aps, $exp, $file = $_.Items
    if (($ver -le 2) -and ($aps -eq '-mta')) {$aps = ''}    #PS2 has no -mta switch

    powershell -version $ver $aps -noprofile -noninteractive -executionpolicy $exp -file $file
  }
.Parameter Pair
Groups adjacent items inside a list.
Each group has two items.

Note:
This function does not return any groups if:
    *the length of the list is less than 2
.Parameter Window
Groups adjacent items inside a list.
The number of items in each group is specified with the -Size parameter.
If the -Size parameter is not specified, the number of items in each group is the same as the length of the list.

Note:
This function does not return any groups if:
    *the value of the -Size parameter is less than 0
    *the value of the -Size parameter is greater than the length of the list

This function will return 1 group with 0 items if:
    *the value of the -Size parameter is 0
.Parameter Combine
Groups items inside a list into combinations.
The number of items in each group is specified with the -Size parameter.
If the -Size parameter is not specified, the number of items in each group is the same as the length of the list.

Note:
This function does not return any groups if:
    *the value of the -Size parameter is less than 0
    *the value of the -Size parameter is greater than the length of the list

This function will return 1 group with 0 items if:
    *the value of the -Size parameter is 0
.Parameter Permute
Groups items inside a list into permutations.
The number of items in each group is specified with the -Size parameter.
If the -Size parameter is not specified, the number of items in each group is the same as the length of the list.

Note:
This function does not return any groups if:
    *the value of the -Size parameter is less than 0
    *the value of the -Size parameter is greater than the length of the list

This function will return 1 group with 0 items if:
    *the value of the -Size parameter is 0
.Parameter Size
The number of items per group for combinations, permutations, and windows.
.Parameter CoveringArray
Groups items from 0 or more lists into a filtered output of cartesian product for t-way testing.
Each group has the same number of items as the number of lists specified.

See the -Strength parameter for more details.

Note:
This function does not return any groups if:
    *no lists are specified
    *any of the specified lists are empty
    *the value of the -Strength parameter is negative
    *the value of the -Strength parameter is 0 (this may change)

This function will return the cartesian product if:
    *the -Strength parameter is not specified
    *the value of the -Strength parameter is greater than or equal to the number of lists

The lists do not need to have the same number of items.


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
.Parameter CartesianProduct
Groups items from 0 or more lists into cartesian products.
Each group has the same number of items as the number of lists specified.

Note:
This function does not return any groups if:
    *no lists are specified
    *any of the specified lists are empty

The lists do not need to have the same number of items.
.Parameter Zip
Groups items from 0 or more lists that have the same index.
Each group has the same number of items as the number of lists specified.

Note:
This function does not return any groups if:
    *no lists are specified
    *any of the specified lists are empty

If the lists do not have the same number of items, the number of groups in the output is equal to the number of items in the list with the fewest items.
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
group-listItem -pair $numbers | foreach-object {$a, $b = $_.Items; assert-true ($a -le $b)}

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
group-listItem -window $numbers -size 3 | foreach-object {$a, $b, $c = $_.Items; assert-true (($a + $b) -eq $c)}

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
group-listItem -combine $words -size 3 | foreach-object {assert-true (($_.items -join ' ').length -lt 10)}

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
group-listItem -permute $numbers | foreach-object {assert-true ((add $_.items) -eq 60)}

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
group-listItem -cartesianProduct @(0), $numbers, $ea | foreach-object {$a, $b, $c = $_.Items; assert-true ((add $a $b -erroraction $c) -eq $b)}

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
group-listItem -coveringArray $aList, $bList, $cList -strength 1 | foreach-object {$a, $b, $c = $_.Items; assert-notnull (f $a $b $c)}

Asserts that the result of (f $a $b $c) is never $null, using the covering array of strength 1 generated from the lists.

If $aList, $bList, $cList, and f were defined as

    $aList = @('a1','a2','a3')
    $bList = @('b1','b2','b3','b4','b5')
    $cList = @('c1','c2')
    function f($a, $b, $c) {"$a $b $c"}

then the example is equivalent to

    assert-notnull (f 'a1' 'b1' 'c1')
    assert-notnull (f 'a2' 'b2' 'c2')
    assert-notnull (f 'a3' 'b3' 'c1')
    assert-notnull (f 'a1' 'b4' 'c2')
    assert-notnull (f 'a2' 'b5' 'c1')


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
group-listItem -zip $aList, $bList | foreach-object {$a, $b = $_.Items; assert-true ($a -eq $b)}

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

Assert that two lists are equal
-------------------------------
assert-true ($aList.count -eq $bList.count)
group-listItem -zip $aList, $bList | foreach-object {$a, $b = $_.Items; assert-true ($a -eq $b)}
.Inputs
System.Collections.IList
.Outputs
System.Management.Automation.PSCustomObject

The PSCustomObject has a property called 'Items' which will always be an array.

The array in the 'Items' property has a type of [System.Object[]] by default. However, the 'Items' property may be constrained with a specific type, such as [System.Int32[]], if the list input to -Pair, -Window, -Combine, or -Permute is constrained to a specific type, or if the list inputs to -CartesianProduct or -Zip are constrained to the same specific type.
.Notes
Why not output a list of lists?

The ideal output for this function is a list of lists. That would allow, for example, to take the output of (Group-ListItem -Zip ...) and later on, feed it directly as input to (Group-ListItem -Zip ...). This is useful because if you look at multiple lists of the same length as rows and columns of data, then -Zip can be used to transpose the rows into columns, and calling -Zip a second time allows you to "undo" the transposition.

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
#>
function Group-ListItem
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, ParameterSetName='Pair')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Pair,

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, ParameterSetName='Window')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Window,

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, ParameterSetName='Combine')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Combine,

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, ParameterSetName='Permute')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Permute,

        [Parameter(Mandatory=$false, ValueFromPipeline=$false, ParameterSetName='Combine')]
        [Parameter(Mandatory=$false, ValueFromPipeline=$false, ParameterSetName='Permute')]
        [Parameter(Mandatory=$false, ValueFromPipeline=$false, ParameterSetName='Window')]
        [System.Int32]
        $Size,

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, ParameterSetName='CoveringArray')]
        [AllowEmptyCollection()]
        [ValidateNotNull()]
        [System.Collections.IList[]]
        $CoveringArray,

        [Parameter(Mandatory=$false, ValueFromPipeline=$false, ParameterSetName='CoveringArray')]
        [System.Int32]
        $Strength,

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, ParameterSetName='CartesianProduct')]
        [AllowEmptyCollection()]
        [ValidateNotNull()]
        [System.Collections.IList[]]
        $CartesianProduct,

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, ParameterSetName='Zip')]
        [AllowEmptyCollection()]
        [ValidateNotNull()]
        [System.Collections.IList[]]
        $Zip
    )

    #NOTE about [ValidateNotNull()]
    #
    #The ValidateNotNull() attribute validates that a list and its contents are not $null.
    #The -Combine, -Permute, -Pair, and -Window parameters NOT having this attribute and
    #-CartesianProduct, -CoveringArray and -Zip having this attribute, is intentional.
    #
    #Mandatory=$true will make sure -Combine, -Permute, -Pair, and -Window are not $null.

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    function getListLength($list)
    {
        if ($list -is [System.Array]) {
            return $list.psbase.Length
        }
        if ($list -is [System.Collections.IList]) {
            return $list.psbase.Count
        }
        return 0
    }

    function getElementType($list)
    {
        #NOTE about compatibility
        #
        #In PowerShell, it is possible to override properties and methods of an object.
        #
        #The psbase property in all objects allows access to the real properties and methods.
        #
        #In PowerShell 4 (and possibly PowerShell 3) however, the psbase property does not
        #allow access to the "real" GetType method of the object. Instead, .psbase.GetType()
        #returns the type of the psbase object instead of the type of the object that psbase
        #represents.
        #
        #Explicit .NET reflection must be used if you want to make sure that you are calling
        #the "real" GetType method in PowerShell 4 (and possibly PowerShell 3).

        $objectGetType = [System.Object].GetMethod('GetType', [System.Type]::EmptyTypes)
        $genericIList = [System.Type]::GetType('System.Collections.Generic.IList`1')

        if ($list -is [System.Array]) {
            return $objectGetType.Invoke($list, $null).GetElementType()
        }
        if ($list -is [System.Collections.IList]) {
            $IListGenericTypes = @(
                $objectGetType.Invoke($list, $null).GetInterfaces() |
                Where-Object -FilterScript {
                    $_.IsGenericType -and ($_.GetGenericTypeDefinition() -eq $genericIList)
                }
            )

            if ($IListGenericTypes.Length -eq 1) {
                return $IListGenericTypes[0].GetGenericArguments()[0]
            }
        }
        return [System.Object]
    }

    switch ($PSCmdlet.ParameterSetName) {
        'Pair' {
            $listLength = getListLength $Pair
            $outputElementType = getElementType $Pair

            $count = $listLength - 1

            for ($i = 0; $i -lt $count; $i++) {
                #generate pair
                $items = [System.Array]::CreateInstance($outputElementType, 2)
                $items[0] = $Pair[$i]
                $items[1] = $Pair[$i + 1]

                #output pair
                New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                    'Items' = $items
                }
            }

            return
        }
        'Window' {
            $listLength = getListLength $Window
            $outputElementType = getElementType $Window

            if (-not $PSBoundParameters.ContainsKey('Size')) {
                $Size = $listLength
            }

            if ($Size -eq 0) {
                New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                    'Items' = [System.Array]::CreateInstance($outputElementType, 0)
                }
                return
            }
            if (($Size -lt 0) -or ($listLength -lt $Size)) {
                return
            }

            $count = $listLength - $Size + 1

            for ($i = 0; $i -lt $count; $i++) {
                #generate window
                $items = [System.Array]::CreateInstance($outputElementType, $Size)
                for ($j = 0; $j -lt $Size; $j++) {
                    $items[$j] = $Window[$j + $i]
                }

                #output window
                New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                    'Items' = $items
                }
            }

            return
        }
        'Combine' {
            $listLength = getListLength $Combine
            $outputElementType = getElementType $Combine

            if (-not $PSBoundParameters.ContainsKey('Size')) {
                $Size = $listLength
            }

            if ($Size -eq 0) {
                New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                    'Items' = [System.Array]::CreateInstance($outputElementType, 0)
                }
                return
            }
            if (($Size -lt 0) -or ($listLength -lt $Size)) {
                return
            }

            #Generate the combinations.
            #Store $Size amount of indices in an array, and increment those indices
            #in way that generates the combinations.
            #
            #The array of indices is conceptually a counter with special rules:
            #  *indices in counter are in range [0..length of list]
            #  *indices in counter are strictly increasing

            #initialize counter
            $counter = [System.Array]::CreateInstance([System.Int32], $Size)
            for ($i = 0; $i -lt $Size; $i++) {
                $counter[$i] = $i
            }

            while ($counter[-1] -lt $listLength) {
                #generate combination
                $items = [System.Array]::CreateInstance($outputElementType, $Size)
                for ($i = 0; $i -lt $Size; $i++) {
                    $items[$i] = $Combine[$counter[$i]]
                }

                #output combination
                New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                    'Items' = $items
                }

                #increment counter
                for ($i = $Size - 1; $i -ge 0; $i--) {
                    $counter[$i]++
                    if ($counter[$i] -le ($listLength - $Size + $i)) {
                        for ($i++; $i -lt $Size; $i++) {
                            $counter[$i] = $counter[$i - 1] + 1
                        }
                        break
                    }
                }
            }

            return
        }
        'Permute' {
            $listLength = getListLength $Permute
            $outputElementType = getElementType $Permute

            if (-not $PSBoundParameters.ContainsKey('Size')) {
                $Size = $listLength
            }

            if ($Size -eq 0) {
                New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                    'Items' = [System.Array]::CreateInstance($outputElementType, 0)
                }
                return
            }
            if (($Size -lt 0) -or ($listLength -lt $Size)) {
                return
            }

            #Generate the permutations.
            #Store $Size amount of indices in an array, and increment those indices
            #in way that generates the permutations.
            #
            #The array of indices is conceptually a counter with special rules:
            #  *indices in counter are in range [0..length of list]
            #  *indices in counter that are less than length of list are unique

            $counter = [System.Array]::CreateInstance([System.Int32], $Size)
            $usedIndices = @{}

            #initialize counter
            for ($i = 0; $i -lt $Size; $i++) {
                $counter[$i] = $i
                $usedIndices.Add($i, $null)
            }

            while ($counter[0] -lt $listLength) {
                #generate permutation
                $items = [System.Array]::CreateInstance($outputElementType, $Size)
                for ($i = 0; $i -lt $Size; $i++) {
                    $items[$i] = $Permute[$counter[$i]]
                }

                #output permutation
                New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                    'Items' = $items
                }

                #increment counter
                for ($i = $Size - 1; $i -ge 0; $i--) {
                    $usedIndices.Remove($counter[$i])
                    for ($counter[$i]++; $counter[$i] -lt $listLength; $counter[$i]++) {
                        if (-not $usedIndices.ContainsKey($counter[$i])) {
                            $usedIndices.Add($counter[$i], $null)
                            break
                        }
                    }

                    if ($counter[$i] -lt $listLength) {
                        for ($i++; $i -lt $Size; $i++) {
                            for ($counter[$i] = 0; $counter[$i] -lt $listLength; $counter[$i]++) {
                                if (-not $usedIndices.ContainsKey($counter[$i])) {
                                    $usedIndices.Add($counter[$i], $null)
                                    break
                                }
                            }
                        }
                        break
                    }
                }
            }

            return
        }
        'CartesianProduct' {
            $listCount = getListLength $CartesianProduct

            if ($listCount -lt 1) {
                return
            }

            #Get all the lengths of the list and
            #determine the type to use to constrain the output array.

            $listLengths = [System.Array]::CreateInstance([System.Int32], $listCount)
            $elementTypes = [System.Array]::CreateInstance([System.Type], $listCount)

            for ($i = 0; $i -lt $listCount; $i++) {
                $listLengths[$i] = getListLength $CartesianProduct[$i]
                $elementTypes[$i] = getElementType $CartesianProduct[$i]
            }

            if (@($listLengths | Sort-Object)[0] -lt 1) {
                return
            }

            if (@($elementTypes | Sort-Object -Unique).Length -eq 1) {
                $outputElementType = $elementTypes[0]
            } else {
                $outputElementType = [System.Object]
            }

            #Generate the cartesian products of the lists.
            #Store an index for each list in an array, and increment those
            #indices in way that generates the cartesian products.
            #
            #The array of indices is conceptually a counter with special rules:
            #  *indices are in range [0..length of list associated with index]

            $counter = [System.Array]::CreateInstance([System.Int32], $listCount)

            while ($counter[0] -lt $listLengths[0]) {
                $i = $listCount - 1

                for (; $counter[$i] -lt $listLengths[$i]; $counter[$i]++) {
                    #generate cartesian product
                    $items = [System.Array]::CreateInstance($outputElementType, $listCount)
                    for ($j = 0; $j -lt $listCount; $j++) {
                        $items[$j] = $CartesianProduct[$j][$counter[$j]]
                    }

                    #output cartesian product
                    New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                        'Items' = $items
                    }
                }

                #update counter
                for (; ($i -gt 0) -and ($counter[$i] -ge $listLengths[$i]); $i--) {
                    $counter[$i] = 0
                    $counter[$i - 1]++
                }
            }

            return
        }
        'Zip' {
            $listCount = getListLength $Zip

            if ($listCount -lt 1) {
                return
            }

            #Get all the lengths of the list and
            #determine the type to use to constrain the output array.

            $listLengths = [System.Array]::CreateInstance([System.Int32], $listCount)
            $elementTypes = [System.Array]::CreateInstance([System.Type], $listCount)

            for ($i = 0; $i -lt $listCount; $i++) {
                $listLengths[$i] = getListLength $Zip[$i]
                $elementTypes[$i] = getElementType $Zip[$i]
            }

            $minlistlength = @($listLengths | Sort-Object)[0]

            if (@($elementTypes | Sort-Object -Unique).Length -eq 1) {
                $outputElementType = $elementTypes[0]
            } else {
                $outputElementType = [System.Object]
            }

            #Generate the "Zip" of the lists by
            #grouping the items in each list with the same index.

            for ($i = 0; $i -lt $minListLength; $i++) {
                #generate the "Zip"
                $items = [System.Array]::CreateInstance($outputElementType, $listCount)
                for ($j = 0; $j -lt $listCount; $j++) {
                    $items[$j] = $Zip[$j][$i]
                }

                #output the "Zip"
                New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                    'Items' = $items
                }
            }

            return
        }
        'CoveringArray' {
            $listCount = getListLength $CoveringArray

            if ($listCount -lt 1) {
                return
            }

            if (-not $PSBoundParameters.ContainsKey('Strength')) {
                $Strength = $listCount
            }
            if ($Strength -lt 1) {
                return
            }

            #A Covering array with the highest strength possible is the Cartesian product
            if ($Strength -ge $listCount) {
                & $PSCmdlet.MyInvocation.MyCommand.ScriptBlock -CartesianProduct $CoveringArray
                return
            }

            #Get all the lengths of the list and
            #determine the type to use to constrain the output array.

            $listLengths = [System.Array]::CreateInstance([System.Int32], $listCount)
            $elementTypes = [System.Array]::CreateInstance([System.Type], $listCount)

            for ($i = 0; $i -lt $listCount; $i++) {
                $listLengths[$i] = getListLength $CoveringArray[$i]
                $elementTypes[$i] = getElementType $CoveringArray[$i]
            }

            if (@($listLengths | Sort-Object)[0] -lt 1) {
                return
            }

            if (@($elementTypes | Sort-Object -Unique).Length -eq 1) {
                $outputElementType = $elementTypes[0]
            } else {
                $outputElementType = [System.Object]
            }

            #If -Strength is 1, then the covering array is a modified version of -Zip.
            #The important thing is all values in the lists are used 1 or more times.

            if ($Strength -eq 1) {
                $maxListLength = @($listLengths | Sort-Object -Descending)[0]

                for ($i = 0; $i -lt $maxListLength; $i++) {
                    #generate a row in the covering array
                    $items = [System.Array]::CreateInstance($outputElementType, $listCount)
                    for ($j = 0; $j -lt $listCount; $j++) {
                        $items[$j] = $CoveringArray[$j][$i % $listLengths[$j]]
                    }

                    #output the row
                    New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                        'Items' = $items
                    }
                }

                return
            }

            #=======================================================
            #At this stage, the following must be true:
            #    0 < $Strength < $listCount
            #    all lists have at least one item
            #=======================================================

            #Generate the covering array by filtering the Cartesian product of the lists.
            #
            #Store an index for each list in an array, and increment those
            #indices in way that generates the cartesian product.
            #
            #The array of indices is conceptually a counter with special rules:
            #  *indices are in range [0..length of list associated with index]
            #
            #Filter the Cartesian product by removing any row that does not have at least
            #one unused column combination.

            $counter = [System.Array]::CreateInstance([System.Int32], $listCount)

            $usedCombinations = @{}

            #Generate a row if the value of counter has at least one new column combination.
            #
            #If $counter is {10, 20, 30, 40} and strength is 2, then the combinations are:
            #
            #    {10, 20} {10, 30} {10, 40} {20, 30} {20, 40} {30, 40}
            #
            #and they'll be converted into the following strings:
            #
            #    "0 10 20 " "1 10 30 " "2 10 40 " "3 20 30 " "4 20 40 " "5 30 40 "
            #
            #with the first number in the string being the index of the combination.

            $f = '{0:D} '
            $s = New-Object -TypeName 'System.Text.StringBuilder'

            while ($counter[0] -lt $listLengths[0]) {
                $i = $listCount - 1

                for (; $counter[$i] -lt $listLengths[$i]; $counter[$i]++) {
                    $hasNewCombination = $false

                    $combinations = @(& $PSCmdlet.MyInvocation.MyCommand.ScriptBlock -Combine $counter -Size $Strength)
                    for ($j = $combinations.Length - 1; $j -ge 0; $j--) {
                        $s.Length = 0
                        [System.Void]$s.AppendFormat($f, $j)
                        foreach ($item in $combinations[$j].Items) {
                            [System.Void]$s.AppendFormat($f, $item)
                        }

                        $combinations[$j] = $s.ToString()

                        $hasNewCombination =
                            ($hasNewCombination) -or
                            (-not $usedCombinations.Contains($combinations[$j]))
                    }

                    if ($hasNewCombination) {
                        #add column combinations to $usedCombinations
                        foreach ($item in $combinations) {
                            $usedCombinations[$item] = $null
                        }

                        #generate cartesian product
                        $items = [System.Array]::CreateInstance($outputElementType, $listCount)
                        for ($j = 0; $j -lt $listCount; $j++) {
                            $items[$j] = $CoveringArray[$j][$counter[$j]]
                        }

                        #output cartesian product
                        New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                            'Items' = $items
                        }
                    }
                }

                #update counter
                for (; ($i -gt 0) -and ($counter[$i] -ge $listLengths[$i]); $i--) {
                    $counter[$i] = 0
                    $counter[$i - 1]++
                }
            }

            return
        }
        default {
            $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                (New-Object -TypeName 'System.NotImplementedException' -ArgumentList @("The ParameterSetName '$_' was not implemented.")),
                'NotImplemented',
                [System.Management.Automation.ErrorCategory]::NotImplemented,
                $null
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }
}

<#
The MIT License (MIT)

Copyright (c) 2015 Francis de la Cerna

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

#>

#Assert Library version 1.7.6.0
#
#PowerShell requirements
#requires -version 2.0


$_7ddd17460d1743b2b6e683ef649e01b7_getListElementType = {
    [CmdletBinding()]
    [OutputType([System.Type])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IList]
        $List
    )

    if ($List -is [System.Array]) {
        return (& $_7ddd17460d1743b2b6e683ef649e01b7_getType $List).GetElementType()
    }

    if ($List -is [System.Collections.IList]) {
        $genericIList = [System.Type]::GetType('System.Collections.Generic.IList`1')

        $IListGenericTypes = @(
            (& $_7ddd17460d1743b2b6e683ef649e01b7_getType $List).GetInterfaces() |
                Microsoft.PowerShell.Core\Where-Object -FilterScript {
                    $_.IsGenericType -and ($_.GetGenericTypeDefinition() -eq $genericIList)
                }
        )

        if ($IListGenericTypes.Length -eq 1) {
            return $IListGenericTypes[0].GetGenericArguments()[0]
        }
    }

    return [System.Object]
}


$_7ddd17460d1743b2b6e683ef649e01b7_getListLength = {
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IList]
        $List
    )

    #NOTE
    #
    #In PowerShell, it is possible to override properties and methods of an object.
    #
    #The psbase property in all objects allows access to the real properties and methods.

    if ($List -is [System.Array]) {
        return $List.psbase.Length
    }

    return $List.psbase.Count
}


$_7ddd17460d1743b2b6e683ef649e01b7_getType = {
    [CmdletBinding()]
    [OutputType([System.Type])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Object]
        $InputObject
    )

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

    if ($null -eq $InputObject) {
        return [System.Void]
    }
    return $_7ddd17460d1743b2b6e683ef649e01b7_getTypeMethod.Invoke($InputObject, $null)
}

$_7ddd17460d1743b2b6e683ef649e01b7_getTypeMethod = [System.Object].GetMethod('GetType', [System.Type]::EmptyTypes)


$_7ddd17460d1743b2b6e683ef649e01b7_groupListItemCartesianProduct = {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]
        [AllowEmptyCollection()]
        [ValidateNotNull()]
        [System.Collections.IList[]]
        $CartesianProduct
    )

    $listCount = & $_7ddd17460d1743b2b6e683ef649e01b7_getListLength -List $CartesianProduct -ErrorAction $ErrorActionPreference

    if ($listCount -lt 1) {
        return
    }

    #Get all the lengths of the list and
    #determine the type to use to constrain the output array.

    $listLengths = [System.Array]::CreateInstance([System.Int32], $listCount)
    $elementTypes = [System.Array]::CreateInstance([System.Type], $listCount)

    for ($i = 0; $i -lt $listCount; $i++) {
        $listLengths[$i] = & $_7ddd17460d1743b2b6e683ef649e01b7_getListLength -List $CartesianProduct[$i] -ErrorAction $ErrorActionPreference
        $elementTypes[$i] = & $_7ddd17460d1743b2b6e683ef649e01b7_getListElementType -List $CartesianProduct[$i] -ErrorAction $ErrorActionPreference
    }

    if (@($listLengths | Microsoft.PowerShell.Utility\Sort-Object)[0] -lt 1) {
        return
    }

    if (@($elementTypes | Microsoft.PowerShell.Utility\Sort-Object -Unique).Length -eq 1) {
        $outputElementType = $elementTypes[0]
    }
    else {
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
            Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                'Items' = $items
            }
        }

        #update counter
        for (; ($i -gt 0) -and ($counter[$i] -ge $listLengths[$i]); $i--) {
            $counter[$i] = 0
            $counter[$i - 1]++
        }
    }
}


$_7ddd17460d1743b2b6e683ef649e01b7_groupListItemCombine = {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Combine,

        [Parameter(Mandatory = $false)]
        [System.Int32]
        $Size
    )

    $listLength = & $_7ddd17460d1743b2b6e683ef649e01b7_getListLength -List $Combine -ErrorAction $ErrorActionPreference
    $outputElementType = & $_7ddd17460d1743b2b6e683ef649e01b7_getListElementType -List $Combine -ErrorAction $ErrorActionPreference

    if (-not $PSBoundParameters.ContainsKey('Size')) {
        $Size = $listLength
    }

    if ($Size -eq 0) {
        Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
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
        Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
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
}


$_7ddd17460d1743b2b6e683ef649e01b7_groupListItemCoveringArray = {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]
        [AllowEmptyCollection()]
        [ValidateNotNull()]
        [System.Collections.IList[]]
        $CoveringArray,

        [Parameter(Mandatory = $false)]
        [System.Int32]
        $Strength
    )

    $listCount = & $_7ddd17460d1743b2b6e683ef649e01b7_getListLength -List $CoveringArray -ErrorAction $ErrorActionPreference

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
        & $_7ddd17460d1743b2b6e683ef649e01b7_groupListItemCartesianProduct -CartesianProduct $CoveringArray -ErrorAction $ErrorActionPreference
        return
    }

    #Get all the lengths of the list and
    #determine the type to use to constrain the output array.

    $listLengths = [System.Array]::CreateInstance([System.Int32], $listCount)
    $elementTypes = [System.Array]::CreateInstance([System.Type], $listCount)

    for ($i = 0; $i -lt $listCount; $i++) {
        $listLengths[$i] = & $_7ddd17460d1743b2b6e683ef649e01b7_getListLength -List $CoveringArray[$i] -ErrorAction $ErrorActionPreference
        $elementTypes[$i] = & $_7ddd17460d1743b2b6e683ef649e01b7_getListElementType -List $CoveringArray[$i] -ErrorAction $ErrorActionPreference
    }

    if (@($listLengths | Microsoft.PowerShell.Utility\Sort-Object)[0] -lt 1) {
        return
    }

    if (@($elementTypes | Microsoft.PowerShell.Utility\Sort-Object -Unique).Length -eq 1) {
        $outputElementType = $elementTypes[0]
    }
    else {
        $outputElementType = [System.Object]
    }

    #If -Strength is 1, then the covering array is a modified version of -Zip.
    #The important thing is all values in the lists are used 1 or more times.

    if ($Strength -eq 1) {
        $maxListLength = @($listLengths | Microsoft.PowerShell.Utility\Sort-Object -Descending)[0]

        for ($i = 0; $i -lt $maxListLength; $i++) {
            #generate a row in the covering array
            $items = [System.Array]::CreateInstance($outputElementType, $listCount)
            for ($j = 0; $j -lt $listCount; $j++) {
                $items[$j] = $CoveringArray[$j][$i % $listLengths[$j]]
            }

            #output the row
            Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
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
    $s = Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Text.StringBuilder'

    while ($counter[0] -lt $listLengths[0]) {
        $i = $listCount - 1

        for (; $counter[$i] -lt $listLengths[$i]; $counter[$i]++) {
            $hasNewCombination = $false

            $combinations = @(& $_7ddd17460d1743b2b6e683ef649e01b7_groupListItemCombine -Combine $counter -Size $Strength -ErrorAction $ErrorActionPreference)
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
                Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
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
}


$_7ddd17460d1743b2b6e683ef649e01b7_groupListItemPair = {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Pair
    )

    $listLength = & $_7ddd17460d1743b2b6e683ef649e01b7_getListLength -List $Pair -ErrorAction $ErrorActionPreference
    $outputElementType = & $_7ddd17460d1743b2b6e683ef649e01b7_getListElementType -List $Pair -ErrorAction $ErrorActionPreference

    $count = $listLength - 1

    for ($i = 0; $i -lt $count; $i++) {
        #generate pair
        $items = [System.Array]::CreateInstance($outputElementType, 2)
        $items[0] = $Pair[$i]
        $items[1] = $Pair[$i + 1]

        #output pair
        Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
            'Items' = $items
        }
    }
}


$_7ddd17460d1743b2b6e683ef649e01b7_groupListItemPermute = {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Permute,

        [Parameter(Mandatory = $false)]
        [System.Int32]
        $Size
    )

    $listLength = & $_7ddd17460d1743b2b6e683ef649e01b7_getListLength -List $Permute -ErrorAction $ErrorActionPreference
    $outputElementType = & $_7ddd17460d1743b2b6e683ef649e01b7_getListElementType -List $Permute -ErrorAction $ErrorActionPreference

    if (-not $PSBoundParameters.ContainsKey('Size')) {
        $Size = $listLength
    }

    if ($Size -eq 0) {
        Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
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
        Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
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
}


$_7ddd17460d1743b2b6e683ef649e01b7_groupListItemRotateLeft = {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $RotateLeft
    )

    $listLength = & $_7ddd17460d1743b2b6e683ef649e01b7_getListLength -List $RotateLeft -ErrorAction $ErrorActionPreference
    $outputElementType = & $_7ddd17460d1743b2b6e683ef649e01b7_getListElementType -List $RotateLeft -ErrorAction $ErrorActionPreference

    if ($listLength -eq 0) {
        Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
            'Items' = [System.Array]::CreateInstance($outputElementType, 0)
        }
        return
    }

    for ($offset = $listLength; $offset -gt 0; $offset--) {
        #generate group
        $items = [System.Array]::CreateInstance($outputElementType, $listLength)

        $i = $offset % $listLength
        foreach ($srcItem in $RotateLeft) {
            $items[$i] = $srcItem
            $i = ($i + 1) % $listLength
        }

        #output group
        Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
            'Items' = $items
        }
    }
}


$_7ddd17460d1743b2b6e683ef649e01b7_groupListItemRotateRight = {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $RotateRight
    )

    $listLength = & $_7ddd17460d1743b2b6e683ef649e01b7_getListLength -List $RotateRight -ErrorAction $ErrorActionPreference
    $outputElementType = & $_7ddd17460d1743b2b6e683ef649e01b7_getListElementType -List $RotateRight -ErrorAction $ErrorActionPreference

    if ($listLength -eq 0) {
        Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
            'Items' = [System.Array]::CreateInstance($outputElementType, 0)
        }
        return
    }

    for ($offset = 0; $offset -lt $listLength; $offset++) {
        #generate group
        $items = [System.Array]::CreateInstance($outputElementType, $listLength)

        $i = $offset
        foreach ($srcItem in $RotateRight) {
            $items[$i] = $srcItem
            $i = ($i + 1) % $listLength
        }

        #output group
        Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
            'Items' = $items
        }
    }
}


$_7ddd17460d1743b2b6e683ef649e01b7_groupListItemWindow = {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Window,

        [Parameter(Mandatory = $false)]
        [System.Int32]
        $Size
    )

    $listLength = & $_7ddd17460d1743b2b6e683ef649e01b7_getListLength -List $Window -ErrorAction $ErrorActionPreference
    $outputElementType = & $_7ddd17460d1743b2b6e683ef649e01b7_getListElementType -List $Window -ErrorAction $ErrorActionPreference

    if (-not $PSBoundParameters.ContainsKey('Size')) {
        $Size = $listLength
    }

    if ($Size -eq 0) {
        Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
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
        Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
            'Items' = $items
        }
    }
}


$_7ddd17460d1743b2b6e683ef649e01b7_groupListItemZip = {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]
        [AllowEmptyCollection()]
        [ValidateNotNull()]
        [System.Collections.IList[]]
        $Zip
    )

    $listCount = & $_7ddd17460d1743b2b6e683ef649e01b7_getListLength -List $Zip -ErrorAction $ErrorActionPreference

    if ($listCount -lt 1) {
        return
    }

    #Get all the lengths of the list and
    #determine the type to use to constrain the output array.

    $listLengths = [System.Array]::CreateInstance([System.Int32], $listCount)
    $elementTypes = [System.Array]::CreateInstance([System.Type], $listCount)

    for ($i = 0; $i -lt $listCount; $i++) {
        $listLengths[$i] = & $_7ddd17460d1743b2b6e683ef649e01b7_getListLength -List $Zip[$i] -ErrorAction $ErrorActionPreference
        $elementTypes[$i] = & $_7ddd17460d1743b2b6e683ef649e01b7_getListElementType -List $Zip[$i] -ErrorAction $ErrorActionPreference
    }

    $minlistlength = @($listLengths | Microsoft.PowerShell.Utility\Sort-Object)[0]

    if (@($elementTypes | Microsoft.PowerShell.Utility\Sort-Object -Unique).Length -eq 1) {
        $outputElementType = $elementTypes[0]
    }
    else {
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
        Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
            'Items' = $items
        }
    }
}


$_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError = {
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $message,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Exception]
        $innerException,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Object]
        $value
    )

    Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
        (Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Exception' -ArgumentList @($message, $innerException)),
        'AssertionFailed',
        [System.Management.Automation.ErrorCategory]::OperationStopped,
        $value
    )
}


$_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus = {
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.InvocationInfo]
        $invocation,

        [System.Management.Automation.SwitchParameter]
        $fail
    )

    'Assertion {0}: {1}, file {2}, line {3}' -f @(
        $(if ($fail) {'failed'} else {'passed'}),
        $invocation.Line.Trim(),
        $invocation.ScriptName,
        $invocation.ScriptLineNumber
    )
}


$_7ddd17460d1743b2b6e683ef649e01b7_newPipelineArgumentOnlyError = {
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $functionName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $argumentName,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Object]
        $argumentValue
    )

    Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
        (Microsoft.PowerShell.Utility\New-Object -TypeName 'System.ArgumentException' -ArgumentList @(
            "$functionName must take its input from the pipeline.",
            $argumentName
        )),
        'PipelineArgumentOnly',
        [System.Management.Automation.ErrorCategory]::InvalidArgument,
        $argumentValue
    )
}


$_7ddd17460d1743b2b6e683ef649e01b7_newPredicateFailedError = {
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ErrorRecord]
        $errorRecord,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Management.Automation.ScriptBlock]
        $predicate
    )

    Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
        (Microsoft.PowerShell.Utility\New-Object -TypeName 'System.InvalidOperationException' -ArgumentList @('Could not invoke predicate.', $errorRecord.Exception)),
        'PredicateFailed',
        [System.Management.Automation.ErrorCategory]::OperationStopped,
        $predicate
    )
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Assert-All
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Collection,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 1)]
        [System.Management.Automation.ScriptBlock]
        $Predicate
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
    }

    $fail = $true
    if ($Collection -is [System.Collections.ICollection]) {
        $fail = $false

        foreach ($item in $Collection.psbase.GetEnumerator()) {
            $result = $null
            try   {$result = do {& $Predicate $item} while ($false)}
            catch {$PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newPredicateFailedError -errorRecord $_ -predicate $Predicate))}

            if (-not (($result -is [System.Boolean]) -and $result)) {
                $fail = $true
                break
            }
        }
    }

    if ($fail -or ([System.Int32]$VerbosePreference)) {
        $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

        Write-Verbose -Message $message

        if ($fail) {
            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $Collection))
        }
    }
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Assert-Exists
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Collection,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 1)]
        [System.Management.Automation.ScriptBlock]
        $Predicate
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
    }

    $fail = $true
    if ($Collection -is [System.Collections.ICollection]) {
        foreach ($item in $Collection.psbase.GetEnumerator()) {
            $result = $null
            try   {$result = do {& $Predicate $item} while ($false)}
            catch {$PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newPredicateFailedError -errorRecord $_ -predicate $Predicate))}

            if (($result -is [System.Boolean]) -and $result) {
                $fail = $false
                break
            }
        }
    }

    if ($fail -or ([System.Int32]$VerbosePreference)) {
        $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

        Write-Verbose -Message $message

        if ($fail) {
            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $Collection))
        }
    }
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Assert-False
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
    }

    $fail = -not (($Value -is [System.Boolean]) -and (-not $Value))

    if ($fail -or ([System.Int32]$VerbosePreference)) {
        $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

        Write-Verbose -Message $message

        if ($fail) {
            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $Value))
        }
    }
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Assert-NotExists
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Collection,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 1)]
        [System.Management.Automation.ScriptBlock]
        $Predicate
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
    }

    $fail = $true
    if ($Collection -is [System.Collections.ICollection]) {
        $fail = $false

        foreach ($item in $Collection.psbase.GetEnumerator()) {
            $result = $null
            try   {$result = do {& $Predicate $item} while ($false)}
            catch {$PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newPredicateFailedError -errorRecord $_ -predicate $Predicate))}

            if (($result -is [System.Boolean]) -and $result) {
                $fail = $true
                break
            }
        }
    }

    if ($fail -or ([System.Int32]$VerbosePreference)) {
        $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

        Write-Verbose -Message $message

        if ($fail) {
            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $Collection))
        }
    }
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Assert-NotFalse
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
    }

    $fail = ($Value -is [System.Boolean]) -and (-not $Value)

    if ($fail -or ([System.Int32]$VerbosePreference)) {
        $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

        Write-Verbose -Message $message

        if ($fail) {
            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $Value))
        }
    }
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Assert-NotNull
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
    }

    $fail = $null -eq $Value

    if ($fail -or ([System.Int32]$VerbosePreference)) {
        $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

        Write-Verbose -Message $message

        if ($fail) {
            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $Value))
        }
    }
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Assert-NotTrue
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
    }

    $fail = ($Value -is [System.Boolean]) -and $Value

    if ($fail -or ([System.Int32]$VerbosePreference)) {
        $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

        Write-Verbose -Message $message

        if ($fail) {
            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $Value))
        }
    }
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Assert-Null
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
    }

    $fail = $null -ne $Value

    if ($fail -or ([System.Int32]$VerbosePreference)) {
        $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

        Write-Verbose -Message $message

        if ($fail) {
            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $Value))
        }
    }
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Assert-PipelineAll
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowNull()]
        [System.Object]
        $InputObject,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [System.Management.Automation.ScriptBlock]
        $Predicate
    )

    begin
    {
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
        }

        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newPipelineArgumentOnlyError -functionName $PSCmdlet.MyInvocation.MyCommand.Name -argumentName 'InputObject' -argumentValue $InputObject))
        } else {
            #NOTE
            #
            #If StrictMode is on, and the $InputObject pipeline variable has no value (because process block does not run),
            #then using the $InputObject variable in the end block will generate an error.
            #Specifying a default value for $InputObject in the param block does not work.
            #Specifying a default value for $InputObject in the begin block is the least confusing option.
            #Even if the $InputObject pipeline variable is not used in the end block, just set it anyway so StrictMode will definitely work.
            $InputObject = $null
        }
    }

    process
    {
        $result = $null
        try   {$result = do {& $Predicate $InputObject} while ($false)}
        catch {$PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newPredicateFailedError -errorRecord $_ -predicate $Predicate))}

        if (-not (($result -is [System.Boolean]) -and $result)) {
            $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail

            Write-Verbose -Message $message

            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $InputObject))
        }

        ,$InputObject
    }

    end
    {
        if (([System.Int32]$VerbosePreference)) {
            $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation
            Write-Verbose -Message $message
        }
    }
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Assert-PipelineAny
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowNull()]
        [System.Object]
        $InputObject
    )

    begin
    {
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
        }

        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newPipelineArgumentOnlyError -functionName $PSCmdlet.MyInvocation.MyCommand.Name -argumentName 'InputObject' -argumentValue $InputObject))
        } else {
            #NOTE
            #
            #If StrictMode is on, and the $InputObject pipeline variable has no value (because process block does not run),
            #then using the $InputObject variable in the end block will generate an error.
            #Specifying a default value for $InputObject in the param block does not work.
            #Specifying a default value for $InputObject in the begin block is the least confusing option.
            #Even if the $InputObject pipeline variable is not used in the end block, just set it anyway so StrictMode will definitely work.
            $InputObject = $null
        }

        $fail = $true
    }

    process
    {
        $fail = $false
        ,$InputObject
    }

    end
    {
        if ($fail -or ([System.Int32]$VerbosePreference)) {
            $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

            Write-Verbose -Message $message

            if ($fail) {
                if (-not $PSBoundParameters.ContainsKey('Debug')) {
                    $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
                }
                Write-Debug -Message $message
                $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $InputObject))
            }
        }
    }
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Assert-PipelineCount
{
    [CmdletBinding(DefaultParameterSetName = 'Equals')]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowNull()]
        [System.Object]
        $InputObject,

        [Parameter(Mandatory = $true, ParameterSetName = 'Equals', Position = 0)]
        [System.Int64]
        $Equals,

        [Parameter(Mandatory = $true, ParameterSetName = 'Minimum')]
        [System.Int64]
        $Minimum,

        [Parameter(Mandatory = $true, ParameterSetName = 'Maximum')]
        [System.Int64]
        $Maximum
    )

    begin
    {
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
        }

        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newPipelineArgumentOnlyError -functionName $PSCmdlet.MyInvocation.MyCommand.Name -argumentName 'InputObject' -argumentValue $InputObject))
        } else {
            #NOTE
            #
            #If StrictMode is on, and the $InputObject pipeline variable has no value (because process block does not run),
            #then using the $InputObject variable in the end block will generate an error.
            #Specifying a default value for $InputObject in the param block does not work.
            #Specifying a default value for $InputObject in the begin block is the least confusing option.
            #Even if the $InputObject pipeline variable is not used in the end block, just set it anyway so StrictMode will definitely work.
            $InputObject = $null
        }

        #Make sure we can count higher than -Equals, -Minimum, and -Maximum.
        [System.UInt64]$inputCount = 0

        if ($PSCmdlet.ParameterSetName -eq 'Equals') {
            $failEarly  = {$inputCount -gt $Equals}
            $failAssert = {$inputCount -ne $Equals}
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'Maximum') {
            $failEarly  = {$inputCount -gt $Maximum}
            $failAssert = $failEarly
        }
        else {
            $failEarly  = {$false}
            $failAssert = {$inputCount -lt $Minimum}
        }
    }

    process
    {
        $inputCount++

        if ((& $failEarly)) {
            #fail immediately
            #do not wait for all pipeline objects

            $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail

            Write-Verbose -Message $message

            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $InputObject))
        }

        ,$InputObject
    }

    end
    {
        $fail = & $failAssert

        if ($fail -or ([System.Int32]$VerbosePreference)) {
            $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

            Write-Verbose -Message $message

            if ($fail) {
                if (-not $PSBoundParameters.ContainsKey('Debug')) {
                    $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
                }
                Write-Debug -Message $message
                $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $InputObject))
            }
        }
    }
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Assert-PipelineEmpty
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowNull()]
        [System.Object]
        $InputObject
    )

    begin
    {
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
        }

        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newPipelineArgumentOnlyError -functionName $PSCmdlet.MyInvocation.MyCommand.Name -argumentName 'InputObject' -argumentValue $InputObject))
        } else {
            #NOTE
            #
            #If StrictMode is on, and the $InputObject pipeline variable has no value (because process block does not run),
            #then using the $InputObject variable in the end block will generate an error.
            #Specifying a default value for $InputObject in the param block does not work.
            #Specifying a default value for $InputObject in the begin block is the least confusing option.
            #Even if the $InputObject pipeline variable is not used in the end block, just set it anyway so StrictMode will definitely work.
            $InputObject = $null
        }
    }

    process
    {
        #fail immediately
        #do not wait for all pipeline objects

        $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail

        Write-Verbose -Message $message

        if (-not $PSBoundParameters.ContainsKey('Debug')) {
            $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
        }
        Write-Debug -Message $message
        $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $InputObject))
    }

    end
    {
        if (([System.Int32]$VerbosePreference)) {
            $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation
            Write-Verbose -Message $message
        }
    }
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Assert-PipelineExists
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowNull()]
        [System.Object]
        $InputObject,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [System.Management.Automation.ScriptBlock]
        $Predicate
    )

    begin
    {
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
        }

        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newPipelineArgumentOnlyError -functionName $PSCmdlet.MyInvocation.MyCommand.Name -argumentName 'InputObject' -argumentValue $InputObject))
        } else {
            #NOTE
            #
            #If StrictMode is on, and the $InputObject pipeline variable has no value (because process block does not run),
            #then using the $InputObject variable in the end block will generate an error.
            #Specifying a default value for $InputObject in the param block does not work.
            #Specifying a default value for $InputObject in the begin block is the least confusing option.
            #Even if the $InputObject pipeline variable is not used in the end block, just set it anyway so StrictMode will definitely work.
            $InputObject = $null
        }

        $fail = $true
    }

    process
    {
        if ($fail) {
            $result = $null
            try   {$result = do {& $Predicate $InputObject} while ($false)}
            catch {$PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newPredicateFailedError -errorRecord $_ -predicate $Predicate))}

            if (($result -is [System.Boolean]) -and $result) {
                $fail = $false
            }
        }
        ,$InputObject
    }

    end
    {
        if ($fail -or ([System.Int32]$VerbosePreference)) {
            $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

            Write-Verbose -Message $message

            if ($fail) {
                if (-not $PSBoundParameters.ContainsKey('Debug')) {
                    $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
                }
                Write-Debug -Message $message
                $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $null))
            }
        }
    }
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Assert-PipelineNotExists
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowNull()]
        [System.Object]
        $InputObject,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [System.Management.Automation.ScriptBlock]
        $Predicate
    )

    begin
    {
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
        }

        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newPipelineArgumentOnlyError -functionName $PSCmdlet.MyInvocation.MyCommand.Name -argumentName 'InputObject' -argumentValue $InputObject))
        } else {
            #NOTE
            #
            #If StrictMode is on, and the $InputObject pipeline variable has no value (because process block does not run),
            #then using the $InputObject variable in the end block will generate an error.
            #Specifying a default value for $InputObject in the param block does not work.
            #Specifying a default value for $InputObject in the begin block is the least confusing option.
            #Even if the $InputObject pipeline variable is not used in the end block, just set it anyway so StrictMode will definitely work.
            $InputObject = $null
        }
    }

    process
    {
        $result = $null
        try   {$result = do {& $Predicate $InputObject} while ($false)}
        catch {$PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newPredicateFailedError -errorRecord $_ -predicate $Predicate))}

        if (($result -is [System.Boolean]) -and $result) {
            $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail

            Write-Verbose -Message $message

            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $InputObject))
        }

        ,$InputObject
    }

    end
    {
        if (([System.Int32]$VerbosePreference)) {
            $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation
            Write-Verbose -Message $message
        }
    }
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Assert-PipelineSingle
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowNull()]
        [System.Object]
        $InputObject
    )

    begin
    {
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
        }

        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newPipelineArgumentOnlyError -functionName $PSCmdlet.MyInvocation.MyCommand.Name -argumentName 'InputObject' -argumentValue $InputObject))
        } else {
            #NOTE
            #
            #If StrictMode is on, and the $InputObject pipeline variable has no value (because process block does not run),
            #then using the $InputObject variable in the end block will generate an error.
            #Specifying a default value for $InputObject in the param block does not work.
            #Specifying a default value for $InputObject in the begin block is the least confusing option.
            #Even if the $InputObject pipeline variable is not used in the end block, just set it anyway so StrictMode will definitely work.
            $InputObject = $null
        }

        $anyItems = $false
    }

    process
    {
        if ($anyItems) {
            #fail immediately
            #do not wait for all pipeline objects

            $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail

            Write-Verbose -Message $message

            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $InputObject))
        }

        $anyItems = $true
        ,$InputObject
    }

    end
    {
        $fail = -not $anyItems

        if ($fail -or ([System.Int32]$VerbosePreference)) {
            $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

            Write-Verbose -Message $message

            if ($fail) {
                if (-not $PSBoundParameters.ContainsKey('Debug')) {
                    $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
                }
                Write-Debug -Message $message
                $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $InputObject))
            }
        }
    }
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Assert-True
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
    }

    $fail = -not (($Value -is [System.Boolean]) -and $Value)

    if ($fail -or ([System.Int32]$VerbosePreference)) {
        $message = & $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

        Write-Verbose -Message $message

        if ($fail) {
            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $Value))
        }
    }
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Group-ListItem
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'Pair')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Pair,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'Window')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Window,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'RotateLeft')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $RotateLeft,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'RotateRight')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $RotateRight,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'Combine')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Combine,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'Permute')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Permute,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'CartesianProduct')]
        [AllowEmptyCollection()]
        [ValidateNotNull()]
        [System.Collections.IList[]]
        $CartesianProduct,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'CoveringArray')]
        [AllowEmptyCollection()]
        [ValidateNotNull()]
        [System.Collections.IList[]]
        $CoveringArray,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'Zip')]
        [AllowEmptyCollection()]
        [ValidateNotNull()]
        [System.Collections.IList[]]
        $Zip,

        [Parameter(Mandatory = $false, ValueFromPipeline = $false, ParameterSetName = 'Combine')]
        [Parameter(Mandatory = $false, ValueFromPipeline = $false, ParameterSetName = 'Permute')]
        [Parameter(Mandatory = $false, ValueFromPipeline = $false, ParameterSetName = 'Window')]
        [System.Int32]
        $Size,

        [Parameter(Mandatory = $false, ValueFromPipeline = $false, ParameterSetName = 'CoveringArray')]
        [System.Int32]
        $Strength
    )

    #NOTE about [ValidateNotNull()]
    #
    #The ValidateNotNull() attribute validates that a list and its contents are not $null.
    #The -RotateLeft, -RotateRight, -Combine, -Permute, -Pair, and -Window parameters
    #NOT having this attribute
    #and -CartesianProduct, -CoveringArray and -Zip having this attribute, is intentional.
    #
    #Mandatory = $true will make sure -Combine, -Permute, -Pair, and -Window are not $null.

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    $PSBoundParameters['ErrorAction'] = $ErrorActionPreference

    switch ($PSCmdlet.ParameterSetName) {
        'RotateLeft' {
            & $_7ddd17460d1743b2b6e683ef649e01b7_groupListItemRotateLeft @PSBoundParameters
            return
        }
        'RotateRight' {
            & $_7ddd17460d1743b2b6e683ef649e01b7_groupListItemRotateRight @PSBoundParameters
            return
        }
        'Pair' {
            & $_7ddd17460d1743b2b6e683ef649e01b7_groupListItemPair @PSBoundParameters
            return
        }
        'Window' {
            & $_7ddd17460d1743b2b6e683ef649e01b7_groupListItemWindow @PSBoundParameters
            return
        }
        'Combine' {
            & $_7ddd17460d1743b2b6e683ef649e01b7_groupListItemCombine @PSBoundParameters
            return
        }
        'Permute' {
            & $_7ddd17460d1743b2b6e683ef649e01b7_groupListItemPermute @PSBoundParameters
            return
        }
        'CartesianProduct' {
            & $_7ddd17460d1743b2b6e683ef649e01b7_groupListItemCartesianProduct @PSBoundParameters
            return
        }
        'Zip' {
            & $_7ddd17460d1743b2b6e683ef649e01b7_groupListItemZip @PSBoundParameters
            return
        }
        'CoveringArray' {
            & $_7ddd17460d1743b2b6e683ef649e01b7_groupListItemCoveringArray @PSBoundParameters
            return
        }
        default {
            $errorRecord = Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                (Microsoft.PowerShell.Utility\New-Object -TypeName 'System.NotImplementedException' -ArgumentList @("The ParameterSetName '$_' was not implemented.")),
                'NotImplemented',
                [System.Management.Automation.ErrorCategory]::NotImplemented,
                $null
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Test-All
{
    [CmdletBinding()]
    [OutputType([System.Boolean], [System.Object])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Collection,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 1)]
        [System.Management.Automation.ScriptBlock]
        $Predicate
    )

    #Do not use the return keyword to return the value
    #because PowerShell 2 will not properly set -OutVariable.

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    if ($Collection -is [System.Collections.ICollection]) {
        foreach ($item in $Collection.psbase.GetEnumerator()) {
            $result = $null
            try   {$result = do {& $Predicate $item} while ($false)}
            catch {$PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newPredicateFailedError -errorRecord $_ -predicate $Predicate))}

            if (-not (($result -is [System.Boolean]) -and $result)) {
                $false
                return
            }
        }
        $true
        return
    }

    $null
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Test-DateTime
{
    [CmdletBinding(DefaultParameterSetName = 'IsDateTime')]
    [OutputType([System.Boolean], [System.Object])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Value,

        [Parameter(Mandatory = $false, ParameterSetName = 'IsDateTime')]
        [System.Management.Automation.SwitchParameter]
        $IsDateTime,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpEquals')]
        [AllowNull()]
        [Alias('eq')]
        [System.Object]
        $Equals,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpNotEquals')]
        [AllowNull()]
        [Alias('ne')]
        [System.Object]
        $NotEquals,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpLessThan')]
        [AllowNull()]
        [Alias('lt')]
        [System.Object]
        $LessThan,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpLessThanOrEqualTo')]
        [AllowNull()]
        [Alias('le')]
        [System.Object]
        $LessThanOrEqualTo,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpGreaterThan')]
        [AllowNull()]
        [Alias('gt')]
        [System.Object]
        $GreaterThan,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [Alias('ge')]
        [System.Object]
        $GreaterThanOrEqualTo,

        [Parameter(Mandatory = $false, ParameterSetName = 'OpEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThanOrEqualTo')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $MatchKind,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.DateTimeKind[]]
        $Kind,

        [Parameter(Mandatory = $false, ParameterSetName = 'OpEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThanOrEqualTo')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.String[]]
        $Property
    )

    $hasKindConstraints = $PSBoundParameters.ContainsKey('Kind')
    $hasPropertyConstraints = $PSBoundParameters.ContainsKey('Property')

    if ($hasKindConstraints -and ($null -eq $Kind)) {
        $Kind = [System.DateTimeKind[]]@()
    }
    if ($hasPropertyConstraints -and ($null -eq $Property)) {
        $Property = [System.String[]]@()
    }
    if ($hasPropertyConstraints -and ($Property.Length -gt 0)) {
        $validProperties = [System.String[]]@(
            'Year', 'Month', 'Day', 'Hour', 'Minute', 'Second', 'Millisecond',
            'Date', 'TimeOfDay', 'DayOfWeek', 'DayOfYear', 'Ticks', 'Kind'
        )

        foreach ($item in $Property) {
            if (($validProperties -notcontains $item) -or ($item -notmatch '^[a-zA-Z]+$')) {
                throw Microsoft.PowerShell.Utility\New-Object -TypeName 'System.ArgumentException' -ArgumentList @(
                    "Invalid DateTime Property: $item.`r`n" +
                    "Use one of the following values: $($validProperties -join ', ')"
                )
            }
        }
    }

    function isDateTime($a)
    {
        $isDateTime = $a -is [System.DateTime]
        if ($hasKindConstraints) {
            $isDateTime = $isDateTime -and ($Kind -contains $a.Kind)
        }
        return $isDateTime
    }

    function compareDateTime($a, $b)
    {
        $canCompare = (isDateTime $a) -and (isDateTime $b)
        if ($MatchKind) {
            $canCompare = $canCompare -and ($a.Kind -eq $b.Kind)
        }
        if ($hasPropertyConstraints) {
            $canCompare = $canCompare -and ($Property.Length -gt 0)
        }

        if (-not $canCompare) {
            return $null
        }

        if (-not $hasPropertyConstraints) {
            return [System.DateTime]::Compare($a, $b)
        }

        $result = [System.Int32]0
        foreach ($item in $Property) {
            $result = $a.psbase.$item.CompareTo($b.psbase.$item)
            if ($result -ne 0) {
                break
            }
        }
        return $result
    }

    #Do not use the return keyword to return the value
    #because PowerShell 2 will not properly set -OutVariable.

    switch ($PSCmdlet.ParameterSetName) {
        'IsDateTime' {
            $result = isDateTime $Value
            if ($PSBoundParameters.ContainsKey('IsDateTime')) {
                ($result) -xor (-not $IsDateTime)
                return
            }
            $result
            return
        }
        'OpEquals' {
            $result = compareDateTime $Value $Equals
            if ($result -is [System.Int32]) {
                ($result -eq 0)
                return
            }
            $null
            return
        }
        'OpNotEquals' {
            $result = compareDateTime $Value $NotEquals
            if ($result -is [System.Int32]) {
                ($result -ne 0)
                return
            }
            $null
            return
        }
        'OpLessThan' {
            $result = compareDateTime $Value $LessThan
            if ($result -is [System.Int32]) {
                ($result -lt 0)
                return
            }
            $null
            return
        }
        'OpLessThanOrEqualTo' {
            $result = compareDateTime $Value $LessThanOrEqualTo
            if ($result -is [System.Int32]) {
                ($result -le 0)
                return
            }
            $null
            return
        }
        'OpGreaterThan' {
            $result = compareDateTime $Value $GreaterThan
            if ($result -is [System.Int32]) {
                ($result -gt 0)
                return
            }
            $null
            return
        }
        'OpGreaterThanOrEqualTo' {
            $result = compareDateTime $Value $GreaterThanOrEqualTo
            if ($result -is [System.Int32]) {
                ($result -ge 0)
                return
            }
            $null
            return
        }
        default {
            throw Microsoft.PowerShell.Utility\New-Object -TypeName 'System.NotImplementedException' -ArgumentList @(
                "The ParameterSetName '$_' was not implemented."
            )
        }
    }
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Test-Exists
{
    [CmdletBinding()]
    [OutputType([System.Boolean], [System.Object])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Collection,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 1)]
        [System.Management.Automation.ScriptBlock]
        $Predicate
    )

    #Do not use the return keyword to return the value
    #because PowerShell 2 will not properly set -OutVariable.

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    if ($Collection -is [System.Collections.ICollection]) {
        foreach ($item in $Collection.psbase.GetEnumerator()) {
            $result = $null
            try   {$result = do {& $Predicate $item} while ($false)}
            catch {$PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newPredicateFailedError -errorRecord $_ -predicate $Predicate))}

            if (($result -is [System.Boolean]) -and $result) {
                $true
                return
            }
        }
        $false
        return
    }

    $null
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Test-False
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    #Do not use the return keyword to return the value
    #because PowerShell 2 will not properly set -OutVariable.

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    ($Value -is [System.Boolean]) -and (-not $Value)
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Test-Guid
{
    [CmdletBinding(DefaultParameterSetName = 'IsGuid')]
    [OutputType([System.Boolean], [System.Object])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Value,

        [Parameter(Mandatory = $false, ParameterSetName = 'IsGuid')]
        [System.Management.Automation.SwitchParameter]
        $IsGuid,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpEquals')]
        [AllowNull()]
        [Alias('eq')]
        [System.Object]
        $Equals,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpNotEquals')]
        [AllowNull()]
        [Alias('ne')]
        [System.Object]
        $NotEquals,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpLessThan')]
        [AllowNull()]
        [Alias('lt')]
        [System.Object]
        $LessThan,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpLessThanOrEqualTo')]
        [AllowNull()]
        [Alias('le')]
        [System.Object]
        $LessThanOrEqualTo,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpGreaterThan')]
        [AllowNull()]
        [Alias('gt')]
        [System.Object]
        $GreaterThan,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [Alias('ge')]
        [System.Object]
        $GreaterThanOrEqualTo,

        [Parameter(Mandatory = $false, ParameterSetName = 'OpEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThanOrEqualTo')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $MatchVariant,

        [Parameter(Mandatory = $false, ParameterSetName = 'OpEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThanOrEqualTo')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $MatchVersion,

        [Parameter(Mandatory = $false, ParameterSetName = 'IsGuid')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThanOrEqualTo')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.String[]]
        $Variant,

        [Parameter(Mandatory = $false, ParameterSetName = 'IsGuid')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThanOrEqualTo')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Int32[]]
        $Version
    )

    $hasVersionConstraints = $PSBoundParameters.ContainsKey('Version')
    $hasVariantConstraints = $PSBoundParameters.ContainsKey('Variant')

    if ($hasVersionConstraints) {
        $versionConstraints = ''

        if (($null -ne $Version) -and ($Version.Length -gt 0)) {
            $intToHex = '0123456789ABCDEF'

            foreach ($item in $Version) {
                if (($item -lt 0) -or ($item -gt 15)) {
                    throw Microsoft.PowerShell.Utility\New-Object -TypeName 'System.ArgumentException' -ArgumentList @(
                        'Version',
                        'The GUID version field can only contain integers between 0 and 15.'
                    )
                }
                $versionConstraints += $intToHex[$item]
            }
        }
    }

    if ($hasVariantConstraints) {
        $variantConstraints = ''

        if (($null -ne $Variant) -and ($Variant.Length -gt 0)) {
            foreach ($item in $Variant) {
                switch ($item) {
                    'Standard'  {$variantConstraints += '89AB'; break;}
                    'Microsoft' {$variantConstraints += 'CD'; break;}
                    'NCS'       {$variantConstraints += '01234567'; break;}
                    'Reserved'  {$variantConstraints += 'EF'; break;}
                    default     {
                        throw Microsoft.PowerShell.Utility\New-Object -TypeName 'System.ArgumentException' -ArgumentList @(
                            "Invalid GUID variant: $item.`r`n" +
                            "Use one of the following values: Standard, Microsoft, NCS, Reserved"
                        )
                    }
                }
            }
        }
    }

    function isGuid($a)
    {
        $isGuid = $a -is [System.Guid]
        if ($isGuid) {
            $guidString = $a.psbase.ToString('D')
            $iOrdinal = [System.Stringcomparison]::OrdinalIgnoreCase

            if ($hasVersionConstraints) {
                $versionString = $guidString.Substring(14, 1)
                $isGuid = $versionConstraints.IndexOf($versionString, $iOrdinal) -ge 0
            }
            if ($isGuid -and $hasVariantConstraints) {
                $variantString = $guidString.Substring(19, 1)
                $isGuid = $variantConstraints.IndexOf($variantString, $iOrdinal) -ge 0
            }
        }
        return $isGuid
    }

    function compareGuid($a, $b)
    {
        $canCompare = (isGuid $a) -and (isGuid $b)
        if ($canCompare) {
            $aString = $a.psbase.ToString('D')
            $bString = $b.psbase.ToString('D')
            $iOrdinal = [System.StringComparison]::OrdinalIgnoreCase

            if ($MatchVersion) {
                $aVersion = $aString.SubString(14, 1)
                $bVersion = $bString.SubString(14, 1)

                $canCompare = [System.String]::Equals($aVersion, $bVersion, $iOrdinal)
            }
            if ($canCompare -and $MatchVariant) {
                $aVariant = $aString.SubString(19, 1)
                $bVariant = $bString.SubString(19, 1)

                $canCompare = $false
                foreach ($item in @('89AB', 'CD', '01234567', 'EF')) {
                    if ($item.IndexOf($aVariant, $iOrdinal) -ge 0) {
                        $canCompare = $item.IndexOf($bVariant, $iOrdinal) -ge 0
                        break
                    }
                }
            }
        }

        if ($canCompare) {
            return $a.psbase.CompareTo($b)
        }
        return $null
    }

    #Do not use the return keyword to return the value
    #because PowerShell 2 will not properly set -OutVariable.

    switch ($PSCmdlet.ParameterSetName) {
        'IsGuid' {
            $result = isGuid $Value
            if ($PSBoundParameters.ContainsKey('IsGuid')) {
                ($result) -xor (-not $IsGuid)
                return
            }
            $result
            return
        }
        'OpEquals' {
            $result = compareGuid $Value $Equals
            if ($result -is [System.Int32]) {
                ($result -eq 0)
                return
            }
            $null
            return
        }
        'OpNotEquals' {
            $result = compareGuid $Value $NotEquals
            if ($result -is [System.Int32]) {
                ($result -ne 0)
                return
            }
            $null
            return
        }
        'OpLessThan' {
            $result = compareGuid $Value $LessThan
            if ($result -is [System.Int32]) {
                ($result -lt 0)
                return
            }
            $null
            return
        }
        'OpLessThanOrEqualTo' {
            $result = compareGuid $Value $LessThanOrEqualTo
            if ($result -is [System.Int32]) {
                ($result -le 0)
                return
            }
            $null
            return
        }
        'OpGreaterThan' {
            $result = compareGuid $Value $GreaterThan
            if ($result -is [System.Int32]) {
                ($result -gt 0)
                return
            }
            $null
            return
        }
        'OpGreaterThanOrEqualTo' {
            $result = compareGuid $Value $GreaterThanOrEqualTo
            if ($result -is [System.Int32]) {
                ($result -ge 0)
                return
            }
            $null
            return
        }
        default {
            throw Microsoft.PowerShell.Utility\New-Object -TypeName 'System.NotImplementedException' -ArgumentList @(
                "The ParameterSetName '$_' was not implemented."
            )
        }
    }
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Test-NotExists
{
    [CmdletBinding()]
    [OutputType([System.Boolean], [System.Object])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Collection,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 1)]
        [System.Management.Automation.ScriptBlock]
        $Predicate
    )

    #Do not use the return keyword to return the value
    #because PowerShell 2 will not properly set -OutVariable.

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    if ($Collection -is [System.Collections.ICollection]) {
        foreach ($item in $Collection.psbase.GetEnumerator()) {
            $result = $null
            try   {$result = do {& $Predicate $item} while ($false)}
            catch {$PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newPredicateFailedError -errorRecord $_ -predicate $Predicate))}

            if (($result -is [System.Boolean]) -and $result) {
                $false
                return
            }
        }
        $true
        return
    }

    $null
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Test-NotFalse
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    #Do not use the return keyword to return the value
    #because PowerShell 2 will not properly set -OutVariable.

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    ($Value -isnot [System.Boolean]) -or $Value
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Test-NotNull
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    #Do not use the return keyword to return the value
    #because PowerShell 2 will not properly set -OutVariable.

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    $null -ne $Value
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Test-NotTrue
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    #Do not use the return keyword to return the value
    #because PowerShell 2 will not properly set -OutVariable.

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    ($Value -isnot [System.Boolean]) -or (-not $Value)
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Test-Null
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    #Do not use the return keyword to return the value
    #because PowerShell 2 will not properly set -OutVariable.

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    $null -eq $Value
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Test-Number
{
    [CmdletBinding(DefaultParameterSetName = 'IsNumber')]
    [OutputType([System.Boolean], [System.Object])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Value,

        [Parameter(Mandatory = $false, ParameterSetName = 'IsNumber')]
        [System.Management.Automation.SwitchParameter]
        $IsNumber,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpEquals')]
        [AllowNull()]
        [Alias('eq')]
        [System.Object]
        $Equals,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpNotEquals')]
        [AllowNull()]
        [Alias('ne')]
        [System.Object]
        $NotEquals,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpLessThan')]
        [AllowNull()]
        [Alias('lt')]
        [System.Object]
        $LessThan,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpLessThanOrEqualTo')]
        [AllowNull()]
        [Alias('le')]
        [System.Object]
        $LessThanOrEqualTo,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpGreaterThan')]
        [AllowNull()]
        [Alias('gt')]
        [System.Object]
        $GreaterThan,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [Alias('ge')]
        [System.Object]
        $GreaterThanOrEqualTo,

        [Parameter(Mandatory = $false, ParameterSetName = 'OpEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThanOrEqualTo')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $MatchType,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.String[]]
        $Type
    )

    $allowedTypes = [System.String[]]@(
        'System.Byte', 'System.SByte',
        'System.Int16', 'System.Int32', 'System.Int64',
        'System.UInt16', 'System.UInt32', 'System.UInt64',
        'System.Single', 'System.Double', 'System.Decimal','System.Numerics.BigInteger'
    )
    if ($PSBoundParameters.ContainsKey('Type')) {
        if ($null -eq $Type) {
            $allowedTypes = [System.String[]]@()
        }
        else {
            $allowedTypes = [System.String[]]@(
                $allowedTypes |
                    Microsoft.PowerShell.Core\Where-Object -FilterScript {($Type -icontains $_) -or ($Type -icontains $_.Split('.')[-1])}
            )
        }
    }

    function isNumber($n)
    {
        if ($null -eq $n) {
            return $false
        }

        $nType = (& $_7ddd17460d1743b2b6e683ef649e01b7_getType $n).FullName
        if ($nType -eq 'System.Double') {
            if (([System.Double]::IsNaN($n)) -or ([System.Double]::IsInfinity($n))) {
                return $false
            }
        }
        if ($nType -eq 'System.Single') {
            if (([System.Single]::IsNaN($n)) -or ([System.Single]::IsInfinity($n))) {
                return $false
            }
        }
        return ($allowedTypes -icontains $nType)
    }

    function canCompareNumbers($x, $y)
    {
        $areNumbers = (isNumber $x) -and (isNumber $y)
        if ($MatchType) {
            return $areNumbers -and ((& $_7ddd17460d1743b2b6e683ef649e01b7_getType $x) -eq (& $_7ddd17460d1743b2b6e683ef649e01b7_getType $y))
        }
        return $areNumbers
    }

    #Do not use the return keyword to return the value
    #because PowerShell 2 will not properly set -OutVariable.

    switch ($PSCmdlet.ParameterSetName) {
        'IsNumber' {
            $result = isNumber $Value
            if ($PSBoundParameters.ContainsKey('IsNumber')) {
                ($result) -xor (-not $IsNumber)
                return
            }
            $result
            return
        }
        'OpEquals' {
            if ((canCompareNumbers $Value $Equals)) {
                ($Value -eq $Equals)
                return
            }
            $null
            return
        }
        'OpNotEquals' {
            if ((canCompareNumbers $Value $NotEquals)) {
                ($Value -ne $NotEquals)
                return
            }
            $null
            return
        }
        'OpLessThan' {
            if ((canCompareNumbers $Value $LessThan)) {
                ($Value -lt $LessThan)
                return
            }
            $null
            return
        }
        'OpLessThanOrEqualTo' {
            if ((canCompareNumbers $Value $LessThanOrEqualTo)) {
                ($Value -le $LessThanOrEqualTo)
                return
            }
            $null
            return
        }
        'OpGreaterThan' {
            if ((canCompareNumbers $Value $GreaterThan)) {
                ($Value -gt $GreaterThan)
                return
            }
            $null
            return
        }
        'OpGreaterThanOrEqualTo' {
            if ((canCompareNumbers $Value $GreaterThanOrEqualTo)) {
                ($Value -ge $GreaterThanOrEqualTo)
                return
            }
            $null
            return
        }
        default {
            throw Microsoft.PowerShell.Utility\New-Object -TypeName 'System.NotImplementedException' -ArgumentList @(
                "The ParameterSetName '$_' was not implemented."
            )
        }
    }
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Test-String
{
    [CmdletBinding(DefaultParameterSetName = 'IsString')]
    [OutputType([System.Boolean], [System.Object])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Value,

        [Parameter(Mandatory = $false, ParameterSetName = 'IsString')]
        [System.Management.Automation.SwitchParameter]
        $IsString,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpContains')]
        [AllowNull()]
        [System.Object]
        $Contains,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpNotContains')]
        [AllowNull()]
        [System.Object]
        $NotContains,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpStartsWith')]
        [AllowNull()]
        [System.Object]
        $StartsWith,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpNotStartsWith')]
        [AllowNull()]
        [System.Object]
        $NotStartsWith,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpEndsWith')]
        [AllowNull()]
        [System.Object]
        $EndsWith,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpNotEndsWith')]
        [AllowNull()]
        [System.Object]
        $NotEndsWith,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpEquals')]
        [AllowNull()]
        [Alias('eq')]
        [System.Object]
        $Equals,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpNotEquals')]
        [AllowNull()]
        [Alias('ne')]
        [System.Object]
        $NotEquals,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpLessThan')]
        [AllowNull()]
        [Alias('lt')]
        [System.Object]
        $LessThan,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpLessThanOrEqualTo')]
        [AllowNull()]
        [Alias('le')]
        [System.Object]
        $LessThanOrEqualTo,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpGreaterThan')]
        [AllowNull()]
        [Alias('gt')]
        [System.Object]
        $GreaterThan,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [Alias('ge')]
        [System.Object]
        $GreaterThanOrEqualTo,

        [Parameter(Mandatory = $false, ParameterSetName = 'OpContains')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotContains')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpEndsWith')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotEndsWith')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpStartsWith')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotStartsWith')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThanOrEqualTo')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $CaseSensitive,

        [Parameter(Mandatory = $false, ParameterSetName = 'OpContains')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotContains')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpStartsWith')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotStartsWith')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpEndsWith')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotEndsWith')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThanOrEqualTo')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $FormCompatible,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Text.NormalizationForm[]]
        $Normalization
    )

    if ($CaseSensitive) {
        $comparisonType = [System.StringComparison]::Ordinal
    }
    else {
        $comparisonType = [System.StringComparison]::OrdinalIgnoreCase
    }

    $hasNormalizationConstraints = $PSBoundParameters.ContainsKey('Normalization')

    if (-not $hasNormalizationConstraints) {
        $allowedNormalizations = [System.Text.NormalizationForm[]]@(
            [System.Enum]::GetValues([System.Text.NormalizationForm])
        )
    }
    elseif (($null -eq $Normalization) -or ($Normalization.Length -eq 0)) {
        $allowedNormalizations = [System.Text.NormalizationForm[]]@()
    }
    else {
        $allowedNormalizations = [System.Text.NormalizationForm[]]@(
            [System.Enum]::GetValues([System.Text.NormalizationForm]) |
                Microsoft.PowerShell.Core\Where-Object -FilterScript {$Normalization -contains $_}
        )
    }

    function isString($str)
    {
        $isStringType = $str -is [System.String]

        if ($isStringType -and $hasNormalizationConstraints) {
            foreach ($item in $allowedNormalizations) {
                if ($str.IsNormalized($item)) {
                    return $true
                }
            }
            return $false
        }

        return $isStringType
    }

    function canCompareStrings($strA, $strB)
    {
        $areStrings = ((isString $strA) -and (isString $strB))
        if ($areStrings -and $FormCompatible) {
            foreach ($item in $allowedNormalizations) {
                if ($strA.IsNormalized($item) -and $strB.IsNormalized($item)) {
                    return $true
                }
            }
            return $false
        }
        return $areStrings
    }

    #Do not use the return keyword to return the value
    #because PowerShell 2 will not properly set -OutVariable.

    switch ($PSCmdlet.ParameterSetName) {
        'IsString' {
            $result = isString $Value
            if ($PSBoundParameters.ContainsKey('IsString')) {
                ($result) -xor (-not $IsString)
                return
            }
            $result
            return
        }
        'OpContains' {
            if ((canCompareStrings $Value $Contains)) {
                ($Value.IndexOf($Contains, $comparisonType) -ge 0)
                return
            }
            $null
            return
        }
        'OpNotContains' {
            if ((canCompareStrings $Value $NotContains)) {
                ($Value.IndexOf($NotContains, $comparisonType) -lt 0)
                return
            }
            $null
            return
        }
        'OpStartsWith' {
            if ((canCompareStrings $Value $StartsWith)) {
                ($Value.StartsWith($StartsWith, $comparisonType))
                return
            }
            $null
            return
        }
        'OpNotStartsWith' {
            if ((canCompareStrings $Value $NotStartsWith)) {
                (-not $Value.StartsWith($NotStartsWith, $comparisonType))
                return
            }
            $null
            return
        }
        'OpEndsWith' {
            if ((canCompareStrings $Value $EndsWith)) {
                ($Value.EndsWith($EndsWith, $comparisonType))
                return
            }
            $null
            return
        }
        'OpNotEndsWith' {
            if ((canCompareStrings $Value $NotEndsWith)) {
                (-not $Value.EndsWith($NotEndsWith, $comparisonType))
                return
            }
            $null
            return
        }
        'OpEquals' {
            if ((canCompareStrings $Value $Equals)) {
                ([System.String]::Equals($Value, $Equals, $comparisonType))
                return
            }
            $null
            return
        }
        'OpNotEquals' {
            if ((canCompareStrings $Value $NotEquals)) {
                (-not [System.String]::Equals($Value, $NotEquals, $comparisonType))
                return
            }
            $null
            return
        }
        'OpLessThan' {
            if ((canCompareStrings $Value $LessThan)) {
                ([System.String]::Compare($Value, $LessThan, $comparisonType) -lt 0)
                return
            }
            $null
            return
        }
        'OpLessThanOrEqualTo' {
            if ((canCompareStrings $Value $LessThanOrEqualTo)) {
                ([System.String]::Compare($Value, $LessThanOrEqualTo, $comparisonType) -le 0)
                return
            }
            $null
            return
        }
        'OpGreaterThan' {
            if ((canCompareStrings $Value $GreaterThan)) {
                ([System.String]::Compare($Value, $GreaterThan, $comparisonType) -gt 0)
                return
            }
            $null
            return
        }
        'OpGreaterThanOrEqualTo' {
            if ((canCompareStrings $Value $GreaterThanOrEqualTo)) {
                ([System.String]::Compare($Value, $GreaterThanOrEqualTo, $comparisonType) -ge 0)
                return
            }
            $null
            return
        }
        default {
            throw Microsoft.PowerShell.Utility\New-Object -TypeName 'System.NotImplementedException' -ArgumentList @(
                "The ParameterSetName '$_' was not implemented."
            )
        }
    }
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Test-Text
{
    [CmdletBinding(DefaultParameterSetName = 'IsText')]
    [OutputType([System.Boolean], [System.Object])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Value,

        [Parameter(Mandatory = $false, ParameterSetName = 'IsText')]
        [System.Management.Automation.SwitchParameter]
        $IsText,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpMatch')]
        [AllowNull()]
        [System.Object]
        $Match,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpNotMatch')]
        [AllowNull()]
        [System.Object]
        $NotMatch,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpContains')]
        [AllowNull()]
        [System.Object]
        $Contains,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpNotContains')]
        [AllowNull()]
        [System.Object]
        $NotContains,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpStartsWith')]
        [AllowNull()]
        [System.Object]
        $StartsWith,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpNotStartsWith')]
        [AllowNull()]
        [System.Object]
        $NotStartsWith,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpEndsWith')]
        [AllowNull()]
        [System.Object]
        $EndsWith,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpNotEndsWith')]
        [AllowNull()]
        [System.Object]
        $NotEndsWith,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpEquals')]
        [AllowNull()]
        [Alias('eq')]
        [System.Object]
        $Equals,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpNotEquals')]
        [AllowNull()]
        [Alias('ne')]
        [System.Object]
        $NotEquals,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpLessThan')]
        [AllowNull()]
        [Alias('lt')]
        [System.Object]
        $LessThan,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpLessThanOrEqualTo')]
        [AllowNull()]
        [Alias('le')]
        [System.Object]
        $LessThanOrEqualTo,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpGreaterThan')]
        [AllowNull()]
        [Alias('gt')]
        [System.Object]
        $GreaterThan,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [Alias('ge')]
        [System.Object]
        $GreaterThanOrEqualTo,

        [Parameter(Mandatory = $false, ParameterSetName = 'OpMatch')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotMatch')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpContains')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotContains')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpEndsWith')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotEndsWith')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpStartsWith')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotStartsWith')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThanOrEqualTo')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $CaseSensitive,

        [Parameter(Mandatory = $false, ParameterSetName = 'OpMatch')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotMatch')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpContains')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotContains')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpEndsWith')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotEndsWith')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpStartsWith')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotStartsWith')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThanOrEqualTo')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $UseCurrentCulture
    )

    if ('OpMatch', 'OpNotMatch' -contains $PSCmdlet.ParameterSetName) {
        $options = [System.Text.RegularExpressions.RegexOptions]::None
        if (-not $UseCurrentCulture) {
            $options = [System.Text.RegularExpressions.RegexOptions]($options -bor [System.Text.RegularExpressions.RegexOptions]::CultureInvariant)
        }
        if (-not $CaseSensitive) {
            $options = [System.Text.RegularExpressions.RegexOptions]($options -bor [System.Text.RegularExpressions.Regexoptions]::IgnoreCase)
        }
    }
    elseif ($UseCurrentCulture) {
        if ($CaseSensitive) {
            $options = [System.StringComparison]::CurrentCulture
        }
        else {
            $options = [System.StringComparison]::CurrentCultureIgnoreCase
        }
    }
    else {
        if ($CaseSensitive) {
            $options = [System.StringComparison]::InvariantCulture
        }
        else {
            $options = [System.StringComparison]::InvariantCultureIgnoreCase
        }
    }

    #Do not use the return keyword to return the value
    #because PowerShell 2 will not properly set -OutVariable.

    switch ($PSCmdlet.ParameterSetName) {
        'IsText' {
            $result = $Value -is [System.String]
            if ($PSBoundParameters.ContainsKey('IsText')) {
                ($result) -xor (-not $IsText)
                return
            }
            $result
            return
        }
        'OpMatch' {
            if (($Value -is [System.String]) -and ($Match -is [System.String])) {
                ([System.Text.RegularExpressions.Regex]::IsMatch($Value, $Match, $options))
                return
            }
            $null
            return
        }
        'OpNotMatch' {
            if (($Value -is [System.String]) -and ($NotMatch -is [System.String])) {
                (-not [System.Text.RegularExpressions.Regex]::IsMatch($Value, $NotMatch, $options))
                return
            }
            $null
            return
        }
        'OpContains' {
            if (($Value -is [System.String]) -and ($Contains -is [System.String])) {
                ($Value.IndexOf($Contains, $options) -ge 0)
                return
            }
            $null
            return
        }
        'OpNotContains' {
            if (($Value -is [System.String]) -and ($NotContains -is [System.String])) {
                ($Value.IndexOf($NotContains, $options) -lt 0)
                return
            }
            $null
            return
        }
        'OpStartsWith' {
            if (($Value -is [System.String]) -and ($StartsWith -is [System.String])) {
                ($Value.StartsWith($StartsWith, $options))
                return
            }
            $null
            return
        }
        'OpNotStartsWith' {
            if (($Value -is [System.String]) -and ($NotStartsWith -is [System.String])) {
                (-not $Value.StartsWith($NotStartsWith, $options))
                return
            }
            $null
            return
        }
        'OpEndsWith' {
            if (($Value -is [System.String]) -and ($EndsWith -is [System.String])) {
                ($Value.EndsWith($EndsWith, $options))
                return
            }
            $null
            return
        }
        'OpNotEndsWith' {
            if (($value -is [System.String]) -and ($NotEndsWith -is [System.String])) {
                (-not $Value.EndsWith($NotEndsWith, $options))
                return
            }
            $null
            return
        }
        'OpEquals' {
            if (($Value -is [System.String]) -and ($Equals -is [System.String])) {
                ([System.String]::Equals($Value, $Equals, $options))
                return
            }
            $null
            return
        }
        'OpNotEquals' {
            if (($Value -is [System.String]) -and ($NotEquals -is [System.String])) {
                (-not [System.String]::Equals($Value, $NotEquals, $options))
                return
            }
            $null
            return
        }
        'OpLessThan' {
            if (($Value -is [System.String]) -and ($LessThan -is [System.String])) {
                ([System.String]::Compare($Value, $LessThan, $options) -lt 0)
                return
            }
            $null
            return
        }
        'OpLessThanOrEqualTo' {
            if (($Value -is [System.String]) -and ($LessThanOrEqualTo -is [System.String])) {
                ([System.String]::Compare($Value, $LessThanOrEqualTo, $options) -le 0)
                return
            }
            $null
            return
        }
        'OpGreaterThan' {
            if (($Value -is [System.String]) -and ($GreaterThan -is [System.String])) {
                ([System.String]::Compare($Value, $GreaterThan, $options) -gt 0)
                return
            }
            $null
            return
        }
        'OpGreaterThanOrEqualTo' {
            if (($Value -is [System.String]) -and ($GreaterThanOrEqualTo -is [System.String])) {
                ([System.String]::Compare($Value, $GreaterThanOrEqualTo, $options) -ge 0)
                return
            }
            $null
            return
        }
        default {
            throw Microsoft.PowerShell.Utility\New-Object -TypeName 'System.NotImplementedException' -ArgumentList @(
                "The ParameterSetName '$_' was not implemented."
            )
        }
    }
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Test-TimeSpan
{
    [CmdletBinding(DefaultParameterSetName = 'IsTimeSpan')]
    [OutputType([System.Boolean], [System.Object])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Value,

        [Parameter(Mandatory = $false, ParameterSetName = 'IsTimeSpan')]
        [System.Management.Automation.SwitchParameter]
        $IsTimeSpan,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpEquals')]
        [AllowNull()]
        [Alias('eq')]
        [System.Object]
        $Equals,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpNotEquals')]
        [AllowNull()]
        [Alias('ne')]
        [System.Object]
        $NotEquals,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpLessThan')]
        [AllowNull()]
        [Alias('lt')]
        [System.Object]
        $LessThan,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpLessThanOrEqualTo')]
        [AllowNull()]
        [Alias('le')]
        [System.Object]
        $LessThanOrEqualTo,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpGreaterThan')]
        [AllowNull()]
        [Alias('gt')]
        [System.Object]
        $GreaterThan,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [Alias('ge')]
        [System.Object]
        $GreaterThanOrEqualTo,

        [Parameter(Mandatory = $false, ParameterSetName = 'OpEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThanOrEqualTo')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.String[]]
        $Property
    )

    $hasPropertyConstraints = $PSBoundParameters.ContainsKey('Property')
    if ($hasPropertyConstraints -and ($null -eq $Property)) {
        $Property = [System.String[]]@()
    }
    if ($hasPropertyConstraints -and ($Property.Length -gt 0)) {
        $validProperties = [System.String[]]@(
            'Days', 'Hours', 'Minutes', 'Seconds', 'Milliseconds', 'Ticks',
            'TotalDays', 'TotalHours', 'TotalMilliseconds', 'TotalMinutes', 'TotalSeconds'
        )

        #Since the property names are going to be used directly in code,
        #make sure property names are valid and do not contain "ignorable" characters.

        foreach ($item in $Property) {
            if (($validProperties -notcontains $item) -or ($item -notmatch '^[a-zA-Z]+$')) {
                throw Microsoft.PowerShell.Utility\New-Object -TypeName 'System.ArgumentException' -ArgumentList @(
                    "Invalid TimeSpan Property: $item.`r`n" +
                    "Use one of the following values: $($validProperties -join ', ')"
                )
            }
        }
    }

    function compareTimeSpan($a, $b)
    {
        $canCompare = ($a -is [System.TimeSpan]) -and ($b -is [System.TimeSpan])
        if ($hasPropertyConstraints) {
            $canCompare = $canCompare -and ($Property.Length -gt 0)
        }

        if (-not $canCompare) {
            return $null
        }

        if (-not $hasPropertyConstraints) {
            return [System.TimeSpan]::Compare($a, $b)
        }

        $result = [System.Int32]0
        foreach ($item in $Property) {
            $result = $a.psbase.$item.CompareTo($b.psbase.$item)
            if ($result -ne 0) {
                break
            }
        }
        return $result
    }

    #Do not use the return keyword to return the value
    #because PowerShell 2 will not properly set -OutVariable.

    switch ($PSCmdlet.ParameterSetName) {
        'IsTimeSpan' {
            $result = $Value -is [System.TimeSpan]
            if ($PSBoundParameters.ContainsKey('IsTimeSpan')) {
                ($result) -xor (-not $IsTimeSpan)
                return
            }
            $result
            return
        }
        'OpEquals' {
            $result = compareTimeSpan $Value $Equals
            if ($result -is [System.Int32]) {
                ($result -eq 0)
                return
            }
            $null
            return
        }
        'OpNotEquals' {
            $result = compareTimeSpan $Value $NotEquals
            if ($result -is [System.Int32]) {
                ($result -ne 0)
                return
            }
            $null
            return
        }
        'OpLessThan' {
            $result = compareTimeSpan $Value $LessThan
            if ($result -is [System.Int32]) {
                ($result -lt 0)
                return
            }
            $null
            return
        }
        'OpLessThanOrEqualTo' {
            $result = compareTimeSpan $Value $LessThanOrEqualTo
            if ($result -is [System.Int32]) {
                ($result -le 0)
                return
            }
            $null
            return
        }
        'OpGreaterThan' {
            $result = compareTimeSpan $Value $GreaterThan
            if ($result -is [System.Int32]) {
                ($result -gt 0)
                return
            }
            $null
            return
        }
        'OpGreaterThanOrEqualTo' {
            $result = compareTimeSpan $Value $GreaterThanOrEqualTo
            if ($result -is [System.Int32]) {
                ($result -ge 0)
                return
            }
            $null
            return
        }
        default {
            throw Microsoft.PowerShell.Utility\New-Object -TypeName 'System.NotImplementedException' -ArgumentList @(
                "The ParameterSetName '$_' was not implemented."
            )
        }
    }
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Test-True
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    #Do not use the return keyword to return the value
    #because PowerShell 2 will not properly set -OutVariable.

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    ($Value -is [System.Boolean]) -and $Value
}


#.ExternalHelp AssertLibrary.psm1-help.xml
function Test-Version
{
    [CmdletBinding(DefaultParameterSetName = 'IsVersion')]
    [OutputType([System.Boolean], [System.Object])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Value,

        [Parameter(Mandatory = $false, ParameterSetName = 'IsVersion')]
        [System.Management.Automation.SwitchParameter]
        $IsVersion,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpEquals')]
        [AllowNull()]
        [Alias('eq')]
        [System.Object]
        $Equals,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpNotEquals')]
        [AllowNull()]
        [Alias('ne')]
        [System.Object]
        $NotEquals,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpLessThan')]
        [AllowNull()]
        [Alias('lt')]
        [System.Object]
        $LessThan,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpLessThanOrEqualTo')]
        [AllowNull()]
        [Alias('le')]
        [System.Object]
        $LessThanOrEqualTo,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpGreaterThan')]
        [AllowNull()]
        [Alias('gt')]
        [System.Object]
        $GreaterThan,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [Alias('ge')]
        [System.Object]
        $GreaterThanOrEqualTo,

        [Parameter(Mandatory = $false, ParameterSetName = 'OpEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThanOrEqualTo')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.String[]]
        $Property
    )

    $hasPropertyConstraints = $PSBoundParameters.ContainsKey('Property')
    if ($hasPropertyConstraints -and ($null -eq $Property)) {
        $Property = [System.String[]]@()
    }
    if ($hasPropertyConstraints -and ($Property.Length -gt 0)) {
        $validProperties = [System.String[]]@(
            'Major', 'Minor', 'Build', 'Revision', 'MajorRevision', 'MinorRevision'
        )

        #Since the property names are going to be used directly in code,
        #make sure property names are valid and do not contain "ignorable" characters.

        foreach ($item in $Property) {
            if (($validProperties -notcontains $item) -or ($item -notmatch '^[a-zA-Z]+$')) {
                throw Microsoft.PowerShell.Utility\New-Object -TypeName 'System.ArgumentException' -ArgumentList @(
                    "Invalid Version Property: $item.`r`n" +
                    "Use one of the following values: $($validProperties -join ', ')"
                )
            }
        }
    }

    function compareVersion($a, $b)
    {
        $canCompare = ($a -is [System.Version]) -and ($b -is [System.Version])
        if ($hasPropertyConstraints) {
            $canCompare = $canCompare -and ($Property.Length -gt 0)
        }

        if (-not $canCompare) {
            return $null
        }

        if (-not $hasPropertyConstraints) {
            return $a.psbase.CompareTo($b)
        }

        $result = [System.Int32]0
        foreach ($item in $Property) {
            $result = $a.psbase.$item.CompareTo($b.psbase.$item)
            if ($result -ne 0) {
                break
            }
        }
        return $result
    }

    #Do not use the return keyword to return the value
    #because PowerShell 2 will not properly set -OutVariable.

    switch ($PSCmdlet.ParameterSetName) {
        'IsVersion' {
            $result = $Value -is [System.Version]
            if ($PSBoundParameters.ContainsKey('IsVersion')) {
                ($result) -xor (-not $IsVersion)
                return
            }
            $result
            return
        }
        'OpEquals' {
            $result = compareVersion $Value $Equals
            if ($result -is [System.Int32]) {
                ($result -eq 0)
                return
            }
            $null
            return
        }
        'OpNotEquals' {
            $result = compareVersion $Value $NotEquals
            if ($result -is [System.Int32]) {
                ($result -ne 0)
                return
            }
            $null
            return
        }
        'OpLessThan' {
            $result = compareVersion $Value $LessThan
            if ($result -is [System.Int32]) {
                ($result -lt 0)
                return
            }
            $null
            return
        }
        'OpLessThanOrEqualTo' {
            $result = compareVersion $Value $LessThanOrEqualTo
            if ($result -is [System.Int32]) {
                ($result -le 0)
                return
            }
            $null
            return
        }
        'OpGreaterThan' {
            $result = compareVersion $Value $GreaterThan
            if ($result -is [System.Int32]) {
                ($result -gt 0)
                return
            }
            $null
            return
        }
        'OpGreaterThanOrEqualTo' {
            $result = compareVersion $Value $GreaterThanOrEqualTo
            if ($result -is [System.Int32]) {
                ($result -ge 0)
                return
            }
            $null
            return
        }
        default {
            throw Microsoft.PowerShell.Utility\New-Object -TypeName 'System.NotImplementedException' -ArgumentList @(
                "The ParameterSetName '$_' was not implemented."
            )
        }
    }
}


Export-ModuleMember -Function '*-*'

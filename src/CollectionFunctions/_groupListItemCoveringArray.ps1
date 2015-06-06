function _7ddd17460d1743b2b6e683ef649e01b7_groupListItemCoveringArray
{
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

    $listCount = _7ddd17460d1743b2b6e683ef649e01b7_getListLength -List $CoveringArray -ErrorAction $ErrorActionPreference

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
        _7ddd17460d1743b2b6e683ef649e01b7_groupListItemCartesianProduct -CartesianProduct $CoveringArray -ErrorAction $ErrorActionPreference
        return
    }

    #Get all the lengths of the list and
    #determine the type to use to constrain the output array.

    $listLengths = [System.Array]::CreateInstance([System.Int32], $listCount)
    $elementTypes = [System.Array]::CreateInstance([System.Type], $listCount)

    for ($i = 0; $i -lt $listCount; $i++) {
        $listLengths[$i] = _7ddd17460d1743b2b6e683ef649e01b7_getListLength -List $CoveringArray[$i] -ErrorAction $ErrorActionPreference
        $elementTypes[$i] = _7ddd17460d1743b2b6e683ef649e01b7_getListElementType -List $CoveringArray[$i] -ErrorAction $ErrorActionPreference
    }

    if (@($listLengths | Sort-Object)[0] -lt 1) {
        return
    }

    if (@($elementTypes | Sort-Object -Unique).Length -eq 1) {
        $outputElementType = $elementTypes[0]
    }
    else {
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

            $combinations = @(_7ddd17460d1743b2b6e683ef649e01b7_groupListItemCombine -Combine $counter -Size $Strength -ErrorAction $ErrorActionPreference)
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
}

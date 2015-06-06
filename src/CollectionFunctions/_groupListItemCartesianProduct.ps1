function _7ddd17460d1743b2b6e683ef649e01b7_groupListItemCartesianProduct
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]
        [AllowEmptyCollection()]
        [ValidateNotNull()]
        [System.Collections.IList[]]
        $CartesianProduct
    )

    $listCount = _7ddd17460d1743b2b6e683ef649e01b7_getListLength -List $CartesianProduct -ErrorAction $ErrorActionPreference

    if ($listCount -lt 1) {
        return
    }

    #Get all the lengths of the list and
    #determine the type to use to constrain the output array.

    $listLengths = [System.Array]::CreateInstance([System.Int32], $listCount)
    $elementTypes = [System.Array]::CreateInstance([System.Type], $listCount)

    for ($i = 0; $i -lt $listCount; $i++) {
        $listLengths[$i] = _7ddd17460d1743b2b6e683ef649e01b7_getListLength -List $CartesianProduct[$i] -ErrorAction $ErrorActionPreference
        $elementTypes[$i] = _7ddd17460d1743b2b6e683ef649e01b7_getListElementType -List $CartesianProduct[$i] -ErrorAction $ErrorActionPreference
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
}

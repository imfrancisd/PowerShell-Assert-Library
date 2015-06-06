function _7ddd17460d1743b2b6e683ef649e01b7_groupListItemZip
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]
        [AllowEmptyCollection()]
        [ValidateNotNull()]
        [System.Collections.IList[]]
        $Zip
    )

    $listCount = _7ddd17460d1743b2b6e683ef649e01b7_getListLength -List $Zip -ErrorAction $ErrorActionPreference

    if ($listCount -lt 1) {
        return
    }

    #Get all the lengths of the list and
    #determine the type to use to constrain the output array.

    $listLengths = [System.Array]::CreateInstance([System.Int32], $listCount)
    $elementTypes = [System.Array]::CreateInstance([System.Type], $listCount)

    for ($i = 0; $i -lt $listCount; $i++) {
        $listLengths[$i] = _7ddd17460d1743b2b6e683ef649e01b7_getListLength -List $Zip[$i] -ErrorAction $ErrorActionPreference
        $elementTypes[$i] = _7ddd17460d1743b2b6e683ef649e01b7_getListElementType -List $Zip[$i] -ErrorAction $ErrorActionPreference
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
}

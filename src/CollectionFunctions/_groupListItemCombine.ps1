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

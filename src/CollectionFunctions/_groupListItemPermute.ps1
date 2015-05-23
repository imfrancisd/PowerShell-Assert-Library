function _7ddd17460d1743b2b6e683ef649e01b7_groupListItemPermute
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false)]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Permute,

        [Parameter(Mandatory=$false)]
        [System.Int32]
        $Size
    )

    $listLength = _7ddd17460d1743b2b6e683ef649e01b7_getListLength -List $Permute -ErrorAction $ErrorActionPreference
    $outputElementType = _7ddd17460d1743b2b6e683ef649e01b7_getListElementType -List $Permute -ErrorAction $ErrorActionPreference

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
}

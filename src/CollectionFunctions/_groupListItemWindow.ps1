function _7ddd17460d1743b2b6e683ef649e01b7_groupListItemWindow
{
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

    $listLength = _7ddd17460d1743b2b6e683ef649e01b7_getListLength -List $Window -ErrorAction $ErrorActionPreference
    $outputElementType = _7ddd17460d1743b2b6e683ef649e01b7_getListElementType -List $Window -ErrorAction $ErrorActionPreference

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
}

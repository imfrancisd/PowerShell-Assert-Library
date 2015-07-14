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

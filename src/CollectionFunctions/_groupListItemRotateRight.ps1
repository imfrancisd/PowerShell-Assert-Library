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

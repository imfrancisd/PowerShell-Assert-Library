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

    for ($offset = 0; $offset -lt $listLength; $offset++) {
        #generate group
        $items = [System.Array]::CreateInstance($outputElementType, $listLength)

        $i = 0

        $j = $offset
        while ($j -lt $listLength) {
            $items[$i++] = $RotateLeft[$j++]
        }

        $j = 0
        while ($i -lt $listLength) {
            $items[$i++] = $RotateLeft[$j++]
        }

        #output group
        Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
            'Items' = $items
        }
    }
}

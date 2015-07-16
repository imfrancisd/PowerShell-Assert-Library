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

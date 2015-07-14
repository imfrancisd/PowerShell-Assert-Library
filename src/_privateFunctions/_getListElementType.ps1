$_7ddd17460d1743b2b6e683ef649e01b7_getListElementType = {
    [CmdletBinding()]
    [OutputType([System.Type])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IList]
        $List
    )

    #NOTE about compatibility
    #
    #In PowerShell, it is possible to override properties and methods of an object.
    #
    #The psbase property in all objects allows access to the real properties and methods.
    #
    #In PowerShell 4 (and possibly PowerShell 3) however, the psbase property does not
    #allow access to the "real" GetType method of the object. Instead, .psbase.GetType()
    #returns the type of the psbase object instead of the type of the object that psbase
    #represents.
    #
    #Explicit .NET reflection must be used if you want to make sure that you are calling
    #the "real" GetType method in PowerShell 4 (and possibly PowerShell 3).

    $objectGetType = [System.Object].GetMethod('GetType', [System.Type]::EmptyTypes)
    $genericIList = [System.Type]::GetType('System.Collections.Generic.IList`1')

    if ($List -is [System.Array]) {
        return $objectGetType.Invoke($List, $null).GetElementType()
    }

    if ($List -is [System.Collections.IList]) {
        $IListGenericTypes = @(
            $objectGetType.Invoke($List, $null).GetInterfaces() |
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

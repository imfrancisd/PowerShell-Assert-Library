function _7ddd17460d1743b2b6e683ef649e01b7_getElementType
{
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [System.Collections.IList]
        $list
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

    if ($list -is [System.Array]) {
        return $objectGetType.Invoke($list, $null).GetElementType()
    }

    if ($list -is [System.Collections.IList]) {
        $IListGenericTypes = @(
            $objectGetType.Invoke($list, $null).GetInterfaces() |
            Where-Object -FilterScript {
                $_.IsGenericType -and ($_.GetGenericTypeDefinition() -eq $genericIList)
            }
        )

        if ($IListGenericTypes.Length -eq 1) {
            return $IListGenericTypes[0].GetGenericArguments()[0]
        }
    }

    return [System.Object]
}

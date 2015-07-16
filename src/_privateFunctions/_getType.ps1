$_7ddd17460d1743b2b6e683ef649e01b7_getType = {
    [CmdletBinding()]
    [OutputType([System.Type])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Object]
        $InputObject
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

    if ($null -eq $InputObject) {
        return [System.Void]
    }
    return $_7ddd17460d1743b2b6e683ef649e01b7_getTypeMethod.Invoke($InputObject, $null)
}

$_7ddd17460d1743b2b6e683ef649e01b7_getTypeMethod = [System.Object].GetMethod('GetType', [System.Type]::EmptyTypes)

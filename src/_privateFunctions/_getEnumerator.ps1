$_7ddd17460d1743b2b6e683ef649e01b7_getEnumerator = {
    [CmdletBinding()]
    [OutputType([System.Collections.IEnumerator])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IEnumerable]
        $InputObject
    )

    #NOTE about compatibility
    #
    #In PowerShell, it is possible to override properties and methods of an object.
    #
    #The psbase property in all objects allows access to the real properties and methods.
    #
    #The properties of hashtables, however, can sometimes be hidden depending on what is
    #inside the hashtable and the version of PowerShell. This means that we cannot always
    #access the psbase property, which means that we cannot use psbase to access the
    #"real" GetEnumerator method of hashtables.
    #
    #Explicit .NET reflection must be used if you want to make sure that you are calling
    #the "real" GetEnumerator method of collections in different versions of PowerShell.

    ,$_7ddd17460d1743b2b6e683ef649e01b7_getEnumeratorMethod.Invoke($InputObject, $null)
}

$_7ddd17460d1743b2b6e683ef649e01b7_getEnumeratorMethod = [System.Collections.IEnumerable].GetMethod('GetEnumerator', [System.Type]::EmptyTypes)

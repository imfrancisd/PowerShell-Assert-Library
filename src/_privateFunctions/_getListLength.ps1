function _7ddd17460d1743b2b6e683ef649e01b7_getListLength
{
    [CmdletBinding()]
    [OutputType([System.Int32])]
    Param(
        [Parameter(Mandatory=$true)]
        [System.Collections.IList]
        $List
    )

    #NOTE
    #
    #In PowerShell, it is possible to override properties and methods of an object.
    #
    #The psbase property in all objects allows access to the real properties and methods.

    if ($List -is [System.Array]) {
        return $List.psbase.Length
    }

    return $List.psbase.Count
}

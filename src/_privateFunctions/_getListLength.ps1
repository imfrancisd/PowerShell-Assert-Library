function _7ddd17460d1743b2b6e683ef649e01b7_getListLength
{
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [System.Collections.IList]
        $list
    )

    if ($list -is [System.Array]) {
        return $list.psbase.Length
    }

    return $list.psbase.Count
}

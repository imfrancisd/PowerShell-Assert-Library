function Test-Exists
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Collection,

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=1)]
        [System.Management.Automation.ScriptBlock]
        $Predicate
    )

    #Do not use the return keyword to return the value
    #because PowerShell 2 will not properly set -OutVariable.

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    if ($Collection -is [System.Collections.ICollection]) {
        foreach ($item in $Collection.psbase.GetEnumerator()) {
            try   {$result = & $Predicate $item}
            catch {$PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newPredicateFailedError -errorRecord $_ -predicate $Predicate))}
        
            if (($result -is [System.Boolean]) -and $result) {
                $true
                return
            }
        }
        $false
        return
    }

    $null
}
function Test-Exists
{
    [CmdletBinding()]
    [OutputType([System.Boolean], [System.Object])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Collection,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 1)]
        [System.Management.Automation.ScriptBlock]
        $Predicate,

        [Parameter(Mandatory = $false, ValueFromPipeline = $false, Position = 2)]
        [ValidateSet('Any', 'Single', 'Multiple')]
        [System.String]
        $Quantity = 'Any'
    )

    #Do not use the return keyword to return the value
    #because PowerShell 2 will not properly set -OutVariable.

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    if ($Collection -is [System.Collections.ICollection]) {
        $exists = $false
        $found = 0
        $enumerator = & $_7ddd17460d1743b2b6e683ef649e01b7_getEnumerator $Collection

        foreach ($item in $enumerator) {
            $result = $null
            try   {$result = do {& $Predicate $item} while ($false)}
            catch {$PSCmdlet.ThrowTerminatingError((& $_7ddd17460d1743b2b6e683ef649e01b7_newPredicateFailedError -errorRecord $_ -predicate $Predicate))}

            if (($result -is [System.Boolean]) -and $result) {
                $found++
                if ($Quantity -eq 'Any') {
                    $exists = $true
                    break
                }
                if ($Quantity -eq 'Single') {
                    if ($found -gt 1) {
                        $exists = $false
                        break
                    }
                }
                if ($Quantity -eq 'Multiple') {
                    if ($found -gt 1) {
                        $exists = $true
                        break
                    }
                }
            }
        }
        $exists -or (($found -eq 1) -and ($Quantity -eq 'Single'))
        return
    }

    $null
}

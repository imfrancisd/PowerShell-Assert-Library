function Test-NotTrue
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    #Do not use the return keyword to return the value
    #because PowerShell 2 will not properly set -OutVariable.

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    ($Value -isnot [System.Boolean]) -or (-not $Value)
}
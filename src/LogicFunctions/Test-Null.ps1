function Test-Null
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    #Do not use the return keyword to return the value
    #because PowerShell 2 will not properly set -OutVariable.

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    $null -eq $Value
}

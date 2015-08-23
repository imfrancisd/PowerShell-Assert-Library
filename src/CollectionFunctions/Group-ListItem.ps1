function Group-ListItem
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'Pair')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Pair,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'Window')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Window,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'RotateLeft')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $RotateLeft,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'RotateRight')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $RotateRight,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'Combine')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Combine,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'Permute')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Permute,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'CartesianProduct')]
        [AllowEmptyCollection()]
        [ValidateNotNull()]
        [System.Collections.IList[]]
        $CartesianProduct,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'CoveringArray')]
        [AllowEmptyCollection()]
        [ValidateNotNull()]
        [System.Collections.IList[]]
        $CoveringArray,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'Zip')]
        [AllowEmptyCollection()]
        [ValidateNotNull()]
        [System.Collections.IList[]]
        $Zip,

        [Parameter(Mandatory = $false, ValueFromPipeline = $false, ParameterSetName = 'Combine')]
        [Parameter(Mandatory = $false, ValueFromPipeline = $false, ParameterSetName = 'Permute')]
        [Parameter(Mandatory = $false, ValueFromPipeline = $false, ParameterSetName = 'Window')]
        [System.Int32]
        $Size,

        [Parameter(Mandatory = $false, ValueFromPipeline = $false, ParameterSetName = 'CoveringArray')]
        [System.Int32]
        $Strength
    )

    #NOTE about [ValidateNotNull()]
    #
    #The ValidateNotNull() attribute validates that a list and its contents are not $null.
    #The -RotateLeft, -RotateRight, -Combine, -Permute, -Pair, and -Window parameters
    #NOT having this attribute
    #and -CartesianProduct, -CoveringArray and -Zip having this attribute, is intentional.
    #
    #Mandatory = $true will make sure -Combine, -Permute, -Pair, and -Window are not $null.

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    $PSBoundParameters['ErrorAction'] = $ErrorActionPreference

    switch ($PSCmdlet.ParameterSetName) {
        'RotateLeft' {
            & $_7ddd17460d1743b2b6e683ef649e01b7_groupListItemRotateLeft @PSBoundParameters
            return
        }
        'RotateRight' {
            & $_7ddd17460d1743b2b6e683ef649e01b7_groupListItemRotateRight @PSBoundParameters
            return
        }
        'Pair' {
            & $_7ddd17460d1743b2b6e683ef649e01b7_groupListItemPair @PSBoundParameters
            return
        }
        'Window' {
            & $_7ddd17460d1743b2b6e683ef649e01b7_groupListItemWindow @PSBoundParameters
            return
        }
        'Combine' {
            & $_7ddd17460d1743b2b6e683ef649e01b7_groupListItemCombine @PSBoundParameters
            return
        }
        'Permute' {
            & $_7ddd17460d1743b2b6e683ef649e01b7_groupListItemPermute @PSBoundParameters
            return
        }
        'CartesianProduct' {
            & $_7ddd17460d1743b2b6e683ef649e01b7_groupListItemCartesianProduct @PSBoundParameters
            return
        }
        'Zip' {
            & $_7ddd17460d1743b2b6e683ef649e01b7_groupListItemZip @PSBoundParameters
            return
        }
        'CoveringArray' {
            & $_7ddd17460d1743b2b6e683ef649e01b7_groupListItemCoveringArray @PSBoundParameters
            return
        }
        default {
            $errorRecord = Microsoft.PowerShell.Utility\New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                (Microsoft.PowerShell.Utility\New-Object -TypeName 'System.NotImplementedException' -ArgumentList @("The ParameterSetName '$_' was not implemented.")),
                'NotImplemented',
                [System.Management.Automation.ErrorCategory]::NotImplemented,
                $null
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }
}

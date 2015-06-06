function Group-ListItem
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'Pair')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Pair,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'Window')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Window,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'Combine')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Combine,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'Permute')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Permute,

        [Parameter(Mandatory = $false, ValueFromPipeline = $false, ParameterSetName = 'Combine')]
        [Parameter(Mandatory = $false, ValueFromPipeline = $false, ParameterSetName = 'Permute')]
        [Parameter(Mandatory = $false, ValueFromPipeline = $false, ParameterSetName = 'Window')]
        [System.Int32]
        $Size,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'CoveringArray')]
        [AllowEmptyCollection()]
        [ValidateNotNull()]
        [System.Collections.IList[]]
        $CoveringArray,

        [Parameter(Mandatory = $false, ValueFromPipeline = $false, ParameterSetName = 'CoveringArray')]
        [System.Int32]
        $Strength,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'CartesianProduct')]
        [AllowEmptyCollection()]
        [ValidateNotNull()]
        [System.Collections.IList[]]
        $CartesianProduct,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'Zip')]
        [AllowEmptyCollection()]
        [ValidateNotNull()]
        [System.Collections.IList[]]
        $Zip
    )

    #NOTE about [ValidateNotNull()]
    #
    #The ValidateNotNull() attribute validates that a list and its contents are not $null.
    #The -Combine, -Permute, -Pair, and -Window parameters NOT having this attribute and
    #-CartesianProduct, -CoveringArray and -Zip having this attribute, is intentional.
    #
    #Mandatory = $true will make sure -Combine, -Permute, -Pair, and -Window are not $null.

    $PSBoundParameters['ErrorAction'] = [System.Management.Automation.ActionPreference]::Stop

    switch ($PSCmdlet.ParameterSetName) {
        'Pair' {
            _7ddd17460d1743b2b6e683ef649e01b7_groupListItemPair @PSBoundParameters
            return
        }
        'Window' {
            _7ddd17460d1743b2b6e683ef649e01b7_groupListItemWindow @PSBoundParameters
            return
        }
        'Combine' {
            _7ddd17460d1743b2b6e683ef649e01b7_groupListItemCombine @PSBoundParameters
            return
        }
        'Permute' {
            _7ddd17460d1743b2b6e683ef649e01b7_groupListItemPermute @PSBoundParameters
            return
        }
        'CartesianProduct' {
            _7ddd17460d1743b2b6e683ef649e01b7_groupListItemCartesianProduct @PSBoundParameters
            return
        }
        'Zip' {
            _7ddd17460d1743b2b6e683ef649e01b7_groupListItemZip @PSBoundParameters
            return
        }
        'CoveringArray' {
            _7ddd17460d1743b2b6e683ef649e01b7_groupListItemCoveringArray @PSBoundParameters
            return
        }
        default {
            $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                (New-Object -TypeName 'System.NotImplementedException' -ArgumentList @("The ParameterSetName '$_' was not implemented.")),
                'NotImplemented',
                [System.Management.Automation.ErrorCategory]::NotImplemented,
                $null
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }
}

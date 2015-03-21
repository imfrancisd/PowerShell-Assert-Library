function Test-Guid
{
<#
.Synopsis
An alternative to PowerShell's comparison operators when testing GUIDs in unit test scenarios.
.Description
This function tests a GUID for type and equality without the implicit conversions or the filtering semantics from the PowerShell comparison operators.

This function will return one of the following values:
    $true
    $false
    $null

A return value of $null indicates an invalid test. See each parameter for specific conditions that causes this function to return $true, $false, or $null.
.Example
Test-Guid $a
Returns $true if $a is a GUID.
.Example
Test-Guid $a -variant standard, microsoft
Returns $true if $a is a standard variant GUID or a Microsoft Backward Compatibility variant GUID.

See the -Variant parameter for more details.
.Example
Test-Guid $a -variant standard -version 1, 4
Returns $true if $a is a standard variant GUID, with a value of 1 or 4 in its version field.

See the -Variant and -Version parameters for more details.
.Example
Test-Guid $a -lt $b
Returns $true if $a is less than $b, and $a and $b are both GUIDs.
Returns $null if $a or $b is not a GUID.
.Example
Test-Guid $a -lt $b -matchvariant
Returns $true if $a is less than $b, and $a and $b have equivalent values in their variant field.
Returns $null if $a or $b is not a GUID, or $a and $b do not have equivalent values in their variant field.

See the -MatchVariant and -Variant parameters for more details.
.Example
Test-Guid $a -lt $b -variant standard -matchversion
Returns $true if $a is less than $b, and both $a and $b are standard variant GUIDs with the same value in their version field.
Returns $null if $a or $b is not a standard variant GUID, or $a and $b do not have the same value in their version field.
.Inputs
System.Guid
System.Object
.Outputs
System.Boolean
$null
.Notes
An example of how this function might be used in a unit test.

#recommended alias
set-alias 'guid?' 'test-guid'

assert-true (guid? $a)
assert-true (guid? $a -variant standard -version 1,3,4,5)
assert-true (guid? $a -ne $b -variant standard -version 1,3,4,5 -matchvariant -matchversion)
#>
    [CmdletBinding(DefaultParameterSetName='IsGuid')]
    Param(
        #The value to test.
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Value,

        #Tests if the value is a GUID.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          never
        #$false         value is not a GUID*
        #$true          value is a GUID*
        #
        #*See the -Variant and -Version parameters for more details.
        [Parameter(Mandatory=$false, ParameterSetName='IsGuid')]
        [System.Management.Automation.SwitchParameter]
        $IsGuid,

        #Tests if the first value is equal to the second.
        #
        #The -Equals parameter has the alias -eq.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not a GUID*
        #$false         System.Guid method CompareTo(Guid) != 0
        #$true          System.Guid method CompareTo(Guid) == 0
        #
        #*See the -Variant and -Version parameters for more details.
        [Parameter(Mandatory=$true, ParameterSetName='OpEquals')]
        [AllowNull()]
        [Alias('eq')]
        [System.Object]
        $Equals,

        #Tests if the first value is not equal to the second.
        #
        #The -NotEquals parameter has the alias -ne.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not a GUID*
        #$false         System.Guid method CompareTo(Guid) == 0
        #$true          System.Guid method CompareTo(Guid) != 0
        #
        #*See the -Variant and -Version parameters for more details.
        [Parameter(Mandatory=$true, ParameterSetName='OpNotEquals')]
        [AllowNull()]
        [Alias('ne')]
        [System.Object]
        $NotEquals,

        #Tests if the first value is less than the second.
        #
        #The -LessThan parameter has the alias -lt.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not a GUID*
        #$false         System.Guid method CompareTo(Guid) >= 0
        #$true          System.Guid method CompareTo(Guid) < 0
        #
        #*See the -Variant and -Version parameters for more details.
        [Parameter(Mandatory=$true, ParameterSetName='OpLessThan')]
        [AllowNull()]
        [Alias('lt')]
        [System.Object]
        $LessThan,

        #Tests if the first value is less than or equal to the second.
        #
        #The -LessThanOrEqualTo parameter has the alias -le.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not a GUID*
        #$false         System.Guid method CompareTo(Guid) > 0
        #$true          System.Guid method CompareTo(Guid) <= 0
        #
        #*See the -Variant and -Version parameters for more details.
        [Parameter(Mandatory=$true, ParameterSetName='OpLessThanOrEqualTo')]
        [AllowNull()]
        [Alias('le')]
        [System.Object]
        $LessThanOrEqualTo,

        #Tests if the first value is greater than the second.
        #
        #The -GreaterThan parameter has the alias -gt.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not a GUID*
        #$false         System.Guid method CompareTo(Guid) <= 0
        #$true          System.Guid method CompareTo(Guid) > 0
        #
        #*See the -Variant and -Version parameters for more details.
        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThan')]
        [AllowNull()]
        [Alias('gt')]
        [System.Object]
        $GreaterThan,

        #Tests if the first value is greater than or equal to the second.
        #
        #The -GreaterThanOrEqualTo parameter has the alias -ge.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not a GUID*
        #$false         System.Guid method CompareTo(Guid) < 0
        #$true          System.Guid method CompareTo(Guid) >= 0
        #
        #*See the -Variant and -Version parameters for more details.
        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [Alias('ge')]
        [System.Object]
        $GreaterThanOrEqualTo,

        #Causes the comparison of two GUIDs to return $null if they do not have an equivalent variant.
        #
        #*See the -Variant parameter for more details.
        [Parameter(Mandatory=$false, ParameterSetName='OpEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThanOrEqualTo')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $MatchVariant,

        #Causes the comparison of two GUIDs to return $null if they do not have the same value in their version fields.
        #
        #*See the -Version parameter for more details.
        [Parameter(Mandatory=$false, ParameterSetName='OpEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThanOrEqualTo')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $MatchVersion,

        #One or more Strings that can be used to define which variants of GUIDs are to be considered GUIDs.
        #
        #Allowed Variants
        #----------------
        #Standard, Microsoft, NCS, Reserved
        #
        #    The GUID variant field can be found in the nibble marked with v:
        #    00000000-0000-0000-v000-000000000000
        #
        #    Variant    v
        #    -------    -
        #    Standard   8, 9, A, B
        #    Microsoft  C, D
        #    NCS        0, 1, 2, 3, 4, 5, 6, 7
        #    Reserved   E, F
        #
        #Note:
        #Specifying this parameter with a $null or an empty array will cause this function to treat all objects as non-GUIDs.
        [Parameter(Mandatory=$false, ParameterSetName='IsGuid')]
        [Parameter(Mandatory=$false, ParameterSetName='OpEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThanOrEqualTo')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.String[]]
        $Variant,

        #One or more integers that can be used to define which versions of GUIDs are to be considered GUIDs.
        #
        #Allowed Versions
        #----------------
        #0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
        #
        #    The GUID version field can be found in the nibble marked with v:
        #    00000000-0000-v000-0000-000000000000
        #
        #    Note: The meaning of the value in the version field depends on the GUID variant.
        #
        #Note:
        #Specifying this parameter with a $null or an empty array will cause this function to treat all objects as non-GUIDs.
        [Parameter(Mandatory=$false, ParameterSetName='IsGuid')]
        [Parameter(Mandatory=$false, ParameterSetName='OpEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThanOrEqualTo')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Int32[]]
        $Version
    )

    $hasVersionConstraints = $PSBoundParameters.ContainsKey('Version')
    $hasVariantConstraints = $PSBoundParameters.ContainsKey('Variant')

    if ($hasVersionConstraints) {
        $versionConstraints = ''

        if (($null -ne $Version) -and ($Version.Length -gt 0)) {
            $intToHex = '0123456789ABCDEF'

            foreach ($item in $Version) {
                if (($item -lt 0) -or ($item -gt 15)) {
                    throw New-Object -TypeName 'System.ArgumentException' -ArgumentList @(
                        'Version',
                        'The GUID version field can only contain integers between 0 and 15.'
                    )
                }
                $versionConstraints += $intToHex[$item]
            }
        }
    }

    if ($hasVariantConstraints) {
        $variantConstraints = ''

        if (($null -ne $Variant) -and ($Variant.Length -gt 0)) {
            foreach ($item in $Variant) {
                switch ($item) {
                    'Standard'  {$variantConstraints += '89AB'; break;}
                    'Microsoft' {$variantConstraints += 'CD'; break;}
                    'NCS'       {$variantConstraints += '01234567'; break;}
                    'Reserved'  {$variantConstraints += 'EF'; break;}
                    default     {
                        throw New-Object -TypeName 'System.ArgumentException' -ArgumentList @(
                            "Invalid GUID variant: $item.`r`n" +
                            "Use one of the following values: Standard, Microsoft, NCS, Reserved"
                        )
                    }
                }
            }
        }
    }

    function isGuid($a)
    {
        $isGuid = $a -is [System.Guid]
        if ($isGuid) {
            $guidString = $a.psbase.ToString('D')
            $iOrdinal = [System.Stringcomparison]::OrdinalIgnoreCase

            if ($hasVersionConstraints) {
                $versionString = $guidString.Substring(14, 1)
                $isGuid = $versionConstraints.IndexOf($versionString, $iOrdinal) -ge 0
            }
            if ($isGuid -and $hasVariantConstraints) {
                $variantString = $guidString.Substring(19, 1)
                $isGuid = $variantConstraints.IndexOf($variantString, $iOrdinal) -ge 0
            }
        }
        return $isGuid
    }

    function compareGuid($a, $b)
    {
        $canCompare = (isGuid $a) -and (isGuid $b)
        if ($canCompare) {
            $aString = $a.psbase.ToString('D')
            $bString = $b.psbase.ToString('D')
            $iOrdinal = [System.StringComparison]::OrdinalIgnoreCase

            if ($MatchVersion) {
                $aVersion = $aString.SubString(14, 1)
                $bVersion = $bString.SubString(14, 1)

                $canCompare = [System.String]::Equals($aVersion, $bVersion, $iOrdinal)
            }
            if ($canCompare -and $MatchVariant) {
                $aVariant = $aString.SubString(19, 1)
                $bVariant = $bString.SubString(19, 1)

                $canCompare = $false
                foreach ($item in @('89AB', 'CD', '01234567', 'EF')) {
                    if ($item.IndexOf($aVariant, $iOrdinal) -ge 0) {
                        $canCompare = $item.IndexOf($bVariant, $iOrdinal) -ge 0
                        break
                    }
                }
            }
        }

        if ($canCompare) {
            return $a.psbase.CompareTo($b)
        }
        return $null
    }

    switch ($PSCmdlet.ParameterSetName) {
        'IsGuid' {
            return (isGuid $Value)
        }
        'OpEquals' {
            $result = compareGuid $Value $Equals
            if ($result -is [System.Int32]) {
                return ($result -eq 0)
            }
            return $null
        }
        'OpNotEquals' {
            $result = compareGuid $Value $NotEquals
            if ($result -is [System.Int32]) {
                return ($result -ne 0)
            }
            return $null
        }
        'OpLessThan' {
            $result = compareGuid $Value $LessThan
            if ($result -is [System.Int32]) {
                return ($result -lt 0)
            }
            return $null
        }
        'OpLessThanOrEqualTo' {
            $result = compareGuid $Value $LessThanOrEqualTo
            if ($result -is [System.Int32]) {
                return ($result -le 0)
            }
            return $null
        }
        'OpGreaterThan' {
            $result = compareGuid $Value $GreaterThan
            if ($result -is [System.Int32]) {
                return ($result -gt 0)
            }
            return $null
        }
        'OpGreaterThanOrEqualTo' {
            $result = compareGuid $Value $GreaterThanOrEqualTo
            if ($result -is [System.Int32]) {
                return ($result -ge 0)
            }
            return $null
        }
        default {
            throw New-Object -TypeName 'System.NotImplementedException' -ArgumentList @(
                "The ParameterSetName '$_' was not implemented."
            )
        }
    }
}

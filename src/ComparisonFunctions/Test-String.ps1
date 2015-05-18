function Test-String
{
    [CmdletBinding(DefaultParameterSetName='IsString')]
    [OutputType([System.Boolean], [System.Object])]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $Value,

        [Parameter(Mandatory=$false, ParameterSetName='IsString')]
        [System.Management.Automation.SwitchParameter]
        $IsString = $true,

        [Parameter(Mandatory=$true, ParameterSetName='OpContains')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $Contains,

        [Parameter(Mandatory=$true, ParameterSetName='OpNotContains')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $NotContains,

        [Parameter(Mandatory=$true, ParameterSetName='OpStartsWith')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $StartsWith,

        [Parameter(Mandatory=$true, ParameterSetName='OpNotStartsWith')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $NotStartsWith,

        [Parameter(Mandatory=$true, ParameterSetName='OpEndsWith')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $EndsWith,

        [Parameter(Mandatory=$true, ParameterSetName='OpNotEndsWith')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $NotEndsWith,

        [Parameter(Mandatory=$true, ParameterSetName='OpEquals')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('eq')]
        [System.Object]
        $Equals,

        [Parameter(Mandatory=$true, ParameterSetName='OpNotEquals')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('ne')]
        [System.Object]
        $NotEquals,

        [Parameter(Mandatory=$true, ParameterSetName='OpLessThan')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('lt')]
        [System.Object]
        $LessThan,

        [Parameter(Mandatory=$true, ParameterSetName='OpLessThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('le')]
        [System.Object]
        $LessThanOrEqualTo,

        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThan')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('gt')]
        [System.Object]
        $GreaterThan,

        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('ge')]
        [System.Object]
        $GreaterThanOrEqualTo,

        [Parameter(Mandatory=$false, ParameterSetName='OpContains')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotContains')]
        [Parameter(Mandatory=$false, ParameterSetName='OpEndsWith')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEndsWith')]
        [Parameter(Mandatory=$false, ParameterSetName='OpStartsWith')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotStartsWith')]
        [Parameter(Mandatory=$false, ParameterSetName='OpEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThanOrEqualTo')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $CaseSensitive,

        [Parameter(Mandatory=$false, ParameterSetName='OpContains')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotContains')]
        [Parameter(Mandatory=$false, ParameterSetName='OpStartsWith')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotStartsWith')]
        [Parameter(Mandatory=$false, ParameterSetName='OpEndsWith')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEndsWith')]
        [Parameter(Mandatory=$false, ParameterSetName='OpEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThanOrEqualTo')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $FormCompatible,

        [Parameter(Mandatory=$false)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Text.NormalizationForm[]]
        $Normalization
    )

    if ($CaseSensitive) {
        $comparisonType = [System.StringComparison]::Ordinal
    } else {
        $comparisonType = [System.StringComparison]::OrdinalIgnoreCase
    }

    $hasNormalizationConstraints = $PSBoundParameters.ContainsKey('Normalization')

    if (-not $hasNormalizationConstraints) {
        $allowedNormalizations = [System.Text.NormalizationForm[]]@(
            [System.Enum]::GetValues([System.Text.NormalizationForm])
        )
    } elseif (($null -eq $Normalization) -or ($Normalization.Length -eq 0)) {
        $allowedNormalizations = [System.Text.NormalizationForm[]]@()
    } else {
        $allowedNormalizations = [System.Text.NormalizationForm[]]@(
            [System.Enum]::GetValues([System.Text.NormalizationForm]) |
                Where-Object {$Normalization -contains $_}
        )
    }

    function isString($str)
    {
        $isStringType = $str -is [System.String]

        if ($isStringType -and $hasNormalizationConstraints) {
            foreach ($item in $allowedNormalizations) {
                if ($str.IsNormalized($item)) {
                    return $true
                }
            }
            return $false
        }

        return $isStringType
    }

    function canCompareStrings($strA, $strB)
    {
        $areStrings = ((isString $strA) -and (isString $strB))
        if ($areStrings -and $FormCompatible) {
            foreach ($item in $allowedNormalizations) {
                if ($strA.IsNormalized($item) -and $strB.IsNormalized($item)) {
                    return $true
                }
            }
            return $false
        }
        return $areStrings
    }

    switch ($PSCmdlet.ParameterSetName) {
        'IsString' {
            return (isString $Value) -xor (-not $IsString)
        }
        'OpContains' {
            if ((canCompareStrings $Value $Contains)) {
                return ($Value.IndexOf($Contains, $comparisonType) -ge 0)
            }
            return $null
        }
        'OpNotContains' {
            if ((canCompareStrings $Value $NotContains)) {
                return ($Value.IndexOf($NotContains, $comparisonType) -lt 0)
            }
            return $null
        }
        'OpStartsWith' {
            if ((canCompareStrings $Value $StartsWith)) {
                return ($Value.StartsWith($StartsWith, $comparisonType))
            }
            return $null
        }
        'OpNotStartsWith' {
            if ((canCompareStrings $Value $NotStartsWith)) {
                return (-not $Value.StartsWith($NotStartsWith, $comparisonType))
            }
            return $null
        }
        'OpEndsWith' {
            if ((canCompareStrings $Value $EndsWith)) {
                return ($Value.EndsWith($EndsWith, $comparisonType))
            }
            return $null
        }
        'OpNotEndsWith' {
            if ((canCompareStrings $Value $NotEndsWith)) {
                return (-not $Value.EndsWith($NotEndsWith, $comparisonType))
            }
            return $null
        }
        'OpEquals' {
            if ((canCompareStrings $Value $Equals)) {
                return ([System.String]::Equals($Value, $Equals, $comparisonType))
            }
            return $null
        }
        'OpNotEquals' {
            if ((canCompareStrings $Value $NotEquals)) {
                return (-not [System.String]::Equals($Value, $NotEquals, $comparisonType))
            }
            return $null
        }
        'OpLessThan' {
            if ((canCompareStrings $Value $LessThan)) {
                return ([System.String]::Compare($Value, $LessThan, $comparisonType) -lt 0)
            }
            return $null
        }
        'OpLessThanOrEqualTo' {
            if ((canCompareStrings $Value $LessThanOrEqualTo)) {
                return ([System.String]::Compare($Value, $LessThanOrEqualTo, $comparisonType) -le 0)
            }
            return $null
        }
        'OpGreaterThan' {
            if ((canCompareStrings $Value $GreaterThan)) {
                return ([System.String]::Compare($Value, $GreaterThan, $comparisonType) -gt 0)
            }
            return $null
        }
        'OpGreaterThanOrEqualTo' {
            if ((canCompareStrings $Value $GreaterThanOrEqualTo)) {
                return ([System.String]::Compare($Value, $GreaterThanOrEqualTo, $comparisonType) -ge 0)
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

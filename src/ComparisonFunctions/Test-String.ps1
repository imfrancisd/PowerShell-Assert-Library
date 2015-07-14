function Test-String
{
    [CmdletBinding(DefaultParameterSetName = 'IsString')]
    [OutputType([System.Boolean], [System.Object])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Value,

        [Parameter(Mandatory = $false, ParameterSetName = 'IsString')]
        [System.Management.Automation.SwitchParameter]
        $IsString,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpContains')]
        [AllowNull()]
        [System.Object]
        $Contains,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpNotContains')]
        [AllowNull()]
        [System.Object]
        $NotContains,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpStartsWith')]
        [AllowNull()]
        [System.Object]
        $StartsWith,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpNotStartsWith')]
        [AllowNull()]
        [System.Object]
        $NotStartsWith,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpEndsWith')]
        [AllowNull()]
        [System.Object]
        $EndsWith,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpNotEndsWith')]
        [AllowNull()]
        [System.Object]
        $NotEndsWith,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpEquals')]
        [AllowNull()]
        [Alias('eq')]
        [System.Object]
        $Equals,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpNotEquals')]
        [AllowNull()]
        [Alias('ne')]
        [System.Object]
        $NotEquals,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpLessThan')]
        [AllowNull()]
        [Alias('lt')]
        [System.Object]
        $LessThan,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpLessThanOrEqualTo')]
        [AllowNull()]
        [Alias('le')]
        [System.Object]
        $LessThanOrEqualTo,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpGreaterThan')]
        [AllowNull()]
        [Alias('gt')]
        [System.Object]
        $GreaterThan,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [Alias('ge')]
        [System.Object]
        $GreaterThanOrEqualTo,

        [Parameter(Mandatory = $false, ParameterSetName = 'OpContains')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotContains')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpEndsWith')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotEndsWith')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpStartsWith')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotStartsWith')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThanOrEqualTo')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $CaseSensitive,

        [Parameter(Mandatory = $false, ParameterSetName = 'OpContains')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotContains')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpStartsWith')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotStartsWith')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpEndsWith')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotEndsWith')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThanOrEqualTo')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $FormCompatible,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Text.NormalizationForm[]]
        $Normalization
    )

    if ($CaseSensitive) {
        $comparisonType = [System.StringComparison]::Ordinal
    }
    else {
        $comparisonType = [System.StringComparison]::OrdinalIgnoreCase
    }

    $hasNormalizationConstraints = $PSBoundParameters.ContainsKey('Normalization')

    if (-not $hasNormalizationConstraints) {
        $allowedNormalizations = [System.Text.NormalizationForm[]]@(
            [System.Enum]::GetValues([System.Text.NormalizationForm])
        )
    }
    elseif (($null -eq $Normalization) -or ($Normalization.Length -eq 0)) {
        $allowedNormalizations = [System.Text.NormalizationForm[]]@()
    }
    else {
        $allowedNormalizations = [System.Text.NormalizationForm[]]@(
            [System.Enum]::GetValues([System.Text.NormalizationForm]) |
                Microsoft.PowerShell.Core\Where-Object -FilterScript {$Normalization -contains $_}
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

    #Do not use the return keyword to return the value
    #because PowerShell 2 will not properly set -OutVariable.

    switch ($PSCmdlet.ParameterSetName) {
        'IsString' {
            $result = isString $Value
            if ($PSBoundParameters.ContainsKey('IsString')) {
                ($result) -xor (-not $IsString)
                return
            }
            $result
            return
        }
        'OpContains' {
            if ((canCompareStrings $Value $Contains)) {
                ($Value.IndexOf($Contains, $comparisonType) -ge 0)
                return
            }
            $null
            return
        }
        'OpNotContains' {
            if ((canCompareStrings $Value $NotContains)) {
                ($Value.IndexOf($NotContains, $comparisonType) -lt 0)
                return
            }
            $null
            return
        }
        'OpStartsWith' {
            if ((canCompareStrings $Value $StartsWith)) {
                ($Value.StartsWith($StartsWith, $comparisonType))
                return
            }
            $null
            return
        }
        'OpNotStartsWith' {
            if ((canCompareStrings $Value $NotStartsWith)) {
                (-not $Value.StartsWith($NotStartsWith, $comparisonType))
                return
            }
            $null
            return
        }
        'OpEndsWith' {
            if ((canCompareStrings $Value $EndsWith)) {
                ($Value.EndsWith($EndsWith, $comparisonType))
                return
            }
            $null
            return
        }
        'OpNotEndsWith' {
            if ((canCompareStrings $Value $NotEndsWith)) {
                (-not $Value.EndsWith($NotEndsWith, $comparisonType))
                return
            }
            $null
            return
        }
        'OpEquals' {
            if ((canCompareStrings $Value $Equals)) {
                ([System.String]::Equals($Value, $Equals, $comparisonType))
                return
            }
            $null
            return
        }
        'OpNotEquals' {
            if ((canCompareStrings $Value $NotEquals)) {
                (-not [System.String]::Equals($Value, $NotEquals, $comparisonType))
                return
            }
            $null
            return
        }
        'OpLessThan' {
            if ((canCompareStrings $Value $LessThan)) {
                ([System.String]::Compare($Value, $LessThan, $comparisonType) -lt 0)
                return
            }
            $null
            return
        }
        'OpLessThanOrEqualTo' {
            if ((canCompareStrings $Value $LessThanOrEqualTo)) {
                ([System.String]::Compare($Value, $LessThanOrEqualTo, $comparisonType) -le 0)
                return
            }
            $null
            return
        }
        'OpGreaterThan' {
            if ((canCompareStrings $Value $GreaterThan)) {
                ([System.String]::Compare($Value, $GreaterThan, $comparisonType) -gt 0)
                return
            }
            $null
            return
        }
        'OpGreaterThanOrEqualTo' {
            if ((canCompareStrings $Value $GreaterThanOrEqualTo)) {
                ([System.String]::Compare($Value, $GreaterThanOrEqualTo, $comparisonType) -ge 0)
                return
            }
            $null
            return
        }
        default {
            throw Microsoft.PowerShell.Utility\New-Object -TypeName 'System.NotImplementedException' -ArgumentList @(
                "The ParameterSetName '$_' was not implemented."
            )
        }
    }
}

function Test-Text
{
    [CmdletBinding(DefaultParameterSetName='IsText')]
    [OutputType([System.Boolean], [System.Object])]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $Value,

        [Parameter(Mandatory=$false, ParameterSetName='IsText')]
        [System.Management.Automation.SwitchParameter]
        $IsText,

        [Parameter(Mandatory=$true, ParameterSetName='OpMatch')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $Match,

        [Parameter(Mandatory=$true, ParameterSetName='OpNotMatch')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $NotMatch,

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

        [Parameter(Mandatory=$false, ParameterSetName='OpMatch')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotMatch')]
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

        [Parameter(Mandatory=$false, ParameterSetName='OpMatch')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotMatch')]
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
        $UseCurrentCulture
    )

    if ('OpMatch', 'OpNotMatch' -contains $PSCmdlet.ParameterSetName) {
        $options = [System.Text.RegularExpressions.RegexOptions]::None
        if (-not $UseCurrentCulture) {
            $options = [System.Text.RegularExpressions.RegexOptions]($options -bor [System.Text.RegularExpressions.RegexOptions]::CultureInvariant)
        }
        if (-not $CaseSensitive) {
            $options = [System.Text.RegularExpressions.RegexOptions]($options -bor [System.Text.RegularExpressions.Regexoptions]::IgnoreCase)
        }
    } elseif ($UseCurrentCulture) {
        if ($CaseSensitive) {
            $options = [System.StringComparison]::CurrentCulture
        } else {
            $options = [System.StringComparison]::CurrentCultureIgnoreCase
        }
    } else {
        if ($CaseSensitive) {
            $options = [System.StringComparison]::InvariantCulture
        } else {
            $options = [System.StringComparison]::InvariantCultureIgnoreCase
        }
    }

    switch ($PSCmdlet.ParameterSetName) {
        'IsText' {
            $result = $Value -is [System.String]
            if ($PSBoundParameters.ContainsKey('IsText')) {
                return ($result) -xor (-not $IsText)
            }
            return $result
        }
        'OpMatch' {
            if (($Value -is [System.String]) -and ($Match -is [System.String])) {
                return ([System.Text.RegularExpressions.Regex]::IsMatch($Value, $Match, $options))
            }
            return $null
        }
        'OpNotMatch' {
            if (($Value -is [System.String]) -and ($NotMatch -is [System.String])) {
                return (-not [System.Text.RegularExpressions.Regex]::IsMatch($Value, $NotMatch, $options))
            }
            return $null
        }
        'OpContains' {
            if (($Value -is [System.String]) -and ($Contains -is [System.String])) {
                return ($Value.IndexOf($Contains, $options) -ge 0)
            }
            return $null
        }
        'OpNotContains' {
            if (($Value -is [System.String]) -and ($NotContains -is [System.String])) {
                return ($Value.IndexOf($NotContains, $options) -lt 0)
            }
            return $null
        }
        'OpStartsWith' {
            if (($Value -is [System.String]) -and ($StartsWith -is [System.String])) {
                return ($Value.StartsWith($StartsWith, $options))
            }
            return $null
        }
        'OpNotStartsWith' {
            if (($Value -is [System.String]) -and ($NotStartsWith -is [System.String])) {
                return (-not $Value.StartsWith($NotStartsWith, $options))
            }
            return $null
        }
        'OpEndsWith' {
            if (($Value -is [System.String]) -and ($EndsWith -is [System.String])) {
                return ($Value.EndsWith($EndsWith, $options))
            }
            return $null
        }
        'OpNotEndsWith' {
            if (($value -is [System.String]) -and ($NotEndsWith -is [System.String])) {
                return (-not $Value.EndsWith($NotEndsWith, $options))
            }
            return $null
        }
        'OpEquals' {
            if (($Value -is [System.String]) -and ($Equals -is [System.String])) {
                return ([System.String]::Equals($Value, $Equals, $options))
            }
            return $null
        }
        'OpNotEquals' {
            if (($Value -is [System.String]) -and ($NotEquals -is [System.String])) {
                return (-not [System.String]::Equals($Value, $NotEquals, $options))
            }
            return $null
        }
        'OpLessThan' {
            if (($Value -is [System.String]) -and ($LessThan -is [System.String])) {
                return ([System.String]::Compare($Value, $LessThan, $options) -lt 0)
            }
            return $null
        }
        'OpLessThanOrEqualTo' {
            if (($Value -is [System.String]) -and ($LessThanOrEqualTo -is [System.String])) {
                return ([System.String]::Compare($Value, $LessThanOrEqualTo, $options) -le 0)
            }
            return $null
        }
        'OpGreaterThan' {
            if (($Value -is [System.String]) -and ($GreaterThan -is [System.String])) {
                return ([System.String]::Compare($Value, $GreaterThan, $options) -gt 0)
            }
            return $null
        }
        'OpGreaterThanOrEqualTo' {
            if (($Value -is [System.String]) -and ($GreaterThanOrEqualTo -is [System.String])) {
                return ([System.String]::Compare($Value, $GreaterThanOrEqualTo, $options) -ge 0)
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

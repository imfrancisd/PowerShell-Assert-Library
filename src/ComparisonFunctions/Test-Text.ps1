function Test-Text
{
    [CmdletBinding(DefaultParameterSetName = 'IsText')]
    [OutputType([System.Boolean], [System.Object])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Value,

        [Parameter(Mandatory = $false, ParameterSetName = 'IsText')]
        [System.Management.Automation.SwitchParameter]
        $IsText,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpMatch')]
        [AllowNull()]
        [System.Object]
        $Match,

        [Parameter(Mandatory = $true, ParameterSetName = 'OpNotMatch')]
        [AllowNull()]
        [System.Object]
        $NotMatch,

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

        [Parameter(Mandatory = $false, ParameterSetName = 'OpMatch')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotMatch')]
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

        [Parameter(Mandatory = $false, ParameterSetName = 'OpMatch')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotMatch')]
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
    }
    elseif ($UseCurrentCulture) {
        if ($CaseSensitive) {
            $options = [System.StringComparison]::CurrentCulture
        }
        else {
            $options = [System.StringComparison]::CurrentCultureIgnoreCase
        }
    }
    else {
        if ($CaseSensitive) {
            $options = [System.StringComparison]::InvariantCulture
        }
        else {
            $options = [System.StringComparison]::InvariantCultureIgnoreCase
        }
    }

    #Do not use the return keyword to return the value
    #because PowerShell 2 will not properly set -OutVariable.

    switch ($PSCmdlet.ParameterSetName) {
        'IsText' {
            $result = $Value -is [System.String]
            if ($PSBoundParameters.ContainsKey('IsText')) {
                ($result) -xor (-not $IsText)
                return
            }
            $result
            return
        }
        'OpMatch' {
            if (($Value -is [System.String]) -and ($Match -is [System.String])) {
                ([System.Text.RegularExpressions.Regex]::IsMatch($Value, $Match, $options))
                return
            }
            $null
            return
        }
        'OpNotMatch' {
            if (($Value -is [System.String]) -and ($NotMatch -is [System.String])) {
                (-not [System.Text.RegularExpressions.Regex]::IsMatch($Value, $NotMatch, $options))
                return
            }
            $null
            return
        }
        'OpContains' {
            if (($Value -is [System.String]) -and ($Contains -is [System.String])) {
                ($Value.IndexOf($Contains, $options) -ge 0)
                return
            }
            $null
            return
        }
        'OpNotContains' {
            if (($Value -is [System.String]) -and ($NotContains -is [System.String])) {
                ($Value.IndexOf($NotContains, $options) -lt 0)
                return
            }
            $null
            return
        }
        'OpStartsWith' {
            if (($Value -is [System.String]) -and ($StartsWith -is [System.String])) {
                ($Value.StartsWith($StartsWith, $options))
                return
            }
            $null
            return
        }
        'OpNotStartsWith' {
            if (($Value -is [System.String]) -and ($NotStartsWith -is [System.String])) {
                (-not $Value.StartsWith($NotStartsWith, $options))
                return
            }
            $null
            return
        }
        'OpEndsWith' {
            if (($Value -is [System.String]) -and ($EndsWith -is [System.String])) {
                ($Value.EndsWith($EndsWith, $options))
                return
            }
            $null
            return
        }
        'OpNotEndsWith' {
            if (($value -is [System.String]) -and ($NotEndsWith -is [System.String])) {
                (-not $Value.EndsWith($NotEndsWith, $options))
                return
            }
            $null
            return
        }
        'OpEquals' {
            if (($Value -is [System.String]) -and ($Equals -is [System.String])) {
                ([System.String]::Equals($Value, $Equals, $options))
                return
            }
            $null
            return
        }
        'OpNotEquals' {
            if (($Value -is [System.String]) -and ($NotEquals -is [System.String])) {
                (-not [System.String]::Equals($Value, $NotEquals, $options))
                return
            }
            $null
            return
        }
        'OpLessThan' {
            if (($Value -is [System.String]) -and ($LessThan -is [System.String])) {
                ([System.String]::Compare($Value, $LessThan, $options) -lt 0)
                return
            }
            $null
            return
        }
        'OpLessThanOrEqualTo' {
            if (($Value -is [System.String]) -and ($LessThanOrEqualTo -is [System.String])) {
                ([System.String]::Compare($Value, $LessThanOrEqualTo, $options) -le 0)
                return
            }
            $null
            return
        }
        'OpGreaterThan' {
            if (($Value -is [System.String]) -and ($GreaterThan -is [System.String])) {
                ([System.String]::Compare($Value, $GreaterThan, $options) -gt 0)
                return
            }
            $null
            return
        }
        'OpGreaterThanOrEqualTo' {
            if (($Value -is [System.String]) -and ($GreaterThanOrEqualTo -is [System.String])) {
                ([System.String]::Compare($Value, $GreaterThanOrEqualTo, $options) -ge 0)
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

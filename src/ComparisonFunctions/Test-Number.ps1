function Test-Number
{
    [CmdletBinding(DefaultParameterSetName='IsNumber')]
    [OutputType([System.Boolean], [System.Object])]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $Value,

        [Parameter(Mandatory=$false, ParameterSetName='IsNumber')]
        [System.Management.Automation.SwitchParameter]
        $IsNumber = $true,

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

        [Parameter(Mandatory=$false, ParameterSetName='OpEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThanOrEqualTo')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $MatchType,

        [Parameter(Mandatory=$false)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.String[]]
        $Type
    )

    $allowedTypes = [System.String[]]@(
        'System.Byte', 'System.SByte',
        'System.Int16', 'System.Int32', 'System.Int64',
        'System.UInt16', 'System.UInt32', 'System.UInt64',
        'System.Single', 'System.Double', 'System.Decimal','System.Numerics.BigInteger'
    )
    if ($PSBoundParameters.ContainsKey('Type')) {
        if ($null -eq $Type) {
            $allowedTypes = [System.String[]]@()
        } else {
            $allowedTypes = [System.String[]]@(
                $allowedTypes |
                    Where-Object {($Type -icontains $_) -or ($Type -icontains $_.Split('.')[-1])}
            )
        }
    }

    function isNumber($n)
    {
        if ($null -eq $n) {
            return $false
        }

        $nType = $n.GetType().FullName
        if ($nType -eq 'System.Double') {
            if (([System.Double]::IsNaN($n)) -or ([System.Double]::IsInfinity($n))) {
                return $false
            }
        }
        if ($nType -eq 'System.Single') {
            if (([System.Single]::IsNaN($n)) -or ([System.Single]::IsInfinity($n))) {
                return $false
            }
        }
        return ($allowedTypes -icontains $nType)
    }

    function canCompareNumbers($x, $y)
    {
        $areNumbers = (isNumber $x) -and (isNumber $y)
        if ($MatchType) {
            return $areNumbers -and ($x.GetType() -eq $y.GetType())
        }
        return $areNumbers
    }

    switch ($PSCmdlet.ParameterSetName) {
        'IsNumber' {
            return (isNumber $Value) -xor (-not $IsNumber)
        }
        'OpEquals' {
            if ((canCompareNumbers $Value $Equals)) {
                return ($Value -eq $Equals)
            }
            return $null
        }
        'OpNotEquals' {
            if ((canCompareNumbers $Value $NotEquals)) {
                return ($Value -ne $NotEquals)
            }
            return $null
        }
        'OpLessThan' {
            if ((canCompareNumbers $Value $LessThan)) {
                return ($Value -lt $LessThan)
            }
            return $null
        }
        'OpLessThanOrEqualTo' {
            if ((canCompareNumbers $Value $LessThanOrEqualTo)) {
                return ($Value -le $LessThanOrEqualTo)
            }
            return $null
        }
        'OpGreaterThan' {
            if ((canCompareNumbers $Value $GreaterThan)) {
                return ($Value -gt $GreaterThan)
            }
            return $null
        }
        'OpGreaterThanOrEqualTo' {
            if ((canCompareNumbers $Value $GreaterThanOrEqualTo)) {
                return ($Value -ge $GreaterThanOrEqualTo)
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

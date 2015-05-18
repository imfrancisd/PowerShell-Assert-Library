function Test-DateTime
{
    [CmdletBinding(DefaultParameterSetName='IsDateTime')]
    [OutputType([System.Boolean], [System.Object])]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $Value,

        [Parameter(Mandatory=$false, ParameterSetName='IsDateTime')]
        [System.Management.Automation.SwitchParameter]
        $IsDateTime = $true,

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
        $LessThan,

        [Parameter(Mandatory=$true, ParameterSetName='OpLessThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('le')]
        $LessThanOrEqualTo,

        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThan')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('gt')]
        $GreaterThan,

        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('ge')]
        $GreaterThanOrEqualTo,

        [Parameter(Mandatory=$false, ParameterSetName='OpEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThanOrEqualTo')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $MatchKind,

        [Parameter(Mandatory=$false)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.DateTimeKind[]]
        $Kind,

        [Parameter(Mandatory=$false, ParameterSetName='OpEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThanOrEqualTo')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.String[]]
        $Property
    )

    $hasKindConstraints = $PSBoundParameters.ContainsKey('Kind')
    $hasPropertyConstraints = $PSBoundParameters.ContainsKey('Property')

    if ($hasKindConstraints -and ($null -eq $Kind)) {
        $Kind = [System.DateTimeKind[]]@()
    }
    if ($hasPropertyConstraints -and ($null -eq $Property)) {
        $Property = [System.String[]]@()
    }
    if ($hasPropertyConstraints -and ($Property.Length -gt 0)) {
        $validProperties = [System.String[]]@(
            'Year', 'Month', 'Day', 'Hour', 'Minute', 'Second', 'Millisecond',
            'Date', 'TimeOfDay', 'DayOfWeek', 'DayOfYear', 'Ticks', 'Kind'
        )

        foreach ($item in $Property) {
            if (($validProperties -notcontains $item) -or ($item -notmatch '^[a-zA-Z]+$')) {
                throw New-Object -TypeName 'System.ArgumentException' -ArgumentList @(
                    "Invalid DateTime Property: $item.`r`n" +
                    "Use one of the following values: $($validProperties -join ', ')"
                )
            }
        }
    }

    function isDateTime($a)
    {
        $isDateTime = $a -is [System.DateTime]
        if ($hasKindConstraints) {
            $isDateTime = $isDateTime -and ($Kind -contains $a.Kind)
        }
        return $isDateTime
    }

    function compareDateTime($a, $b)
    {
        $canCompare = (isDateTime $a) -and (isDateTime $b)
        if ($MatchKind) {
            $canCompare = $canCompare -and ($a.Kind -eq $b.Kind)
        }
        if ($hasPropertyConstraints) {
            $canCompare = $canCompare -and ($Property.Length -gt 0)
        }

        if (-not $canCompare) {
            return $null
        }

        if (-not $hasPropertyConstraints) {
            return [System.DateTime]::Compare($a, $b)
        }

        $result = [System.Int32]0
        foreach ($item in $Property) {
            $result = $a.psbase.$item.CompareTo($b.psbase.$item)
            if ($result -ne 0) {
                break
            }
        }
        return $result
    }

    switch ($PSCmdlet.ParameterSetName) {
        'IsDateTime' {
            return (isDateTime $Value) -xor (-not $IsDateTime)
        }
        'OpEquals' {
            $result = compareDateTime $Value $Equals
            if ($result -is [System.Int32]) {
                return ($result -eq 0)
            }
            return $null
        }
        'OpNotEquals' {
            $result = compareDateTime $Value $NotEquals
            if ($result -is [System.Int32]) {
                return ($result -ne 0)
            }
            return $null
        }
        'OpLessThan' {
            $result = compareDateTime $Value $LessThan
            if ($result -is [System.Int32]) {
                return ($result -lt 0)
            }
            return $null
        }
        'OpLessThanOrEqualTo' {
            $result = compareDateTime $Value $LessThanOrEqualTo
            if ($result -is [System.Int32]) {
                return ($result -le 0)
            }
            return $null
        }
        'OpGreaterThan' {
            $result = compareDateTime $Value $GreaterThan
            if ($result -is [System.Int32]) {
                return ($result -gt 0)
            }
            return $null
        }
        'OpGreaterThanOrEqualTo' {
            $result = compareDateTime $Value $GreaterThanOrEqualTo
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

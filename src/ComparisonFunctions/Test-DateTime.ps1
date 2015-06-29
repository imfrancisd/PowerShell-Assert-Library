function Test-DateTime
{
    [CmdletBinding(DefaultParameterSetName = 'IsDateTime')]
    [OutputType([System.Boolean], [System.Object])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Value,

        [Parameter(Mandatory = $false, ParameterSetName = 'IsDateTime')]
        [System.Management.Automation.SwitchParameter]
        $IsDateTime,

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

        [Parameter(Mandatory = $false, ParameterSetName = 'OpEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThanOrEqualTo')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $MatchKind,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.DateTimeKind[]]
        $Kind,

        [Parameter(Mandatory = $false, ParameterSetName = 'OpEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpNotEquals')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpLessThanOrEqualTo')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThan')]
        [Parameter(Mandatory = $false, ParameterSetName = 'OpGreaterThanOrEqualTo')]
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

    #Do not use the return keyword to return the value
    #because PowerShell 2 will not properly set -OutVariable.

    switch ($PSCmdlet.ParameterSetName) {
        'IsDateTime' {
            $result = isDateTime $Value
            if ($PSBoundParameters.ContainsKey('IsDateTime')) {
                ($result) -xor (-not $IsDateTime)
                return
            }
            $result
            return
        }
        'OpEquals' {
            $result = compareDateTime $Value $Equals
            if ($result -is [System.Int32]) {
                ($result -eq 0)
                return
            }
            $null
            return
        }
        'OpNotEquals' {
            $result = compareDateTime $Value $NotEquals
            if ($result -is [System.Int32]) {
                ($result -ne 0)
                return
            }
            $null
            return
        }
        'OpLessThan' {
            $result = compareDateTime $Value $LessThan
            if ($result -is [System.Int32]) {
                ($result -lt 0)
                return
            }
            $null
            return
        }
        'OpLessThanOrEqualTo' {
            $result = compareDateTime $Value $LessThanOrEqualTo
            if ($result -is [System.Int32]) {
                ($result -le 0)
                return
            }
            $null
            return
        }
        'OpGreaterThan' {
            $result = compareDateTime $Value $GreaterThan
            if ($result -is [System.Int32]) {
                ($result -gt 0)
                return
            }
            $null
            return
        }
        'OpGreaterThanOrEqualTo' {
            $result = compareDateTime $Value $GreaterThanOrEqualTo
            if ($result -is [System.Int32]) {
                ($result -ge 0)
                return
            }
            $null
            return
        }
        default {
            throw New-Object -TypeName 'System.NotImplementedException' -ArgumentList @(
                "The ParameterSetName '$_' was not implemented."
            )
        }
    }
}

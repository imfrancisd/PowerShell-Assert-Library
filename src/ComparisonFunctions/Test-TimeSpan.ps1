function Test-TimeSpan
{
    [CmdletBinding(DefaultParameterSetName = 'IsTimeSpan')]
    [OutputType([System.Boolean], [System.Object])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [AllowNull()]
        [System.Object]
        $Value,

        [Parameter(Mandatory = $false, ParameterSetName = 'IsTimeSpan')]
        [System.Management.Automation.SwitchParameter]
        $IsTimeSpan,

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
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.String[]]
        $Property
    )

    $hasPropertyConstraints = $PSBoundParameters.ContainsKey('Property')
    if ($hasPropertyConstraints -and ($null -eq $Property)) {
        $Property = [System.String[]]@()
    }
    if ($hasPropertyConstraints -and ($Property.Length -gt 0)) {
        $validProperties = [System.String[]]@(
            'Days', 'Hours', 'Minutes', 'Seconds', 'Milliseconds', 'Ticks',
            'TotalDays', 'TotalHours', 'TotalMilliseconds', 'TotalMinutes', 'TotalSeconds'
        )

        #Since the property names are going to be used directly in code,
        #make sure property names are valid and do not contain "ignorable" characters.

        foreach ($item in $Property) {
            if (($validProperties -notcontains $item) -or ($item -notmatch '^[a-zA-Z]+$')) {
                throw New-Object -TypeName 'System.ArgumentException' -ArgumentList @(
                    "Invalid TimeSpan Property: $item.`r`n" +
                    "Use one of the following values: $($validProperties -join ', ')"
                )
            }
        }
    }

    function compareTimeSpan($a, $b)
    {
        $canCompare = ($a -is [System.TimeSpan]) -and ($b -is [System.TimeSpan])
        if ($hasPropertyConstraints) {
            $canCompare = $canCompare -and ($Property.Length -gt 0)
        }

        if (-not $canCompare) {
            return $null
        }

        if (-not $hasPropertyConstraints) {
            return [System.TimeSpan]::Compare($a, $b)
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
        'IsTimeSpan' {
            $result = $Value -is [System.TimeSpan]
            if ($PSBoundParameters.ContainsKey('IsTimeSpan')) {
                return ($result) -xor (-not $IsTimeSpan)
            }
            return $result
        }
        'OpEquals' {
            $result = compareTimeSpan $Value $Equals
            if ($result -is [System.Int32]) {
                return ($result -eq 0)
            }
            return $null
        }
        'OpNotEquals' {
            $result = compareTimeSpan $Value $NotEquals
            if ($result -is [System.Int32]) {
                return ($result -ne 0)
            }
            return $null
        }
        'OpLessThan' {
            $result = compareTimeSpan $Value $LessThan
            if ($result -is [System.Int32]) {
                return ($result -lt 0)
            }
            return $null
        }
        'OpLessThanOrEqualTo' {
            $result = compareTimeSpan $Value $LessThanOrEqualTo
            if ($result -is [System.Int32]) {
                return ($result -le 0)
            }
            return $null
        }
        'OpGreaterThan' {
            $result = compareTimeSpan $Value $GreaterThan
            if ($result -is [System.Int32]) {
                return ($result -gt 0)
            }
            return $null
        }
        'OpGreaterThanOrEqualTo' {
            $result = compareTimeSpan $Value $GreaterThanOrEqualTo
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

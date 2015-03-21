function Test-TimeSpan
{
<#
.Synopsis
An alternative to PowerShell's comparison operators when testing TimeSpan objects in unit test scenarios.
.Description
This function tests a TimeSpan object for type and equality without the implicit conversions or the filtering semantics from the PowerShell comparison operators.

This function will return one of the following values:
    $true
    $false
    $null

A return value of $null indicates an invalid test. See each parameter for specific conditions that causes this function to return $true, $false, or $null.
.Example
Test-TimeSpan $a
Returns $true if $a is a TimeSpan object.
.Example
Test-TimeSpan $a -eq $b
Returns $true if $a and $b are both TimeSpan objects with the same value.
Returns $null if $a or $b is not a TimeSpan object.
.Example
Test-TimeSpan $a -eq $b -property days, hours
Returns $true if $a and $b are both TimeSpan objects with the same days and hours values.
Returns $null if $a or $b is not a TimeSpan object.

Note that the order of the properties specified is significant. See the -Property parameter for more details.
.Inputs
System.TimeSpan
System.Object
.Outputs
System.Boolean
$null
.Notes
An example of how this function might be used in a unit test.

#recommended alias
set-alias 'timespan?' 'test-timeSpan'

assert-true (timespan? $a)
assert-true (timespan? $a -eq $b -property days, hours, minutes)
#>
    [CmdletBinding(DefaultParameterSetName='IsTimeSpan')]
    Param(
        #The value to test.
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Value,

        #Tests if the value is a TimeSpan value.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          never
        #$false         value is not a TimeSpan
        #$true          value is a TimeSpan
        [Parameter(Mandatory=$false, ParameterSetName='IsTimeSpan')]
        [System.Management.Automation.SwitchParameter]
        $IsTimeSpan,

        #Tests if the first value is equal to the second.
        #
        #The -Equals parameter has the alias -eq.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not a TimeSpan
        #$false         System.TimeSpan.Compare(TimeSpan, TimeSpan) != 0
        #$true          System.TimeSpan.Compare(TimeSpan, TimeSpan) == 0
        #
        #Note: If the -Property parameter is specified, a different comparison method is used.
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
        #$null          one or both of the values is not a TimeSpan
        #$false         System.TimeSpan.Compare(TimeSpan, TimeSpan) == 0
        #$true          System.TimeSpan.Compare(TimeSpan, TimeSpan) != 0
        #
        #Note: If the -Property parameter is specified, a different comparison method is used.
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
        #$null          one or both of the values is not a TimeSpan
        #$false         System.TimeSpan.Compare(TimeSpan, TimeSpan) >= 0
        #$true          System.TimeSpan.Compare(TimeSpan, TimeSpan) < 0
        #
        #Note: If the -Property parameter is specified, a different comparison method is used.
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
        #$null          one or both of the values is not a TimeSpan
        #$false         System.TimeSpan.Compare(TimeSpan, TimeSpan) > 0
        #$true          System.TimeSpan.Compare(TimeSpan, TimeSpan) <= 0
        #
        #Note: If the -Property parameter is specified, a different comparison method is used.
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
        #$null          one or both of the values is not a TimeSpan
        #$false         System.TimeSpan.Compare(TimeSpan, TimeSpan) <= 0
        #$true          System.TimeSpan.Compare(TimeSpan, TimeSpan) > 0
        #
        #Note: If the -Property parameter is specified, a different comparison method is used.
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
        #$null          one or both of the values is not a TimeSpan
        #$false         System.TimeSpan.Compare(TimeSpan, TimeSpan) < 0
        #$true          System.TimeSpan.Compare(TimeSpan, TimeSpan) >= 0
        #
        #Note: If the -Property parameter is specified, a different comparison method is used.
        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [Alias('ge')]
        [System.Object]
        $GreaterThanOrEqualTo,

        #Compares the TimeSpan values using the specified properties.
        #
        #Note that the order that you specify the properties is significant. The first property specified has the highest priority in the comparison, and the last property specified has the lowest priority in the comparison.
        #
        #Allowed Properties
        #------------------
        #Days, Hours, Minutes, Seconds, Milliseconds, Ticks, TotalDays, TotalHours, TotalMilliseconds, TotalMinutes, TotalSeconds
        #
        #No wildcards are allowed.
        #No calculated properties (script blocks) are allowed.
        #Specifying this parameter with a $null or an empty array causes the comparisons to return $null.
        #
        #Comparison method
        #-----------------
        #1. Start with the first property specified.
        #2. Compare the properties from the two TimeSpan objects using the CompareTo method.
        #3. If the properties are equal, repeat steps 2 and 3 with the remaining properties.
        #4. Done.
        #
        #PowerShell Note:
        #Synthetic properties are not used in comparisons.
        #For example, when the hours property is compared, an expression like $a.psbase.hours is used instead of $a.hours.
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
            return ($Value -is [System.TimeSpan])
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

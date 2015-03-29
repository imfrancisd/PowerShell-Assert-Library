function Test-DateTime
{
<#
.Synopsis
An alternative to PowerShell's comparison operators when testing DateTime objects in unit test scenarios.
.Description
This function tests a DateTime object for type and equality without the implicit conversions or the filtering semantics from the PowerShell comparison operators.

This function will return one of the following values:
    $true
    $false
    $null

A return value of $null indicates an invalid test. See each parameter for specific conditions that causes this function to return $true, $false, or $null.

Note about calendars
====================
The documentation for System.DateTime explicitly states the use of the Gregorian calendar in some of its properties. This function uses the same calendar that the System.DateTime class uses.

This function does not support the use of different calendars.

Note about time zones
=====================
The System.DateTime class has limited support for time zones. Specifically, the DateTime class can represent dates and times in UTC, local time, or some unspecified time zone.

This function does NOT normalize dates and times to a common time zone before performing comparisons.

This function does NOT take time zone information into consideration when performing comparisons.

See the -Kind and -MatchKind parameters for more details.
.Example
Test-DateTime $a
Returns $true if $a is a DateTime object.
.Example
Test-DateTime $a -kind utc
Returns $true if $a is a DateTime object with a value of utc for its Kind property.
.Example
Test-DateTime $a -eq $b
Returns $true if $a and $b are both DateTime objects with the same value (excluding the Kind property).
Returns $null if $a or $b is not a DateTime object.
.Example
Test-DateTime $a -eq $b -matchkind
Returns $true if $a and $b are both DateTime objects with the same value and the same Kind.
Returns $null if $a or $b is not a DateTime object, or $a and $b do not have the same Kind.
.Example
Test-DateTime $a -eq $b -property year, month, day
Returns $true if $a and $b are both DateTime objects with the same year, month, and day values.
Returns $null if $a or $b is not a DateTime object.

Note that the order of the properties specified is significant. See the -Property parameter for more details.
.Inputs
System.DateTime
System.Object
.Outputs
System.Boolean
$null
.Notes
An example of how this function might be used in a unit test.

#recommended alias
set-alias 'datetime?' 'test-datetime'

#if you have an assert function, you can write assertions like this
assert (datetime? $a)
assert (datetime? $a -kind utc)
assert (datetime? $a -eq $b -matchkind -kind utc, local)
assert (datetime? $a -eq $b -matchkind -kind utc, local -property year, month, day)
#>
    [CmdletBinding(DefaultParameterSetName='IsDateTime')]
    Param(
        #The value to test.
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $Value,

        #Tests if the value is a DateTime value.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          never
        #$false         value is not a DateTime*
        #$true          value is a DateTime*
        #
        #*See the -Kind and -MatchKind parameters for more details.
        [Parameter(Mandatory=$false, ParameterSetName='IsDateTime')]
        [System.Management.Automation.SwitchParameter]
        $IsDateTime = $true,

        #Tests if the first value is equal to the second.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not a DateTime*
        #$false         System.DateTime.Compare(DateTime, DateTime) != 0
        #$true          System.DateTime.Compare(DateTime, DateTime) == 0
        #
        #*See the -Kind and -MatchKind parameters for more details.
        #
        #Note: If the -Property parameter is specified, a different comparison method is used.
        [Parameter(Mandatory=$true, ParameterSetName='OpEquals')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('eq')]
        [System.Object]
        $Equals,

        #Tests if the first value is not equal to the second.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not a DateTime*
        #$false         System.DateTime.Compare(DateTime, DateTime) == 0
        #$true          System.DateTime.Compare(DateTime, DateTime) != 0
        #
        #*See the -Kind and -MatchKind parameters for more details.
        #
        #Note: If the -Property parameter is specified, a different comparison method is used.
        [Parameter(Mandatory=$true, ParameterSetName='OpNotEquals')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('ne')]
        [System.Object]
        $NotEquals,

        #Tests if the first value is less than the second.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not a DateTime*
        #$false         System.DateTime.Compare(DateTime, DateTime) >= 0
        #$true          System.DateTime.Compare(DateTime, DateTime) < 0
        #
        #*See the -Kind and -MatchKind parameters for more details.
        #
        #Note: If the -Property parameter is specified, a different comparison method is used.
        [Parameter(Mandatory=$true, ParameterSetName='OpLessThan')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('lt')]
        $LessThan,

        #Tests if the first value is less than or equal to the second.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not a DateTime*
        #$false         System.DateTime.Compare(DateTime, DateTime) > 0
        #$true          System.DateTime.Compare(DateTime, DateTime) <= 0
        #
        #*See the -Kind and -MatchKind parameters for more details.
        #
        #Note: If the -Property parameter is specified, a different comparison method is used.
        [Parameter(Mandatory=$true, ParameterSetName='OpLessThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('le')]
        $LessThanOrEqualTo,

        #Tests if the first value is greater than the second.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not a DateTime*
        #$false         System.DateTime.Compare(DateTime, DateTime) <= 0
        #$true          System.DateTime.Compare(DateTime, DateTime) > 0
        #
        #*See the -Kind and -MatchKind parameters for more details.
        #
        #Note: If the -Property parameter is specified, a different comparison method is used.
        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThan')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('gt')]
        $GreaterThan,

        #Tests if the first value is greater than or equal to the second.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not a DateTime*
        #$false         System.DateTime.Compare(DateTime, DateTime) < 0
        #$true          System.DateTime.Compare(DateTime, DateTime) >= 0
        #
        #*See the -Kind and -MatchKind parameters for more details.
        #
        #Note: If the -Property parameter is specified, a different comparison method is used.
        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('ge')]
        $GreaterThanOrEqualTo,

        #Causes the comparison of two DateTimes to return $null if they do not have the same kind.
        #
        #*See the -Kind parameter for more details.
        [Parameter(Mandatory=$false, ParameterSetName='OpEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThanOrEqualTo')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $MatchKind,

        #One or more Enums that can be used to define which kind of DateTime objects are to be considered DateTime objects.
        #
        #The Kind property of a DateTime object states whether the DateTime object is a Local time, a UTC time, or an Unspecified time.
        #
        #Note:
        #DateTime objects are not normalized to a common Kind before performing comparisons.
        #Specifying this parameter with a $null or an empty array will cause this function to treat all objects as non-DateTime objects.
        #
        #PowerShell Note:
        #Get-Date returns DateTime objects in Local time.
        #
        #For example:
        #    $local = new-object 'datetime' 2014, 1, 1, 0, 0, 0, ([datetimekind]::local)
        #    $utc   = new-object 'datetime' 2014, 1, 1, 0, 0, 0, ([datetimekind]::utc)
        #
        #    #$local  is not considered as a DateTime object
        #    #
        #    test-datetime $local -eq $utc -Kind utc
        #    test-datetime $local -eq $utc -Kind utc, unspecified
        #
        #    #$utc is not considered as a DateTime object
        #    #
        #    test-datetime $local -eq $utc -Kind local
        #    test-datetime $local -eq $utc -Kind local, unspecified
        #
        #    #$utc and $local are considered as DateTime objects
        #    #
        #    test-datetime $local -eq $utc -Kind local, utc
        #    test-datetime $local -eq $utc -Kind utc, local
        #    test-datetime $local -eq $utc -Kind utc, local, unspecified
        #    test-datetime $local -eq $utc
        #
        #WARNING
        #=======
        #If you run the example above, you will notice that $local and $utc are considered EQUAL.
        #
        #This means that the comparisons DO NOT take time zone information into consideration.
        #
        #Part of the reason for this is that DateTime objects can be used to represent many concepts of time:
        #    *a time (12:00 AM)
        #    *a date (January 1)
        #    *a date and time (January 1 12:00 AM)
        #    *a specific date and time (2015 January 1 12:00 AM)
        #    *a specific date and time at a specific place (2015 January 1 12:00 AM UTC)
        #    *a weekly date and time (Weekdays 9:00 AM)
        #    *a monthly date (every first Friday)
        #    *a yearly date (every January 1st)
        #    *and so on...
        #
        #So, the meaning of the comparisons in the example above is not,
        #    "Does $local and $utc represent the same moment in time?",
        #but
        #    "Does $local and $utc both represent the same date and time values?".
        [Parameter(Mandatory=$false)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.DateTimeKind[]]
        $Kind,

        #Compares the DateTime values using the specified properties.
        #
        #Note that the order that you specify the properties is significant. The first property specified has the highest priority in the comparison, and the last property specified has the lowest priority in the comparison.
        #
        #Allowed Properties
        #------------------
        #Year, Month, Day, Hour, Minute, Second, Millisecond, Date, TimeOfDay, DayOfWeek, DayOfYear, Ticks, Kind
        #
        #No wildcards are allowed.
        #No calculated properties are allowed.
        #Specifying this parameter with a $null or an empty array causes the comparisons to return $null.
        #
        #Comparison method
        #-----------------
        #1. Start with the first property specified.
        #2. Compare the properties from the two DateTime objects using the CompareTo method.
        #3. If the properties are equal, repeat steps 2 and 3 with the remaining properties.
        #4. Done.
        #
        #Note:
        #Synthetic properties are not used in comparisons.
        #For example, when the year property is compared, an expression like $a.psbase.year is used instead of $a.year.
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

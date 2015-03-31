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
.Parameter Value
The value to test.
.Parameter IsTimeSpan
Tests if the value is a TimeSpan value.

Return Value   Condition
------------   ---------
$null          never
$false         value is not a TimeSpan
$true          value is a TimeSpan
.Parameter Equals
Tests if the first value is equal to the second.

The -Equals parameter has the alias -eq.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a TimeSpan
$false         System.TimeSpan.Compare(TimeSpan, TimeSpan) != 0
$true          System.TimeSpan.Compare(TimeSpan, TimeSpan) == 0

Note: If the -Property parameter is specified, a different comparison method is used.
.Parameter NotEquals
Tests if the first value is not equal to the second.

The -NotEquals parameter has the alias -ne.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a TimeSpan
$false         System.TimeSpan.Compare(TimeSpan, TimeSpan) == 0
$true          System.TimeSpan.Compare(TimeSpan, TimeSpan) != 0

Note: If the -Property parameter is specified, a different comparison method is used.
.Parameter LessThan
Tests if the first value is less than the second.

The -LessThan parameter has the alias -lt.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a TimeSpan
$false         System.TimeSpan.Compare(TimeSpan, TimeSpan) >= 0
$true          System.TimeSpan.Compare(TimeSpan, TimeSpan) < 0

Note: If the -Property parameter is specified, a different comparison method is used.
.Parameter LessThanOrEqualTo
Tests if the first value is less than or equal to the second.

The -LessThanOrEqualTo parameter has the alias -le.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a TimeSpan
$false         System.TimeSpan.Compare(TimeSpan, TimeSpan) > 0
$true          System.TimeSpan.Compare(TimeSpan, TimeSpan) <= 0

Note: If the -Property parameter is specified, a different comparison method is used.
.Parameter GreaterThan
Tests if the first value is greater than the second.

The -GreaterThan parameter has the alias -gt.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a TimeSpan
$false         System.TimeSpan.Compare(TimeSpan, TimeSpan) <= 0
$true          System.TimeSpan.Compare(TimeSpan, TimeSpan) > 0

Note: If the -Property parameter is specified, a different comparison method is used.
.Parameter GreaterThanOrEqualTo
Tests if the first value is greater than or equal to the second.

The -GreaterThanOrEqualTo parameter has the alias -ge.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a TimeSpan
$false         System.TimeSpan.Compare(TimeSpan, TimeSpan) < 0
$true          System.TimeSpan.Compare(TimeSpan, TimeSpan) >= 0

Note: If the -Property parameter is specified, a different comparison method is used.
.Parameter Property
Compares the TimeSpan values using the specified properties.

Note that the order that you specify the properties is significant. The first property specified has the highest priority in the comparison, and the last property specified has the lowest priority in the comparison.

Allowed Properties
------------------
Days, Hours, Minutes, Seconds, Milliseconds, Ticks, TotalDays, TotalHours, TotalMilliseconds, TotalMinutes, TotalSeconds

No wildcards are allowed.
No calculated properties (script blocks) are allowed.
Specifying this parameter with a $null or an empty array causes the comparisons to return $null.

Comparison method
-----------------
1. Start with the first property specified.
2. Compare the properties from the two TimeSpan objects using the CompareTo method.
3. If the properties are equal, repeat steps 2 and 3 with the remaining properties.
4. Done.

PowerShell Note:
Synthetic properties are not used in comparisons.
For example, when the hours property is compared, an expression like $a.psbase.hours is used instead of $a.hours.
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

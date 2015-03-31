<#
.Synopsis
An alternative to PowerShell's comparison operators when testing Version objects in unit test scenarios.
.Description
This function tests a Version object for type and equality without the implicit conversions or the filtering semantics from the PowerShell comparison operators.

This function will return one of the following values:
    $true
    $false
    $null

A return value of $null indicates an invalid test. See each parameter for specific conditions that causes this function to return $true, $false, or $null.
.Parameter Value
The value to test.
.Parameter IsVersion
Tests if the value is a Version object.

Return Value   Condition
------------   ---------
$null          never
$false         value is not a Version object
$true          value is a Version object
.Parameter Equals
Tests if the first value is equal to the second.

The -Equals parameter has the alias -eq.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a Version object
$false         System.Version method CompareTo(Version) != 0
$true          System.Version method CompareTo(Version) == 0

Note: If the -Property parameter is specified, a different comparison method is used.
.Parameter NotEquals
Tests if the first value is not equal to the second.

The -NotEquals parameter has the alias -ne.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a Version object
$false         System.Version method CompareTo(Version) == 0
$true          System.Version method CompareTo(Version) != 0

Note: If the -Property parameter is specified, a different comparison method is used.
.Parameter LessThan
Tests if the first value is less than the second.

The -LessThan parameter has the alias -lt.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a Version object
$false         System.Version method CompareTo(Version) >= 0
$true          System.Version method CompareTo(Version) < 0

Note: If the -Property parameter is specified, a different comparison method is used.
.Parameter LessThanOrEqualTo
Tests if the first value is less than or equal to the second.

The -LessThanOrEqualTo parameter has the alias -le.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a Version object
$false         System.Version method CompareTo(Version) > 0
$true          System.Version method CompareTo(Version) <= 0

Note: If the -Property parameter is specified, a different comparison method is used.
.Parameter GreaterThan
Tests if the first value is greater than the second.

The -GreaterThan parameter has the alias -gt.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a Version object
$false         System.Version method CompareTo(Version) <= 0
$true          System.Version method CompareTo(Version) > 0

Note: If the -Property parameter is specified, a different comparison method is used.
.Parameter GreaterThanOrEqualTo
Tests if the first value is greater than or equal to the second.

The -GreaterThanOrEqualTo parameter has the alias -ge.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a Version object
$false         System.Version method CompareTo(Version) < 0
$true          System.Version method CompareTo(Version) >= 0

Note: If the -Property parameter is specified, a different comparison method is used.
.Parameter Property
Compares the Version objects using the specified properties.

Note that the order that you specify the properties is significant. The first property specified has the highest priority in the comparison, and the last property specified has the lowest priority in the comparison.

Allowed Properties
------------------
Major, Minor, Build, Revision, MajorRevision, MinorRevision

No wildcards are allowed.
No calculated properties (script blocks) are allowed.
Specifying this parameter with a $null or an empty array causes the comparisons to return $null.

Comparison method
-----------------
1. Start with the first property specified.
2. Compare the properties from the two Version objects using the CompareTo method.
3. If the properties are equal, repeat steps 2 and 3 with the remaining properties.
4. Done.

PowerShell Note:
Synthetic properties are not used in comparisons.
For example, when the build property is compared, an expression like $a.psbase.build is used instead of $a.build.
.Example
Test-Version $a
Returns $true if $a is a Version object.
.Example
Test-Version $a -eq $b
Returns $true if $a and $b are both Version objects with the same value.
Returns $null if $a or $b is not a Version object.
.Example
Test-Version $a -eq $b -property major, minor
Returns $true if $a and $b are both Version objects with the same major and minor values.
Returns $null if $a or $b is not a Version object.

Note that the order of the properties specified is significant. See the -Property parameter for more details.
.Inputs
System.Version
System.Object
.Outputs
System.Boolean
$null
.Notes
An example of how this function might be used in a unit test.

#recommended alias
set-alias 'version?' 'test-version'

assert-true (version? $a)
assert-true (version? $a -eq $b -property major, minor, build)
#>

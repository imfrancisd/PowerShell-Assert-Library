<#
.Synopsis
An alternative to PowerShell's comparison operators when testing GUIDs in unit test scenarios.
.Description
This function tests a GUID for type and equality without the implicit conversions or the filtering semantics from the PowerShell comparison operators.

This function will return one of the following values:
    $true
    $false
    $null

A return value of $null indicates an invalid test. See each parameter for specific conditions that causes this function to return $true, $false, or $null.
.Parameter Value
The value to test.
.Parameter IsGuid
Tests if the value is a GUID.

Return Value   Condition
------------   ---------
$null          never
$false         value is not a GUID*
$true          value is a GUID*

*See the -Variant and -Version parameters for more details.
.Parameter Equals
Tests if the first value is equal to the second.

The -Equals parameter has the alias -eq.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a GUID*
$false         System.Guid method CompareTo(Guid) != 0
$true          System.Guid method CompareTo(Guid) == 0

*See the -Variant and -Version parameters for more details.
.Parameter NotEquals
Tests if the first value is not equal to the second.

The -NotEquals parameter has the alias -ne.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a GUID*
$false         System.Guid method CompareTo(Guid) == 0
$true          System.Guid method CompareTo(Guid) != 0

*See the -Variant and -Version parameters for more details.
.Parameter LessThan
Tests if the first value is less than the second.

The -LessThan parameter has the alias -lt.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a GUID*
$false         System.Guid method CompareTo(Guid) >= 0
$true          System.Guid method CompareTo(Guid) < 0

*See the -Variant and -Version parameters for more details.
.Parameter LessThanOrEqualTo
Tests if the first value is less than or equal to the second.

The -LessThanOrEqualTo parameter has the alias -le.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a GUID*
$false         System.Guid method CompareTo(Guid) > 0
$true          System.Guid method CompareTo(Guid) <= 0

*See the -Variant and -Version parameters for more details.
.Parameter GreaterThan
Tests if the first value is greater than the second.

The -GreaterThan parameter has the alias -gt.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a GUID*
$false         System.Guid method CompareTo(Guid) <= 0
$true          System.Guid method CompareTo(Guid) > 0

*See the -Variant and -Version parameters for more details.
.Parameter GreaterThanOrEqualTo
Tests if the first value is greater than or equal to the second.

The -GreaterThanOrEqualTo parameter has the alias -ge.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a GUID*
$false         System.Guid method CompareTo(Guid) < 0
$true          System.Guid method CompareTo(Guid) >= 0

*See the -Variant and -Version parameters for more details.
.Parameter MatchVariant
Causes the comparison of two GUIDs to return $null if they do not have an equivalent variant.

*See the -Variant parameter for more details.
.Parameter MatchVersion
Causes the comparison of two GUIDs to return $null if they do not have the same value in their version fields.

*See the -Version parameter for more details.
.Parameter Variant
One or more Strings that can be used to define which variants of GUIDs are to be considered GUIDs.

Allowed Variants
----------------
Standard, Microsoft, NCS, Reserved

    The GUID variant field can be found in the nibble marked with v:
    00000000-0000-0000-v000-000000000000

    Variant    v
    -------    -
    Standard   8, 9, A, B
    Microsoft  C, D
    NCS        0, 1, 2, 3, 4, 5, 6, 7
    Reserved   E, F

Note:
Specifying this parameter with a $null or an empty array will cause this function to treat all objects as non-GUIDs.
.Parameter Version
One or more integers that can be used to define which versions of GUIDs are to be considered GUIDs.

Allowed Versions
----------------
0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15

    The GUID version field can be found in the nibble marked with v:
    00000000-0000-v000-0000-000000000000

    Note: The meaning of the value in the version field depends on the GUID variant.

Note:
Specifying this parameter with a $null or an empty array will cause this function to treat all objects as non-GUIDs.
.Example
Test-Guid $a
Returns $true if $a is a GUID.
.Example
Test-Guid $a -variant standard, microsoft
Returns $true if $a is a standard variant GUID or a Microsoft Backward Compatibility variant GUID.

See the -Variant parameter for more details.
.Example
Test-Guid $a -variant standard -version 1, 4
Returns $true if $a is a standard variant GUID, with a value of 1 or 4 in its version field.

See the -Variant and -Version parameters for more details.
.Example
Test-Guid $a -lt $b
Returns $true if $a is less than $b, and $a and $b are both GUIDs.
Returns $null if $a or $b is not a GUID.
.Example
Test-Guid $a -lt $b -matchvariant
Returns $true if $a is less than $b, and $a and $b have equivalent values in their variant field.
Returns $null if $a or $b is not a GUID, or $a and $b do not have equivalent values in their variant field.

See the -MatchVariant and -Variant parameters for more details.
.Example
Test-Guid $a -lt $b -variant standard -matchversion
Returns $true if $a is less than $b, and both $a and $b are standard variant GUIDs with the same value in their version field.
Returns $null if $a or $b is not a standard variant GUID, or $a and $b do not have the same value in their version field.
.Inputs
None

This function does not accept input from the pipeline.
.Outputs
System.Boolean

This function returns a Boolean if the test can be performed.
.Outputs
$null

This function returns $null if the test cannot be performed.
.Notes
An example of how this function might be used in a unit test.

#recommended alias
set-alias 'guid?' 'test-guid'

assert-true (guid? $a)
assert-true (guid? $a -variant standard -version 1,3,4,5)
assert-true (guid? $a -ne $b -variant standard -version 1,3,4,5 -matchvariant -matchversion)
.Link
Test-DateTime
.Link
Test-Number
.Link
Test-String
.Link
Test-Text
.Link
Test-TimeSpan
.Link
Test-Version
#>

<#
.Synopsis
An alternative to PowerShell's comparison functions when testing strings in unit test scenarios.
.Description
This function tests a string for type and equality without the implicit conversions and filtering semantics of the PowerShell comparison operators.

This function also gives you some control over how strings should be compared. See the -Normalization and -FormCompatible parameters for more details.

This function will return one of the following values:
    $true
    $false
    $null

A return value of $null indicates an invalid test. See each parameter for specific conditions that causes this function to return $true, $false, or $null.

Note about comparison
---------------------
This function uses the Equals and Compare methods from the String class using an ordinal comparison type. This type of comparison will compare strings at the binary level, and this type of comparison is not affected by the user's culture or language settings.

By default this function uses a case-insensitive comparison, but this can be changed by setting the -CaseSensitive switch.

Note about normalization
------------------------
This function does not normalize strings to a common form before performing comparisons.

This is done so that minor deviations from the strings being tested will be detected from unit tests. This is especially important if the strings being tested represent things like file paths or registry keys.

Differences with PowerShell string comparison
---------------------------------------------
For case-sensitive string comparisons, this function may give a different result than the PowerShell comparison operators.

    #PowerShell returns $true
    'A' -cgt 'a'

    #Test-String returns $false
    Test-String 'A' -gt 'a' -CaseSensitive
    
    #String.Compare returns $false
    [string]::compare('A', 'a', [stringcomparison]::Ordinal) -gt 0

    #Int values of characters; returns $false
    [int][char]'A' -gt [int][char]'a'
.Parameter Value
The value to test.
.Parameter IsString
Tests if the value is a string.

Return Value   Condition
------------   ---------
$null          never
$false         the value is not a string*
$true          the value is a string*

*See the -Normalization parameter for more details
.Parameter Contains
Tests if the first string contains the second.

Note: The empty string is inside all strings.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a string*
$false         String method IndexOf(String, StringComparison) < 0
$true          String method IndexOf(String, StringComparison) >= 0

*See the -Normalization parameter for more details
.Parameter NotContains
Tests if the string does not contain the second.

Note: The empty string is inside all strings.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a string*
$false         String method IndexOf(String, StringComparison) >= 0
$true          String method IndexOf(String, StringComparison) < 0

*See the -Normalization parameter for more details
.Parameter StartsWith
Tests if the first string starts with the second string.

Note: The empty string starts all strings.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a string*
$false         String method StartsWith(String, StringComparison) returns $false
$true          String method StartsWith(String, StringComparison) returns $true

*See the -Normalization parameter for more details
.Parameter NotStartsWith
Tests if the first string does not start with the second string.

Note: The empty string starts all strings.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a string*
$false         String method StartsWith(String, StringComparison) returns $true
$true          String method StartsWith(String, StringComparison) returns $false

*See the -Normalization parameter for more details
.Parameter EndsWith
Tests if the first string ends with the second string.

Note: The empty string ends all strings.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a string*
$false         String method EndsWith(String, StringComparison) returns $false
$true          String method EndsWith(String, StringComparison) returns $true

*See the -Normalization parameter for more details
.Parameter NotEndsWith
Tests if the first string does not end with the second string

Note: The empty string ends all strings.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a string*
$false         String method EndsWith(String, StringComparison) returns $true
$true          String method EndsWith(String, StringComparison) returns $false

*See the -Normalization parameter for more details
.Parameter Equals
Tests if the first value is equal to the second.

The -Equals parameter has the alias -eq.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a string*
$false         String.Equals(String, String, StringComparison) returns $false
$true          String.Equals(String, String, StringComparison) returns $true

*See the -Normalization parameter for more details
.Parameter NotEquals
Tests if the first value is not equal to the second.

The -NotEquals parameter has the alias -ne.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a string*
$false         String.Equals(String, String, StringComparison) returns $true
$true          String.Equals(String, String, StringComparison) returns $false

*See the -Normalization parameter for more details
.Parameter LessThan
Tests if the first value is less than the second.

The -LessThan parameter has the alias -lt.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a string*
$false         String.Compare(String, String, StringComparison) >= 0
$true          String.Compare(String, String, StringComparison) < 0

*See the -Normalization parameter for more details
.Parameter LessThanOrEqualTo
Tests if the first value is less than or equal to the second.

The -LessThanOrEqualTo parameter has the alias -le.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a string*
$false         String.Compare(String, String, StringComparison) > 0
$true          String.Compare(String, String, StringComparison) <= 0

*See the -Normalization parameter for more details
.Parameter GreaterThan
Tests if the first value is greater than the second.

The -GreaterThan parameter has the alias -gt.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a string*
$false         String.Compare(String, String, StringComparison) <= 0
$true          String.Compare(String, String, StringComparison) > 0

*See the -Normalization parameter for more details
.Parameter GreaterThanOrEqualTo
Tests if the first value is greater than or equal to the second.

The -GreaterThanOrEqualTo parameter has the alias -ge.

Return Value   Condition
------------   ---------
$null          one or both of the values is not a string*
$false         String.Compare(String, String, StringComparison) < 0
$true          String.Compare(String, String, StringComparison) >= 0

*See the -Normalization parameter for more details
.Parameter CaseSensitive
Makes the comparisons case sensitive.

If this switch is set, the comparisons use

    [System.StringComparison]::Ordinal

otherwise, the comparisons use

    [System.StringComparison]::OrdinalIgnoreCase

as the default.
.Parameter FormCompatible
Causes the comparison of two strings to return $null if they are not normalized to compatible forms.

See the -Normalization parameter for more details.
.Parameter Normalization
One or more Enums that can be used to define which form of strings are to be considered strings.

Normalization is a way of making sure that a Unicode character will only have one binary representation. This allows strings to be compared using only their binary representations. Comparing strings using only their binary representation is often desirable in scripts and programs because these comparisons are not affected by the rules of different cultures and languages.

The Normalization Forms are: FormC, FormD, FormKC, and FormKD.

You can use this parameter to specify which of the forms above a string must have in order for the string to be considered a string.

Note:
* Specifying this parameter with a $null or an empty array will cause this function to treat all objects as non-strings.

* This function does not normalize strings to a common form before performing the comparison.

Reference:
For more details, see the MSDN documentation for the System.String methods called Normalize() and IsNormalized().
.Example
Test-String $a
Tests if $a is a string.
.Example
Test-String $a -eq $b
Tests if $a is equal to $b using a case-insensitive test.

Returns the result of ([string]::Equals($a, $b, [stringcomparison]::ordinalignorecase)) if $a and $b are strings.
Returns $null if $a or $b is not a string.
.Example
Test-String $a -eq $b -CaseSensitive
Tests if $a is equal to $b using a case-sensitive test.

Returns the result of ([string]::Equals($a, $b, [stringcomparison]::ordinal)) if $a and $b are strings.
Returns $null if $a or $b is not a string.
.Example
Test-String $a -Normalization FormC
Returns $true if $a is a string that is compatible with Normalization FormC.
Returns $false if $a is not a string that is compatible with Normalization FormC.

NOTE: See the -Normalization parameter for more details.
.Example
Test-String $a -eq $b -FormCompatible
Returns the result of (Test-String $a -eq $b) if $a has a compatible Normalization Form with $b.
Returns $null if $a does not have a compatible Normalization with $b.

NOTE: See the -Normalization parameter for more details.
.Example
Test-String $a -eq $b -FormCompatible -Normalization FormKC, FormKD
Returns the result of (Test-String $a -eq $b -FormCompatible) if $a and $b are strings that are compatible with Normalization FormKC or Normalization FormKD.
Returns $null if $a or $b is not a string that is compatible with Normalization FormKC or Normalization FormKD.

NOTE: See the -Normalization parameter for more details.
.Inputs
System.String
System.Object
.Outputs
System.Boolean
$null
.Notes
An example of how this function might be used in a unit test.

#recommended alias
set-alias 'string?' 'test-string'

#if you have an assert function, you can write assertions like this
assert (string? $a)
assert (string? $a -contains $b)
assert (string? $a -notStartsWith $c -casesensitive -formcompatible)
#>

<#
.Synopsis
An alternative to PowerShell's comparison operators when texts are being tested in unit test scenarios with operators that are sensitive to culture and language.
.Description
This function contains text operators that are sensitive to language and culture. These operators are: Match, NotMatch, Contains, NotContains, StartsWith, NotStartsWith, EndsWith, NotEndsWith, Equals, NotEquals, LessThan, GreaterThan, LessThanOrEqualTo, and GreaterThanOrEqualTo.

This function will return one of the following values:
    $true
    $false
    $null

A return value of $null indicates an invalid operation. See each parameter for specific conditions that causes this function to return $true, $false, or $null.

The default for this function is to use case-insensitive operations using InvariantCulture. See the -CaseSensitive and -UseCurrentCulture parameters for more details.

Note about language and culture
===============================

All the operators mentioned above will be affected by the different rules of languages and cultures. From the MSDN documentation, it seems that the regular expression operators (Match and NotMatch) are the only operators listed above that cannot be used in a way that is not sensitive to language or culture.

Use Test-String if you want text operators that are not affected by language and culture.
.Parameter Value
The value to test.
.Parameter IsText
Tests if the value is text.

Return Value   Condition
------------   ---------
$null          never
$false         value is not of type System.String
$true          value is of type System.String
.Parameter Match
Tests if the first value matches the regular expression pattern in the second.

Return Value   Condition
------------   ---------
$null          one or both of the values is not of type System.String
$false         Regex.IsMatch(String, String, RegexOptions) returns $false
$true          Regex.IsMatch(String, String, RegexOptions) returns $true

*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
.Parameter NotMatch
Tests if the first value does not match the regular expression pattern in the second.

Return Value   Condition
------------   ---------
$null          one or both of the values is not of type System.String
$false         Regex.IsMatch(String, String, RegexOptions) returns $true
$true          Regex.IsMatch(String, String, RegexOptions) returns $false

*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
.Parameter Contains
Tests if the first value contains the second.

Note: The empty string is inside all texts.

Return Value   Condition
------------   ---------
$null          one or both of the values is not of type System.String
$false         String method IndexOf(String, StringComparison) < 0
$true          String method IndexOf(String, StringComparison) >= 0

*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
.Parameter NotContains
Tests if the first value does not contain the second.

Note: The empty string is inside all texts.

Return Value   Condition
------------   ---------
$null          one or both of the values is not of type System.String
$false         String method IndexOf(String, StringComparison) >= 0
$true          String method IndexOf(String, StringComparison) < 0

*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
.Parameter StartsWith
Tests if the first value starts with the second.

Note: The empty string starts all texts.

Return Value   Condition
------------   ---------
$null          one or both of the values is not of type System.String
$false         String method StartsWith(String, StringComparison) returns $false
$true          String method StartsWith(String, StringComparison) returns $true

*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
.Parameter NotStartsWith
Tests if the first value does not start with the second.

Note: The empty string starts all texts.

Return Value   Condition
------------   ---------
$null          one or both of the values is not of type System.String
$false         String method StartsWith(String, StringComparison) returns $true
$true          String method StartsWith(String, StringComparison) returns $false

*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
.Parameter EndsWith
Tests if the first value ends with the second.

Note: The empty string ends all texts.

Return Value   Condition
------------   ---------
$null          one or both of the values is not of type System.String
$false         String method EndsWith(String, StringComparison) returns $false
$true          String method EndsWith(String, StringComparison) returns $true

*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
.Parameter NotEndsWith
Tests if the first value does not end with the second.

Note: The empty string ends all texts.

Return Value   Condition
------------   ---------
$null          one or both of the values is not of type System.String
$false         String method EndsWith(String, StringComparison) returns $true
$true          String method EndsWith(String, StringComparison) returns $false

*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
.Parameter Equals
Tests if the first value is equal to the second.

The -Equals parameter has the alias -eq.

Return Value   Condition
------------   ---------
$null          one or both of the values is not of type System.String
$false         String.Equals(String, String, StringComparison) returns $false
$true          String.Equals(String, String, StringComparison) returns $true

*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
.Parameter NotEquals
Tests if the first value is not equal to the second.

The -NotEquals parameter has the alias -ne.

Return Value   Condition
------------   ---------
$null          one or both of the values is not of type System.String
$false         String.Equals(String, String, StringComparison) returns $true
$true          String.Equals(String, String, StringComparison) returns $false

*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
.Parameter LessThan
Tests if the first value is less than the second.

The -LessThan parameter has the alias -lt.

Return Value   Condition
------------   ---------
$null          one or both of the values is not of type System.String
$false         String.Compare(String, String, StringComparison) >= 0
$true          String.Compare(String, String, StringComparison) < 0

*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
.Parameter LessThanOrEqualTo
Tests if the first value is less than or equal to the second.

The -LessThanOrEqualTo parameter has the alias -le.

Return Value   Condition
------------   ---------
$null          one or both of the values is not of type System.String
$false         String.Compare(String, String, StringComparison) > 0
$true          String.Compare(String, String, StringComparison) <= 0

*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
.Parameter GreaterThan
Tests if the first value is greater than the second.

The -GreaterThan parameter has the alias -gt.

Return Value   Condition
------------   ---------
$null          one or both of the values is not of type System.String
$false         String.Compare(String, String, StringComparison) <= 0
$true          String.Compare(String, String, StringComparison) > 0

*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
.Parameter GreaterThanOrEqualTo
Tests if the first value is greater than or equal to the second.

The -GreaterThanOrEqualTo parameter has the alias -ge.

Return Value   Condition
------------   ---------
$null          one or both of the values is not of type System.String
$false         String.Compare(String, String, StringComparison) < 0
$true          String.Compare(String, String, StringComparison) >= 0

*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
.Parameter CaseSensitive
Makes the operators case-sensitive.

If this parameter is not specified, the operators will be case-insensitive.

*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
.Parameter UseCurrentCulture
Makes the operators use the language rules of the current culture.

If this parameter is not specified, the operators will use the language rules from System.Globalization.CultureInfo.InvariantCulture. Operators using InvariantCulture will give the same results when the operations are run in different computers.

Note that the culture (including InvariantCulture) defines rules such as the ordering of the characters, the casing of the characters, and disturbingly, rules such as which characters can be ignored in text operations. This means that two string that are equal in one culture may not be equal in another culture. Even operations using InvariantCulture can compare two strings of different lengths as equal because the strings contain characters which are considered ignorable by the culture.

See the MSDN documentation for System.Globalization.CultureInfo for more information.
.Example
Test-Text $a
Returns $true if $a is text (an object of type System.String).
.Example
Test-Text $a -eq $b
Returns $true if $a and $b contains text that are equal according to the rules of InvariantCulture.
Returns $null if $a or $b is not text.
.Example
Test-Text $a -eq $b -CaseSensitive -UseCurrentCulture
Returns $true if $a and $b contains text that are equal (both in content and in case) according to the rules of the culture currently being used by PowerShell.
Returns $null if $a or $b is not text.
.Example
Test-Text $a -match $b
Returns $true if the text in $a matches the regular expression pattern in $b (case-insensitive match) according to the rules of InvariantCulture.
Returns $null if $a or $b is not text.
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
set-alias 'text?' 'test-text'

#if you have an assert function, you can write assertions like this
assert (text? $greeting)
assert (text? $greeting -match '[chj]ello world')
assert (text? $greeting -startswith 'Hello' -casesensitive -usecurrentculture)
.Link
Test-DateTime
.Link
Test-Guid
.Link
Test-Number
.Link
Test-String
.Link
Test-TimeSpan
.Link
Test-Version
#>

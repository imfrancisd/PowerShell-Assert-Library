function Test-Text
{
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

If you want text operators that are not affected by language and culture, see the script in the following link:
    A PowerShell String Testing Function - Update
    https://gallery.technet.microsoft.com/scriptcenter/A-PowerShell-String-5ea692a6
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
System.String
System.Object
.Outputs
System.Boolean
$null
.Notes
An example of how this function might be used in a unit test.

#recommended alias
set-alias 'text?' 'test-text'

#if you have an assert function, you can write assertions like this
assert (text? $greeting)
assert (text? $greeting -match '[chj]ello world')
assert (text? $greeting -startswith 'Hello' -casesensitive -usecurrentculture)
#>
    [CmdletBinding(DefaultParameterSetName='IsText')]
    Param(
        #The value to test.
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $Value,

        #Tests if the value is text.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          never
        #$false         value is not of type System.String
        #$true          value is of type System.String
        [Parameter(Mandatory=$false, ParameterSetName='IsText')]
        [System.Management.Automation.SwitchParameter]
        $IsText = $true,

        #Tests if the first value matches the regular expression pattern in the second.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not of type System.String
        #$false         Regex.IsMatch(String, String, RegexOptions) returns $false
        #$true          Regex.IsMatch(String, String, RegexOptions) returns $true
        #
        #*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
        [Parameter(Mandatory=$true, ParameterSetName='OpMatch')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $Match,

        #Tests if the first value does not match the regular expression pattern in the second.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not of type System.String
        #$false         Regex.IsMatch(String, String, RegexOptions) returns $true
        #$true          Regex.IsMatch(String, String, RegexOptions) returns $false
        #
        #*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
        [Parameter(Mandatory=$true, ParameterSetName='OpNotMatch')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $NotMatch,

        #Tests if the first value contains the second.
        #
        #Note: The empty string is inside all texts.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not of type System.String
        #$false         String method IndexOf(String, StringComparison) < 0
        #$true          String method IndexOf(String, StringComparison) >= 0
        #
        #*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
        [Parameter(Mandatory=$true, ParameterSetName='OpContains')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $Contains,

        #Tests if the first value does not contain the second.
        #
        #Note: The empty string is inside all texts.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not of type System.String
        #$false         String method IndexOf(String, StringComparison) >= 0
        #$true          String method IndexOf(String, StringComparison) < 0
        #
        #*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
        [Parameter(Mandatory=$true, ParameterSetName='OpNotContains')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $NotContains,

        #Tests if the first value starts with the second.
        #
        #Note: The empty string starts all texts.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not of type System.String
        #$false         String method StartsWith(String, StringComparison) returns $false
        #$true          String method StartsWith(String, StringComparison) returns $true
        #
        #*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
        [Parameter(Mandatory=$true, ParameterSetName='OpStartsWith')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $StartsWith,

        #Tests if the first value does not start with the second.
        #
        #Note: The empty string starts all texts.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not of type System.String
        #$false         String method StartsWith(String, StringComparison) returns $true
        #$true          String method StartsWith(String, StringComparison) returns $false
        #
        #*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
        [Parameter(Mandatory=$true, ParameterSetName='OpNotStartsWith')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $NotStartsWith,

        #Tests if the first value ends with the second.
        #
        #Note: The empty string ends all texts.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not of type System.String
        #$false         String method EndsWith(String, StringComparison) returns $false
        #$true          String method EndsWith(String, StringComparison) returns $true
        #
        #*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
        [Parameter(Mandatory=$true, ParameterSetName='OpEndsWith')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $EndsWith,

        #Tests if the first value does not end with the second.
        #
        #Note: The empty string ends all texts.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not of type System.String
        #$false         String method EndsWith(String, StringComparison) returns $true
        #$true          String method EndsWith(String, StringComparison) returns $false
        #
        #*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
        [Parameter(Mandatory=$true, ParameterSetName='OpNotEndsWith')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $NotEndsWith,

        #Tests if the first value is equal to the second.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not of type System.String
        #$false         String.Equals(String, String, StringComparison) returns $false
        #$true          String.Equals(String, String, StringComparison) returns $true
        #
        #*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
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
        #$null          one or both of the values is not of type System.String
        #$false         String.Equals(String, String, StringComparison) returns $true
        #$true          String.Equals(String, String, StringComparison) returns $false
        #
        #*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
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
        #$null          one or both of the values is not of type System.String
        #$false         String.Compare(String, String, StringComparison) >= 0
        #$true          String.Compare(String, String, StringComparison) < 0
        #
        #*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
        [Parameter(Mandatory=$true, ParameterSetName='OpLessThan')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('lt')]
        [System.Object]
        $LessThan,

        #Tests if the first value is less than or equal to the second.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not of type System.String
        #$false         String.Compare(String, String, StringComparison) > 0
        #$true          String.Compare(String, String, StringComparison) <= 0
        #
        #*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
        [Parameter(Mandatory=$true, ParameterSetName='OpLessThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('le')]
        [System.Object]
        $LessThanOrEqualTo,

        #Tests if the first value is greater than the second.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not of type System.String
        #$false         String.Compare(String, String, StringComparison) <= 0
        #$true          String.Compare(String, String, StringComparison) > 0
        #
        #*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThan')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('gt')]
        [System.Object]
        $GreaterThan,

        #Tests if the first value is greater than or equal to the second.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not of type System.String
        #$false         String.Compare(String, String, StringComparison) < 0
        #$true          String.Compare(String, String, StringComparison) >= 0
        #
        #*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('ge')]
        [System.Object]
        $GreaterThanOrEqualTo,

        #Makes the operators case-sensitive.
        #
        #If this parameter is not specified, the operators will be case-insensitive.
        #
        #*See the -UseCurrentCulture parameter for details about how language and culture can affect this parameter.
        [Parameter(Mandatory=$false, ParameterSetName='OpMatch')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotMatch')]
        [Parameter(Mandatory=$false, ParameterSetName='OpContains')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotContains')]
        [Parameter(Mandatory=$false, ParameterSetName='OpEndsWith')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEndsWith')]
        [Parameter(Mandatory=$false, ParameterSetName='OpStartsWith')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotStartsWith')]
        [Parameter(Mandatory=$false, ParameterSetName='OpEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThanOrEqualTo')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $CaseSensitive,

        #Makes the operators use the language rules of the current culture.
        #
        #If this parameter is not specified, the operators will use the language rules from System.Globalization.CultureInfo.InvariantCulture. Operators using InvariantCulture will give the same results when the operations are run in different computers.
        #
        #Note that the culture (including InvariantCulture) defines rules such as the ordering of the characters, the casing of the characters, and disturbingly, rules such as which characters can be ignored in text operations. This means that two string that are equal in one culture may not be equal in another culture. Even operations using InvariantCulture can compare two strings of different lengths as equal because the strings contain characters which are considered ignorable by the culture.
        #
        #See the MSDN documentation for System.Globalization.CultureInfo for more information.
        [Parameter(Mandatory=$false, ParameterSetName='OpMatch')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotMatch')]
        [Parameter(Mandatory=$false, ParameterSetName='OpContains')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotContains')]
        [Parameter(Mandatory=$false, ParameterSetName='OpEndsWith')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEndsWith')]
        [Parameter(Mandatory=$false, ParameterSetName='OpStartsWith')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotStartsWith')]
        [Parameter(Mandatory=$false, ParameterSetName='OpEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThanOrEqualTo')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $UseCurrentCulture
    )

    if ('OpMatch', 'OpNotMatch' -contains $PSCmdlet.ParameterSetName) {
        $options = [System.Text.RegularExpressions.RegexOptions]::None
        if (-not $UseCurrentCulture) {
            $options = [System.Text.RegularExpressions.RegexOptions]($options -bor [System.Text.RegularExpressions.RegexOptions]::CultureInvariant)
        }
        if (-not $CaseSensitive) {
            $options = [System.Text.RegularExpressions.RegexOptions]($options -bor [System.Text.RegularExpressions.Regexoptions]::IgnoreCase)
        }
    } elseif ($UseCurrentCulture) {
        if ($CaseSensitive) {
            $options = [System.StringComparison]::CurrentCulture
        } else {
            $options = [System.StringComparison]::CurrentCultureIgnoreCase
        }
    } else {
        if ($CaseSensitive) {
            $options = [System.StringComparison]::InvariantCulture
        } else {
            $options = [System.StringComparison]::InvariantCultureIgnoreCase
        }
    }

    switch ($PSCmdlet.ParameterSetName) {
        'IsText' {
            return ($Value -is [System.String]) -xor (-not $IsText)
        }
        'OpMatch' {
            if (($Value -is [System.String]) -and ($Match -is [System.String])) {
                return ([System.Text.RegularExpressions.Regex]::IsMatch($Value, $Match, $options))
            }
            return $null
        }
        'OpNotMatch' {
            if (($Value -is [System.String]) -and ($NotMatch -is [System.String])) {
                return (-not [System.Text.RegularExpressions.Regex]::IsMatch($Value, $NotMatch, $options))
            }
            return $null
        }
        'OpContains' {
            if (($Value -is [System.String]) -and ($Contains -is [System.String])) {
                return ($Value.IndexOf($Contains, $options) -ge 0)
            }
            return $null
        }
        'OpNotContains' {
            if (($Value -is [System.String]) -and ($NotContains -is [System.String])) {
                return ($Value.IndexOf($NotContains, $options) -lt 0)
            }
            return $null
        }
        'OpStartsWith' {
            if (($Value -is [System.String]) -and ($StartsWith -is [System.String])) {
                return ($Value.StartsWith($StartsWith, $options))
            }
            return $null
        }
        'OpNotStartsWith' {
            if (($Value -is [System.String]) -and ($NotStartsWith -is [System.String])) {
                return (-not $Value.StartsWith($NotStartsWith, $options))
            }
            return $null
        }
        'OpEndsWith' {
            if (($Value -is [System.String]) -and ($EndsWith -is [System.String])) {
                return ($Value.EndsWith($EndsWith, $options))
            }
            return $null
        }
        'OpNotEndsWith' {
            if (($value -is [System.String]) -and ($NotEndsWith -is [System.String])) {
                return (-not $Value.EndsWith($NotEndsWith, $options))
            }
            return $null
        }
        'OpEquals' {
            if (($Value -is [System.String]) -and ($Equals -is [System.String])) {
                return ([System.String]::Equals($Value, $Equals, $options))
            }
            return $null
        }
        'OpNotEquals' {
            if (($Value -is [System.String]) -and ($NotEquals -is [System.String])) {
                return (-not [System.String]::Equals($Value, $NotEquals, $options))
            }
            return $null
        }
        'OpLessThan' {
            if (($Value -is [System.String]) -and ($LessThan -is [System.String])) {
                return ([System.String]::Compare($Value, $LessThan, $options) -lt 0)
            }
            return $null
        }
        'OpLessThanOrEqualTo' {
            if (($Value -is [System.String]) -and ($LessThanOrEqualTo -is [System.String])) {
                return ([System.String]::Compare($Value, $LessThanOrEqualTo, $options) -le 0)
            }
            return $null
        }
        'OpGreaterThan' {
            if (($Value -is [System.String]) -and ($GreaterThan -is [System.String])) {
                return ([System.String]::Compare($Value, $GreaterThan, $options) -gt 0)
            }
            return $null
        }
        'OpGreaterThanOrEqualTo' {
            if (($Value -is [System.String]) -and ($GreaterThanOrEqualTo -is [System.String])) {
                return ([System.String]::Compare($Value, $GreaterThanOrEqualTo, $options) -ge 0)
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

function Test-Number
{
<#
.Synopsis
An alternative to PowerShell's comparison operators when testing numbers in unit test scenarios.
.Description
This function tests a number for type and equality without the filtering semantics of the PowerShell comparison operators.

This function also gives you some control over how different types of numbers should be compared. See the -Type and -MatchType parameters for more details.

This function will return one of the following values:
    $true
    $false
    $null

A return value of $null indicates an invalid test. See each parameter for specific conditions that causes this function to return $true, $false, or $null.

Note:
NaN, PositiveInfinity, and NegativeInfinity are not considered to be numbers by this function.
.Example
Test-Number $n
Tests if $n is a number.
.Example
Test-Number $n -Type Int32
Tests if $n is a number of type Int32.
.Example
Test-Number $n -Type Int32, Double, Decimal
Tests if $n is a number of type Int32, Double, or Decimal.
.Example
Test-Number $x -lt $y
Returns the result of ($x -lt $y) if $x and $y are numbers.
Returns $null if $x or $y is not a number.
.Example
Test-Number $x -lt $y -MatchType
Returns the result of ($x -lt $y) if $x and $y are numbers of the same type.
Returns $null if $x or $y is not a number, or $x and $y do not have the same type.
.Example
Test-Number $x -lt $y -Type Int32, Int64, Double
Returns the result of ($x -lt $y) if both $x and $y are numbers of type Int32, Int64, or Double.
Returns $null if $x or $y is not of type Int32, Int64, or Double.
.Inputs
System.Byte
System.SByte
System.Int16
System.Int32
System.Int64
System.UInt16
System.UInt32
System.UInt64
System.Single
System.Double
System.Decimal
System.Numerics.BigInteger
System.Object
.Outputs
System.Boolean
$null
.Notes
An example of how this function might be used in a unit test.

#recommended alias
set-alias 'number?' 'test-number'

#if you have an assert function, you can write assertions like this
assert (number? $n)
assert (number? $x -lt $y)
assert (number? $x -lt $y -MatchType)
assert (number? $x -lt $y -Type Int32, Int64, Decimal, Double)
assert (number? $x -lt $y -Type Int32, Int64, Decimal, Double -MatchType)
#>
    [CmdletBinding(DefaultParameterSetName='OpIsNumber')]
    Param(
        #The value to test.
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $Value,

        #Tests if the value is a number.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          never
        #$false         value is not a number*
        #$true          value is a number*
        #
        #* See -Type parameter for more details.
        [Parameter(Mandatory=$false, ParameterSetName='OpIsNumber')]
        [System.Management.Automation.SwitchParameter]
        $IsNumber,

        #Tests if the first value is equal to the second.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not a number*
        #               -MatchType is set and values are not of the same type
        #$false         PowerShell's -eq operator returns $false
        #$true          PowerShell's -eq operator returns $true
        #
        #* See -Type parameter for more details.
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
        #$null          one or both of the values is not a number*
        #               -MatchType is set and values are not of the same type
        #$false         PowerShell's -ne operator returns $false
        #$true          PowerShell's -ne operator returns $true
        #
        #* See -Type parameter for more details.
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
        #$null          one or both of the values is not a number*
        #               -MatchType is set and values are not of the same type
        #$false         PowerShell's -lt operator returns $false
        #$true          PowerShell's -lt operator returns $true
        #
        #* See -Type parameter for more details.
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
        #$null          one or both of the values is not a number*
        #               -MatchType is set and values are not of the same type
        #$false         PowerShell's -le operator returns $false
        #$true          PowerShell's -le operator returns $true
        #
        #* See -Type parameter for more details.
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
        #$null          one or both of the values is not a number*
        #               -MatchType is set and values are not of the same type
        #$false         PowerShell's -gt operator returns $false
        #$true          PowerShell's -gt operator returns $true
        #
        #* See -Type parameter for more details.
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
        #$null          one or both of the values is not a number*
        #               -MatchType is set and values are not of the same type
        #$false         PowerShell's -ge operator returns $false
        #$true          PowerShell's -ge operator returns $true
        #
        #* See -Type parameter for more details.
        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('ge')]
        [System.Object]
        $GreaterThanOrEqualTo,

        #Causes the comparison of two numbers to return $null if they do not have the same type.
        [Parameter(Mandatory=$false, ParameterSetName='OpEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThanOrEqualTo')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $MatchType,

        #One or more strings that can be used to define which numeric types are to be considered numeric types.
        #
        #These types are considered to be numeric types:
        #   System.Byte, System.SByte,
        #   System.Int16, System.Int32, System.Int64,
        #   System.UInt16, System.UInt32, System.UInt64,
        #   System.Single, System.Double, System.Decimal, System.Numerics.BigInteger
        #
        #You can use this parameter to specify which of the types above are to be considered numeric types.
        #
        #Each type can be specified by its type name or by its full type name.
        #
        #Note:
        #NaN, PositiveInfinity, and NegativeInfinity are never considered to be numbers by this function.
        #Specifying this parameter with a $null or an empty array will cause this function to treat all objects as non-numbers.
        #
        #For example:
        #    $a = [uint32]0
        #    $b = [double]10.0
        #
        #    #$a (uint32) is not considered a number
        #    #
        #    Test-Number $a -lt $b -Type Double
        #    Test-Number $a -lt $b -Type Double, Decimal
        #    Test-Number $a -lt $b -Type Double, Decimal, Int32
        #    Test-Number $a -lt $b -Type Double, Decimal, System.Int32
        #
        #    #$b (double) is not considered a number
        #    #
        #    Test-Number $a -lt $b -Type UInt32
        #    Test-Number $a -lt $b -Type UInt32, Byte
        #    Test-Number $a -lt $b -Type UInt32, Byte, Int64
        #    Test-Number $a -lt $b -Type UInt32, System.Byte, Int64
        #
        #    #$a and $b are considered numbers
        #    #
        #    Test-Number $a -lt $b
        #    Test-Number $a -lt $b -Type UInt32, Double
        #    Test-Number $a -lt $b -Type Double, UInt32
        #    Test-Number $a -lt $b -Type Byte, Double, System.SByte, System.UInt32
        [Parameter(Mandatory=$false)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.String[]]
        $Type
    )

    $allowedTypes = [System.String[]]@(
        'System.Byte', 'System.SByte',
        'System.Int16', 'System.Int32', 'System.Int64',
        'System.UInt16', 'System.UInt32', 'System.UInt64',
        'System.Single', 'System.Double', 'System.Decimal','System.Numerics.BigInteger'
    )
    if ($PSBoundParameters.ContainsKey('Type')) {
        if ($null -eq $Type) {
            $allowedTypes = [System.String[]]@()
        } else {
            $allowedTypes = [System.String[]]@(
                $allowedTypes |
                    Where-Object {($Type -icontains $_) -or ($Type -icontains $_.Split('.')[-1])}
            )
        }
    }

    function isNumber($n)
    {
        if ($null -eq $n) {
            return $false
        }

        $nType = $n.GetType().FullName
        if ($nType -eq 'System.Double') {
            if (([System.Double]::IsNaN($n)) -or ([System.Double]::IsInfinity($n))) {
                return $false
            }
        }
        if ($nType -eq 'System.Single') {
            if (([System.Single]::IsNaN($n)) -or ([System.Single]::IsInfinity($n))) {
                return $false
            }
        }
        return ($allowedTypes -icontains $nType)
    }

    function canCompareNumbers($x, $y)
    {
        $areNumbers = (isNumber $x) -and (isNumber $y)
        if ($MatchType) {
            return $areNumbers -and ($x.GetType() -eq $y.GetType())
        }
        return $areNumbers
    }

    switch ($PSCmdlet.ParameterSetName) {
        'OpIsNumber' {
            return (isNumber $Value)
        }
        'OpEquals' {
            if ((canCompareNumbers $Value $Equals)) {
                return ($Value -eq $Equals)
            }
            return $null
        }
        'OpNotEquals' {
            if ((canCompareNumbers $Value $NotEquals)) {
                return ($Value -ne $NotEquals)
            }
            return $null
        }
        'OpLessThan' {
            if ((canCompareNumbers $Value $LessThan)) {
                return ($Value -lt $LessThan)
            }
            return $null
        }
        'OpLessThanOrEqualTo' {
            if ((canCompareNumbers $Value $LessThanOrEqualTo)) {
                return ($Value -le $LessThanOrEqualTo)
            }
            return $null
        }
        'OpGreaterThan' {
            if ((canCompareNumbers $Value $GreaterThan)) {
                return ($Value -gt $GreaterThan)
            }
            return $null
        }
        'OpGreaterThanOrEqualTo' {
            if ((canCompareNumbers $Value $GreaterThanOrEqualTo)) {
                return ($Value -ge $GreaterThanOrEqualTo)
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
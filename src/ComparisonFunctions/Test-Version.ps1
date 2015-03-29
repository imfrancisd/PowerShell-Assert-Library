function Test-Version
{
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
    [CmdletBinding(DefaultParameterSetName='IsVersion')]
    Param(
        #The value to test.
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Value,

        #Tests if the value is a Version object.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          never
        #$false         value is not a Version object
        #$true          value is a Version object
        [Parameter(Mandatory=$false, ParameterSetName='IsVersion')]
        [System.Management.Automation.SwitchParameter]
        $IsVersion = $true,

        #Tests if the first value is equal to the second.
        #
        #The -Equals parameter has the alias -eq.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not a Version object
        #$false         System.Version method CompareTo(Version) != 0
        #$true          System.Version method CompareTo(Version) == 0
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
        #$null          one or both of the values is not a Version object
        #$false         System.Version method CompareTo(Version) == 0
        #$true          System.Version method CompareTo(Version) != 0
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
        #$null          one or both of the values is not a Version object
        #$false         System.Version method CompareTo(Version) >= 0
        #$true          System.Version method CompareTo(Version) < 0
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
        #$null          one or both of the values is not a Version object
        #$false         System.Version method CompareTo(Version) > 0
        #$true          System.Version method CompareTo(Version) <= 0
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
        #$null          one or both of the values is not a Version object
        #$false         System.Version method CompareTo(Version) <= 0
        #$true          System.Version method CompareTo(Version) > 0
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
        #$null          one or both of the values is not a Version object
        #$false         System.Version method CompareTo(Version) < 0
        #$true          System.Version method CompareTo(Version) >= 0
        #
        #Note: If the -Property parameter is specified, a different comparison method is used.
        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [Alias('ge')]
        [System.Object]
        $GreaterThanOrEqualTo,

        #Compares the Version objects using the specified properties.
        #
        #Note that the order that you specify the properties is significant. The first property specified has the highest priority in the comparison, and the last property specified has the lowest priority in the comparison.
        #
        #Allowed Properties
        #------------------
        #Major, Minor, Build, Revision, MajorRevision, MinorRevision
        #
        #No wildcards are allowed.
        #No calculated properties (script blocks) are allowed.
        #Specifying this parameter with a $null or an empty array causes the comparisons to return $null.
        #
        #Comparison method
        #-----------------
        #1. Start with the first property specified.
        #2. Compare the properties from the two Version objects using the CompareTo method.
        #3. If the properties are equal, repeat steps 2 and 3 with the remaining properties.
        #4. Done.
        #
        #PowerShell Note:
        #Synthetic properties are not used in comparisons.
        #For example, when the build property is compared, an expression like $a.psbase.build is used instead of $a.build.
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
            'Major', 'Minor', 'Build', 'Revision', 'MajorRevision', 'MinorRevision'
        )

        #Since the property names are going to be used directly in code,
        #make sure property names are valid and do not contain "ignorable" characters.

        foreach ($item in $Property) {
            if (($validProperties -notcontains $item) -or ($item -notmatch '^[a-zA-Z]+$')) {
                throw New-Object -TypeName 'System.ArgumentException' -ArgumentList @(
                    "Invalid Version Property: $item.`r`n" +
                    "Use one of the following values: $($validProperties -join ', ')"
                )
            }
        }
    }

    function compareVersion($a, $b)
    {
        $canCompare = ($a -is [System.Version]) -and ($b -is [System.Version])
        if ($hasPropertyConstraints) {
            $canCompare = $canCompare -and ($Property.Length -gt 0)
        }

        if (-not $canCompare) {
            return $null
        }

        if (-not $hasPropertyConstraints) {
            return $a.psbase.CompareTo($b)
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
        'IsVersion' {
            return ($Value -is [System.Version]) -xor (-not $IsVersion)
        }
        'OpEquals' {
            $result = compareVersion $Value $Equals
            if ($result -is [System.Int32]) {
                return ($result -eq 0)
            }
            return $null
        }
        'OpNotEquals' {
            $result = compareVersion $Value $NotEquals
            if ($result -is [System.Int32]) {
                return ($result -ne 0)
            }
            return $null
        }
        'OpLessThan' {
            $result = compareVersion $Value $LessThan
            if ($result -is [System.Int32]) {
                return ($result -lt 0)
            }
            return $null
        }
        'OpLessThanOrEqualTo' {
            $result = compareVersion $Value $LessThanOrEqualTo
            if ($result -is [System.Int32]) {
                return ($result -le 0)
            }
            return $null
        }
        'OpGreaterThan' {
            $result = compareVersion $Value $GreaterThan
            if ($result -is [System.Int32]) {
                return ($result -gt 0)
            }
            return $null
        }
        'OpGreaterThanOrEqualTo' {
            $result = compareVersion $Value $GreaterThanOrEqualTo
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

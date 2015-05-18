function Group-ListItem
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, ParameterSetName='Pair')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Pair,

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, ParameterSetName='Window')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Window,

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, ParameterSetName='Combine')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Combine,

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, ParameterSetName='Permute')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Permute,

        [Parameter(Mandatory=$false, ValueFromPipeline=$false, ParameterSetName='Combine')]
        [Parameter(Mandatory=$false, ValueFromPipeline=$false, ParameterSetName='Permute')]
        [Parameter(Mandatory=$false, ValueFromPipeline=$false, ParameterSetName='Window')]
        [System.Int32]
        $Size,

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, ParameterSetName='CoveringArray')]
        [AllowEmptyCollection()]
        [ValidateNotNull()]
        [System.Collections.IList[]]
        $CoveringArray,

        [Parameter(Mandatory=$false, ValueFromPipeline=$false, ParameterSetName='CoveringArray')]
        [System.Int32]
        $Strength,

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, ParameterSetName='CartesianProduct')]
        [AllowEmptyCollection()]
        [ValidateNotNull()]
        [System.Collections.IList[]]
        $CartesianProduct,

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, ParameterSetName='Zip')]
        [AllowEmptyCollection()]
        [ValidateNotNull()]
        [System.Collections.IList[]]
        $Zip
    )

    #NOTE about [ValidateNotNull()]
    #
    #The ValidateNotNull() attribute validates that a list and its contents are not $null.
    #The -Combine, -Permute, -Pair, and -Window parameters NOT having this attribute and
    #-CartesianProduct, -CoveringArray and -Zip having this attribute, is intentional.
    #
    #Mandatory=$true will make sure -Combine, -Permute, -Pair, and -Window are not $null.

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    function getListLength($list)
    {
        if ($list -is [System.Array]) {
            return $list.psbase.Length
        }
        if ($list -is [System.Collections.IList]) {
            return $list.psbase.Count
        }
        return 0
    }

    function getElementType($list)
    {
        #NOTE about compatibility
        #
        #In PowerShell, it is possible to override properties and methods of an object.
        #
        #The psbase property in all objects allows access to the real properties and methods.
        #
        #In PowerShell 4 (and possibly PowerShell 3) however, the psbase property does not
        #allow access to the "real" GetType method of the object. Instead, .psbase.GetType()
        #returns the type of the psbase object instead of the type of the object that psbase
        #represents.
        #
        #Explicit .NET reflection must be used if you want to make sure that you are calling
        #the "real" GetType method in PowerShell 4 (and possibly PowerShell 3).

        $objectGetType = [System.Object].GetMethod('GetType', [System.Type]::EmptyTypes)
        $genericIList = [System.Type]::GetType('System.Collections.Generic.IList`1')

        if ($list -is [System.Array]) {
            return $objectGetType.Invoke($list, $null).GetElementType()
        }
        if ($list -is [System.Collections.IList]) {
            $IListGenericTypes = @(
                $objectGetType.Invoke($list, $null).GetInterfaces() |
                Where-Object -FilterScript {
                    $_.IsGenericType -and ($_.GetGenericTypeDefinition() -eq $genericIList)
                }
            )

            if ($IListGenericTypes.Length -eq 1) {
                return $IListGenericTypes[0].GetGenericArguments()[0]
            }
        }
        return [System.Object]
    }

    switch ($PSCmdlet.ParameterSetName) {
        'Pair' {
            $listLength = getListLength $Pair
            $outputElementType = getElementType $Pair

            $count = $listLength - 1

            for ($i = 0; $i -lt $count; $i++) {
                #generate pair
                $items = [System.Array]::CreateInstance($outputElementType, 2)
                $items[0] = $Pair[$i]
                $items[1] = $Pair[$i + 1]

                #output pair
                New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                    'Items' = $items
                }
            }

            return
        }
        'Window' {
            $listLength = getListLength $Window
            $outputElementType = getElementType $Window

            if (-not $PSBoundParameters.ContainsKey('Size')) {
                $Size = $listLength
            }

            if ($Size -eq 0) {
                New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                    'Items' = [System.Array]::CreateInstance($outputElementType, 0)
                }
                return
            }
            if (($Size -lt 0) -or ($listLength -lt $Size)) {
                return
            }

            $count = $listLength - $Size + 1

            for ($i = 0; $i -lt $count; $i++) {
                #generate window
                $items = [System.Array]::CreateInstance($outputElementType, $Size)
                for ($j = 0; $j -lt $Size; $j++) {
                    $items[$j] = $Window[$j + $i]
                }

                #output window
                New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                    'Items' = $items
                }
            }

            return
        }
        'Combine' {
            $listLength = getListLength $Combine
            $outputElementType = getElementType $Combine

            if (-not $PSBoundParameters.ContainsKey('Size')) {
                $Size = $listLength
            }

            if ($Size -eq 0) {
                New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                    'Items' = [System.Array]::CreateInstance($outputElementType, 0)
                }
                return
            }
            if (($Size -lt 0) -or ($listLength -lt $Size)) {
                return
            }

            #Generate the combinations.
            #Store $Size amount of indices in an array, and increment those indices
            #in way that generates the combinations.
            #
            #The array of indices is conceptually a counter with special rules:
            #  *indices in counter are in range [0..length of list]
            #  *indices in counter are strictly increasing

            #initialize counter
            $counter = [System.Array]::CreateInstance([System.Int32], $Size)
            for ($i = 0; $i -lt $Size; $i++) {
                $counter[$i] = $i
            }

            while ($counter[-1] -lt $listLength) {
                #generate combination
                $items = [System.Array]::CreateInstance($outputElementType, $Size)
                for ($i = 0; $i -lt $Size; $i++) {
                    $items[$i] = $Combine[$counter[$i]]
                }

                #output combination
                New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                    'Items' = $items
                }

                #increment counter
                for ($i = $Size - 1; $i -ge 0; $i--) {
                    $counter[$i]++
                    if ($counter[$i] -le ($listLength - $Size + $i)) {
                        for ($i++; $i -lt $Size; $i++) {
                            $counter[$i] = $counter[$i - 1] + 1
                        }
                        break
                    }
                }
            }

            return
        }
        'Permute' {
            $listLength = getListLength $Permute
            $outputElementType = getElementType $Permute

            if (-not $PSBoundParameters.ContainsKey('Size')) {
                $Size = $listLength
            }

            if ($Size -eq 0) {
                New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                    'Items' = [System.Array]::CreateInstance($outputElementType, 0)
                }
                return
            }
            if (($Size -lt 0) -or ($listLength -lt $Size)) {
                return
            }

            #Generate the permutations.
            #Store $Size amount of indices in an array, and increment those indices
            #in way that generates the permutations.
            #
            #The array of indices is conceptually a counter with special rules:
            #  *indices in counter are in range [0..length of list]
            #  *indices in counter that are less than length of list are unique

            $counter = [System.Array]::CreateInstance([System.Int32], $Size)
            $usedIndices = @{}

            #initialize counter
            for ($i = 0; $i -lt $Size; $i++) {
                $counter[$i] = $i
                $usedIndices.Add($i, $null)
            }

            while ($counter[0] -lt $listLength) {
                #generate permutation
                $items = [System.Array]::CreateInstance($outputElementType, $Size)
                for ($i = 0; $i -lt $Size; $i++) {
                    $items[$i] = $Permute[$counter[$i]]
                }

                #output permutation
                New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                    'Items' = $items
                }

                #increment counter
                for ($i = $Size - 1; $i -ge 0; $i--) {
                    $usedIndices.Remove($counter[$i])
                    for ($counter[$i]++; $counter[$i] -lt $listLength; $counter[$i]++) {
                        if (-not $usedIndices.ContainsKey($counter[$i])) {
                            $usedIndices.Add($counter[$i], $null)
                            break
                        }
                    }

                    if ($counter[$i] -lt $listLength) {
                        for ($i++; $i -lt $Size; $i++) {
                            for ($counter[$i] = 0; $counter[$i] -lt $listLength; $counter[$i]++) {
                                if (-not $usedIndices.ContainsKey($counter[$i])) {
                                    $usedIndices.Add($counter[$i], $null)
                                    break
                                }
                            }
                        }
                        break
                    }
                }
            }

            return
        }
        'CartesianProduct' {
            $listCount = getListLength $CartesianProduct

            if ($listCount -lt 1) {
                return
            }

            #Get all the lengths of the list and
            #determine the type to use to constrain the output array.

            $listLengths = [System.Array]::CreateInstance([System.Int32], $listCount)
            $elementTypes = [System.Array]::CreateInstance([System.Type], $listCount)

            for ($i = 0; $i -lt $listCount; $i++) {
                $listLengths[$i] = getListLength $CartesianProduct[$i]
                $elementTypes[$i] = getElementType $CartesianProduct[$i]
            }

            if (@($listLengths | Sort-Object)[0] -lt 1) {
                return
            }

            if (@($elementTypes | Sort-Object -Unique).Length -eq 1) {
                $outputElementType = $elementTypes[0]
            } else {
                $outputElementType = [System.Object]
            }

            #Generate the cartesian products of the lists.
            #Store an index for each list in an array, and increment those
            #indices in way that generates the cartesian products.
            #
            #The array of indices is conceptually a counter with special rules:
            #  *indices are in range [0..length of list associated with index]

            $counter = [System.Array]::CreateInstance([System.Int32], $listCount)

            while ($counter[0] -lt $listLengths[0]) {
                $i = $listCount - 1

                for (; $counter[$i] -lt $listLengths[$i]; $counter[$i]++) {
                    #generate cartesian product
                    $items = [System.Array]::CreateInstance($outputElementType, $listCount)
                    for ($j = 0; $j -lt $listCount; $j++) {
                        $items[$j] = $CartesianProduct[$j][$counter[$j]]
                    }

                    #output cartesian product
                    New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                        'Items' = $items
                    }
                }

                #update counter
                for (; ($i -gt 0) -and ($counter[$i] -ge $listLengths[$i]); $i--) {
                    $counter[$i] = 0
                    $counter[$i - 1]++
                }
            }

            return
        }
        'Zip' {
            $listCount = getListLength $Zip

            if ($listCount -lt 1) {
                return
            }

            #Get all the lengths of the list and
            #determine the type to use to constrain the output array.

            $listLengths = [System.Array]::CreateInstance([System.Int32], $listCount)
            $elementTypes = [System.Array]::CreateInstance([System.Type], $listCount)

            for ($i = 0; $i -lt $listCount; $i++) {
                $listLengths[$i] = getListLength $Zip[$i]
                $elementTypes[$i] = getElementType $Zip[$i]
            }

            $minlistlength = @($listLengths | Sort-Object)[0]

            if (@($elementTypes | Sort-Object -Unique).Length -eq 1) {
                $outputElementType = $elementTypes[0]
            } else {
                $outputElementType = [System.Object]
            }

            #Generate the "Zip" of the lists by
            #grouping the items in each list with the same index.

            for ($i = 0; $i -lt $minListLength; $i++) {
                #generate the "Zip"
                $items = [System.Array]::CreateInstance($outputElementType, $listCount)
                for ($j = 0; $j -lt $listCount; $j++) {
                    $items[$j] = $Zip[$j][$i]
                }

                #output the "Zip"
                New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                    'Items' = $items
                }
            }

            return
        }
        'CoveringArray' {
            $listCount = getListLength $CoveringArray

            if ($listCount -lt 1) {
                return
            }

            if (-not $PSBoundParameters.ContainsKey('Strength')) {
                $Strength = $listCount
            }
            if ($Strength -lt 1) {
                return
            }

            #A Covering array with the highest strength possible is the Cartesian product
            if ($Strength -ge $listCount) {
                & $PSCmdlet.MyInvocation.MyCommand.ScriptBlock -CartesianProduct $CoveringArray
                return
            }

            #Get all the lengths of the list and
            #determine the type to use to constrain the output array.

            $listLengths = [System.Array]::CreateInstance([System.Int32], $listCount)
            $elementTypes = [System.Array]::CreateInstance([System.Type], $listCount)

            for ($i = 0; $i -lt $listCount; $i++) {
                $listLengths[$i] = getListLength $CoveringArray[$i]
                $elementTypes[$i] = getElementType $CoveringArray[$i]
            }

            if (@($listLengths | Sort-Object)[0] -lt 1) {
                return
            }

            if (@($elementTypes | Sort-Object -Unique).Length -eq 1) {
                $outputElementType = $elementTypes[0]
            } else {
                $outputElementType = [System.Object]
            }

            #If -Strength is 1, then the covering array is a modified version of -Zip.
            #The important thing is all values in the lists are used 1 or more times.

            if ($Strength -eq 1) {
                $maxListLength = @($listLengths | Sort-Object -Descending)[0]

                for ($i = 0; $i -lt $maxListLength; $i++) {
                    #generate a row in the covering array
                    $items = [System.Array]::CreateInstance($outputElementType, $listCount)
                    for ($j = 0; $j -lt $listCount; $j++) {
                        $items[$j] = $CoveringArray[$j][$i % $listLengths[$j]]
                    }

                    #output the row
                    New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                        'Items' = $items
                    }
                }

                return
            }

            #=======================================================
            #At this stage, the following must be true:
            #    0 < $Strength < $listCount
            #    all lists have at least one item
            #=======================================================

            #Generate the covering array by filtering the Cartesian product of the lists.
            #
            #Store an index for each list in an array, and increment those
            #indices in way that generates the cartesian product.
            #
            #The array of indices is conceptually a counter with special rules:
            #  *indices are in range [0..length of list associated with index]
            #
            #Filter the Cartesian product by removing any row that does not have at least
            #one unused column combination.

            $counter = [System.Array]::CreateInstance([System.Int32], $listCount)

            $usedCombinations = @{}

            #Generate a row if the value of counter has at least one new column combination.
            #
            #If $counter is {10, 20, 30, 40} and strength is 2, then the combinations are:
            #
            #    {10, 20} {10, 30} {10, 40} {20, 30} {20, 40} {30, 40}
            #
            #and they'll be converted into the following strings:
            #
            #    "0 10 20 " "1 10 30 " "2 10 40 " "3 20 30 " "4 20 40 " "5 30 40 "
            #
            #with the first number in the string being the index of the combination.

            $f = '{0:D} '
            $s = New-Object -TypeName 'System.Text.StringBuilder'

            while ($counter[0] -lt $listLengths[0]) {
                $i = $listCount - 1

                for (; $counter[$i] -lt $listLengths[$i]; $counter[$i]++) {
                    $hasNewCombination = $false

                    $combinations = @(& $PSCmdlet.MyInvocation.MyCommand.ScriptBlock -Combine $counter -Size $Strength)
                    for ($j = $combinations.Length - 1; $j -ge 0; $j--) {
                        $s.Length = 0
                        [System.Void]$s.AppendFormat($f, $j)
                        foreach ($item in $combinations[$j].Items) {
                            [System.Void]$s.AppendFormat($f, $item)
                        }

                        $combinations[$j] = $s.ToString()

                        $hasNewCombination =
                            ($hasNewCombination) -or
                            (-not $usedCombinations.Contains($combinations[$j]))
                    }

                    if ($hasNewCombination) {
                        #add column combinations to $usedCombinations
                        foreach ($item in $combinations) {
                            $usedCombinations[$item] = $null
                        }

                        #generate cartesian product
                        $items = [System.Array]::CreateInstance($outputElementType, $listCount)
                        for ($j = 0; $j -lt $listCount; $j++) {
                            $items[$j] = $CoveringArray[$j][$counter[$j]]
                        }

                        #output cartesian product
                        New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{
                            'Items' = $items
                        }
                    }
                }

                #update counter
                for (; ($i -gt 0) -and ($counter[$i] -ge $listLengths[$i]); $i--) {
                    $counter[$i] = 0
                    $counter[$i - 1]++
                }
            }

            return
        }
        default {
            $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                (New-Object -TypeName 'System.NotImplementedException' -ArgumentList @("The ParameterSetName '$_' was not implemented.")),
                'NotImplemented',
                [System.Management.Automation.ErrorCategory]::NotImplemented,
                $null
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }
}

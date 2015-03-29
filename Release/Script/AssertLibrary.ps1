<#
The MIT License (MIT)

Copyright (c) 2015 Francis de la Cerna

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

#>

#Assert Library version 1.0.0.8
#
#PowerShell requirements
#requires -version 2.0

function Assert-False
{
<#
.Synopsis
Assert that a value is the Boolean value $false.
.Description
This function throws an error if any of the following conditions are met:
    *the value being asserted is $null
    *the value being asserted is not of type System.Boolean
    *the value being asserted is not $false
.Example
Assert-False ($a -eq $b)
Throws an error if the expression ($a -eq $b) does not evaluate to $false.
.Example
Assert-False ($a -eq $b) -Verbose
Throws an error if the expression ($a -eq $b) does not evaluate to $false.
The -Verbose switch will output the result of the assertion to the Verbose stream.
.Example
Assert-False ($a -eq $b) -Debug
Throws an error if the expression ($a -eq $b) does not evaluate to $false.
The -Debug switch gives you a chance to investigate a failing assertion before an error is thrown.
.Inputs
System.Boolean
System.Object
.Outputs
None
.Notes
An example of how this function might be used in a unit test.

#display passing assertions
$VerbosePreference = [System.Management.Automation.ActionPreference]::Continue

#display debug prompt on failing assertions
$DebugPreference = [System.Management.Automation.ActionPreference]::Inquire

Assert-False ($null -eq $a)
Assert-False ($null -eq $b)
Assert-False ($a -eq $b)
.Link
Assert-True
Assert-Null
Assert-NotNull
Assert-PipelineEmpty
Assert-PipelineAny
Assert-PipelineSingle
Assert-PipelineCount
#>
    [CmdletBinding()]
    Param(
        #The value to assert.
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
        if ($null -eq $VerbosePreference) {
            $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
        }
    }

    $fail = -not (($Value -is [System.Boolean]) -and (-not $Value))

    if ($fail -or ($VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue)) {
        $message = 'Assertion {0}: {1}, file {2}, line {3}' -f @(
            $(if ($fail) {'failed'} else {'passed'}),
            $MyInvocation.Line.Trim(),
            $MyInvocation.ScriptName,
            $MyInvocation.ScriptLineNumber
        )

        Write-Verbose -Message $message

        if ($fail) {
            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference]
                if ($null -eq $DebugPreference) {
                    $DebugPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                }
            }
            Write-Debug -Message $message

            $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                (New-Object -TypeName 'System.Exception' -ArgumentList @($message)),
                'AssertionFailed',
                [System.Management.Automation.ErrorCategory]::OperationStopped,
                $Value
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }
}

function Assert-NotNull
{
<#
.Synopsis
Assert that a value is not $null.
.Description
This function throws an error if any of the following conditions are met:
    *the value being asserted is $null
.Example
Assert-NotNull $a
Throws an error if $a evaluates to $null.
.Example
Assert-NotNull $a -Verbose
Throws an error if $a evaluates to $null.
The -Verbose switch will output the result of the assertion to the Verbose stream.
.Example
Assert-NotNull $a -Debug
Throws an error if $a evaluates to $null.
The -Debug switch gives you a chance to investigate a failing assertion before an error is thrown.
.Inputs
System.Object
.Outputs
None
.Notes
An example of how this function might be used in a unit test.

#display passing assertions
$VerbosePreference = [System.Management.Automation.ActionPreference]::Continue

#display debug prompt on failing assertions
$DebugPreference = [System.Management.Automation.ActionPreference]::Inquire

Assert-NotNull $a
Assert-NotNull $b
Assert-NotNull $c
.Link
Assert-True
Assert-False
Assert-Null
Assert-PipelineEmpty
Assert-PipelineAny
Assert-PipelineSingle
Assert-PipelineCount
#>
    [CmdletBinding()]
    Param(
        #The value to assert.
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
        if ($null -eq $VerbosePreference) {
            $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
        }
    }

    $fail = $null -eq $Value

    if ($fail -or ($VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue)) {
        $message = 'Assertion {0}: {1}, file {2}, line {3}' -f @(
            $(if ($fail) {'failed'} else {'passed'}),
            $MyInvocation.Line.Trim(),
            $MyInvocation.ScriptName,
            $MyInvocation.ScriptLineNumber
        )

        Write-Verbose -Message $message

        if ($fail) {
            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference]
                if ($null -eq $DebugPreference) {
                    $DebugPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                }
            }
            Write-Debug -Message $message

            $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                (New-Object -TypeName 'System.Exception' -ArgumentList @($message)),
                'AssertionFailed',
                [System.Management.Automation.ErrorCategory]::OperationStopped,
                $Value
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }
}

function Assert-Null
{
<#
.Synopsis
Assert that a value is $null.
.Description
This function throws an error if any of the following conditions are met:
    *the value being asserted is not $null
.Example
Assert-Null $a
Throws an error if $a does not evaluate to $null.
.Example
Assert-Null $a -Verbose
Throws an error if $a does not evaluate to $null.
The -Verbose switch will output the result of the assertion to the Verbose stream.
.Example
Assert-Null $a -Debug
Throws an error if $a does not evaluate to $null.
The -Debug switch gives you a chance to investigate a failing assertion before an error is thrown.
.Inputs
System.Object
.Outputs
None
.Notes
An example of how this function might be used in a unit test.

#display passing assertions
$VerbosePreference = [System.Management.Automation.ActionPreference]::Continue

#display debug prompt on failing assertions
$DebugPreference = [System.Management.Automation.ActionPreference]::Inquire

Assert-Null $a
Assert-Null $b
Assert-Null $c
.Link
Assert-True
Assert-False
Assert-NotNull
Assert-PipelineEmpty
Assert-PipelineAny
Assert-PipelineSingle
Assert-PipelineCount
#>
    [CmdletBinding()]
    Param(
        #The value to assert.
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
        if ($null -eq $VerbosePreference) {
            $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
        }
    }

    $fail = $null -ne $Value

    if ($fail -or ($VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue)) {
        $message = 'Assertion {0}: {1}, file {2}, line {3}' -f @(
            $(if ($fail) {'failed'} else {'passed'}),
            $MyInvocation.Line.Trim(),
            $MyInvocation.ScriptName,
            $MyInvocation.ScriptLineNumber
        )

        Write-Verbose -Message $message

        if ($fail) {
            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference]
                if ($null -eq $DebugPreference) {
                    $DebugPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                }
            }
            Write-Debug -Message $message

            $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                (New-Object -TypeName 'System.Exception' -ArgumentList @($message)),
                'AssertionFailed',
                [System.Management.Automation.ErrorCategory]::OperationStopped,
                $Value
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }
}

function Assert-PipelineAny
{
<#
.Synopsis
Assert that the pipeline contains one or more objects.
.Description
This function is useful for asserting that a function returns one or more objects.

This function throws an error if any of the following conditions are met:
    *the pipeline contains less than one object
.Example
$letter = 'a', 'b', 'c' | Get-Random | Assert-PipelineAny
Throws an error if Get-Random does not return any objects.
.Example
$letter = 'a', 'b', 'c' | Get-Random | Assert-PipelineAny -Verbose
Throws an error if Get-Random does not return any objects.
The -Verbose switch will output the result of the assertion to the Verbose stream.
.Example
$letter = 'a', 'b', 'c' | Get-Random | Assert-PipelineAny -Debug
Throws an error if Get-Random does not return any objects.
The -Debug switch gives you a chance to investigate a failing assertion before an error is thrown.
.Inputs
System.Object
.Outputs
System.Object
.Notes
An example of how this function might be used in a unit test.

#display passing assertions
$VerbosePreference = [System.Management.Automation.ActionPreference]::Continue

#display debug prompt on failing assertions
$DebugPreference = [System.Management.Automation.ActionPreference]::Inquire

$a = myFunc1 | Assert-PipelineAny
$b = myFunc2 | Assert-PipelineAny
$c = myFunc3 | Assert-PipelineAny
.Link
Assert-True
Assert-False
Assert-Null
Assert-NotNull
Assert-PipelineEmpty
Assert-PipelineSingle
Assert-PipelineCount
#>
    [CmdletBinding()]
    Param(
        #The object from the pipeline.
        #
        #Note:
        #The argument for this parameter must come from the pipeline.
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [AllowNull()]
        [System.Object]
        $InputObject
    )

    Begin
    {
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
            if ($null -eq $VerbosePreference) {
                $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
            }
        }
        if (-not $PSBoundParameters.ContainsKey('Debug')) {
            $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference]
            if ($null -eq $DebugPreference) {
                $DebugPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
            }
        }

        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                (New-Object -TypeName 'System.ArgumentException' -ArgumentList @(
                    'Assert-PipelineAny must take its input from the pipeline.',
                    'InputObject'
                )),
                'PipelineArgumentOnly',
                [System.Management.Automation.ErrorCategory]::InvalidArgument,
                $InputObject
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }

        $fail = $true
    }

    Process
    {
        $fail = $false
        ,$InputObject
    }

    End
    {
        if ($fail -or ($VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue)) {
            $message = 'Assertion {0}: {1}, file {2}, line {3}' -f @(
                $(if ($fail) {'failed'} else {'passed'}),
                $MyInvocation.Line.Trim(),
                $MyInvocation.ScriptName,
                $MyInvocation.ScriptLineNumber
            )

            Write-Verbose -Message $message

            if ($fail) {
                Write-Debug -Message $message

                $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                    (New-Object -TypeName 'System.Exception' -ArgumentList @($message)),
                    'AssertionFailed',
                    [System.Management.Automation.ErrorCategory]::OperationStopped,
                    $InputObject
                )
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }
        }
    }
}

function Assert-PipelineCount
{
<#
.Synopsis
Assert the number of objects in the pipeline.
.Description
This function is useful for asserting that a function outputs the correct number of objects.

See the -Equals, -Minimum, and -Maximum parameters for more details.

Note:
This function will output all pipeline objects it receives until an error is thrown, or until there are no more objects left in the pipeline.
.Example
$nums = 1..100 | Get-Random -Count 10 | Assert-PipelineCount 10
Throws an error if Get-Random -Count 10 does not return exactly ten objects.
.Example
$nums = 1..100 | Get-Random -Count 10 | Assert-PipelineCount -Maximum 10
Throws an error if Get-Random -Count 10 returns more than ten objects.
.Example
$nums = 1..100 | Get-Random -Count 10 | Assert-PipelineCount -Minimum 10
Throws an error if Get-Random -Count 10 returns less than ten objects.
.Example
$nums = 1..100 | Get-Random -Count 10 | Assert-PipelineCount 10 -Verbose
Throws an error if Get-Random -Count 10 does not return exactly ten objects.
The -Verbose switch will output the result of the assertion to the Verbose stream.
.Example
$nums = 1..100 | Get-Random -Count 10 | Assert-PipelineCount 10 -Debug
Throws an error if Get-Random -Count 10 does not return exactly ten objects.
The -Debug switch gives you a chance to investigate a failing assertion before an error is thrown.
.Example
$a = Get-ChildItem 'a*' | Assert-PipelineCount -Minimum 5 | Assert-PipelineCount -Maximum 10
Throws an error if Get-ChildItem 'a*' either returns less than five objects, or returns more than 10 objects.
.Inputs
System.Object
.Outputs
System.Object
.Notes
An example of how this function might be used in a unit test.

#display passing assertions
$VerbosePreference = [System.Management.Automation.ActionPreference]::Continue

#display debug prompt on failing assertions
$DebugPreference = [System.Management.Automation.ActionPreference]::Inquire

$a = myFunc1 | Assert-PipelineCount 10
$b = myFunc2 | Assert-PipelineCount -Minimum 1
$c = myFunc3 | Assert-PipelineCount -Maximum 2
$d = myFunc4 | Assert-PipelineCount -Minimum 3 | Assert-PipelineCount -Maximum 14
.Link
Assert-True
Assert-False
Assert-Null
Assert-NotNull
Assert-PipelineEmpty
Assert-PipelineAny
Assert-PipelineSingle
#>
    [CmdletBinding(DefaultParameterSetName='Equals')]
    Param(
        #The object from the pipeline.
        #
        #Note:
        #The argument for this parameter must come from the pipeline.
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [AllowNull()]
        [System.Object]
        $InputObject,

        #This function will throw an error if the number of objects in the pipeline is not equal to the number specified by this parameter.
        #
        #Note:
        #A negative number will always cause this assertion to fail.
        [Parameter(Mandatory=$true, ParameterSetName='Equals', Position=0)]
        [System.Int64]
        $Equals,

        #This function will throw an error if the number of objects in the pipeline is less than the number specified by this parameter.
        #
        #Note:
        #A negative number will always cause this assertion to pass.
        [Parameter(Mandatory=$true, ParameterSetName='Minimum')]
        [System.Int64]
        $Minimum,

        #This function will throw an error if the number of objects in the pipeline is more than the number specified by this parameter.
        #
        #Note:
        #A negative number will always cause this assertion to fail.
        [Parameter(Mandatory=$true, ParameterSetName='Maximum')]
        [System.Int64]
        $Maximum
    )

    Begin
    {
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
            if ($null -eq $VerbosePreference) {
                $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
            }
        }
        if (-not $PSBoundParameters.ContainsKey('Debug')) {
            $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference]
            if ($null -eq $DebugPreference) {
                $DebugPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
            }
        }

        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                (New-Object -TypeName 'System.ArgumentException' -ArgumentList @(
                    'Assert-PipelineCount must take its input from the pipeline.',
                    'InputObject'
                )),
                'PipelineArgumentOnly',
                [System.Management.Automation.ErrorCategory]::InvalidArgument,
                $InputObject
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }

        #Make sure we can count higher than -Equals, -Minimum, and -Maximum.
        [System.UInt64]$inputCount = 0

        if ($PSCmdlet.ParameterSetName -eq 'Equals') {
            $failEarly  = {$inputCount -gt $Equals}
            $failAssert = {$inputCount -ne $Equals}
        } elseif ($PSCmdlet.ParameterSetName -eq 'Maximum') {
            $failEarly  = {$inputCount -gt $Maximum}
            $failAssert = $failEarly
        } else {
            $failEarly  = {$false}
            $failAssert = {$inputCount -lt $Minimum}
        }
    }

    Process
    {
        $inputCount++

        if ((& $failEarly)) {
            #fail immediately
            #do not wait for all pipeline objects

            $message = 'Assertion failed: {0}, file {1}, line {2}' -f @(
                $MyInvocation.Line.Trim(),
                $MyInvocation.ScriptName,
                $MyInvocation.ScriptLineNumber
            )

            Write-Verbose -Message $message
            Write-Debug -Message $message

            $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                (New-Object -TypeName 'System.Exception' -ArgumentList @($message)),
                'AssertionFailed',
                [System.Management.Automation.ErrorCategory]::OperationStopped,
                $InputObject
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }

        ,$InputObject
    }

    End
    {
        $fail = & $failAssert

        if ($fail -or ($VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue)) {
            $message = 'Assertion {0}: {1}, file {2}, line {3}' -f @(
                $(if ($fail) {'failed'} else {'passed'}),
                $MyInvocation.Line.Trim(),
                $MyInvocation.ScriptName,
                $MyInvocation.ScriptLineNumber
            )

            Write-Verbose -Message $message

            if ($fail) {
                Write-Debug -Message $message

                $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                    (New-Object -TypeName 'System.Exception' -ArgumentList @($message)),
                    'AssertionFailed',
                    [System.Management.Automation.ErrorCategory]::OperationStopped,
                    $InputObject
                )
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }
        }
    }
}

function Assert-PipelineEmpty
{
<#
.Synopsis
Assert that the pipeline does not contain any objects.
.Description
This function is useful for asserting that a function does not output any objects.

This function throws an error if any of the following conditions are met:
    *the pipeline contains an object
.Example
Get-ChildItem 'aFileThatDoesNotExist*' | Assert-PipelineEmpty
Throws an error if Get-ChildItem 'aFileThatDoesNotExist*' returns an object.
.Example
Get-ChildItem 'aFileThatDoesNotExist*' | Assert-PipelineEmpty -Verbose
Throws an error if Get-ChildItem 'aFileThatDoesNotExist*' returns an object.
The -Verbose switch will output the result of the assertion to the Verbose stream.
.Example
Get-ChildItem 'aFileThatDoesNotExist*' | Assert-PipelineEmpty -Debug
Throws an error if Get-ChildItem 'aFileThatDoesNotExist*' returns an object.
The -Debug switch gives you a chance to investigate a failing assertion before an error is thrown.
.Inputs
System.Object
.Outputs
None
.Notes
An example of how this function might be used in a unit test.

#display passing assertions
$VerbosePreference = [System.Management.Automation.ActionPreference]::Continue

#display debug prompt on failing assertions
$DebugPreference = [System.Management.Automation.ActionPreference]::Inquire

myFunc1 | Assert-PipelineEmpty
myFunc2 | Assert-PipelineEmpty
myFunc3 | Assert-PipelineEmpty
.Link
Assert-True
Assert-False
Assert-Null
Assert-NotNull
Assert-PipelineAny
Assert-PipelineSingle
Assert-PipelineCount
#>
    [CmdletBinding()]
    Param(
        #The object from the pipeline.
        #
        #Note:
        #The argument for this parameter must come from the pipeline.
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [AllowNull()]
        [System.Object]
        $InputObject
    )

    Begin
    {
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
            if ($null -eq $VerbosePreference) {
                $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
            }
        }
        if (-not $PSBoundParameters.ContainsKey('Debug')) {
            $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference]
            if ($null -eq $DebugPreference) {
                $DebugPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
            }
        }

        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                (New-Object -TypeName 'System.ArgumentException' -ArgumentList @(
                    'Assert-PipelineEmpty must take its input from the pipeline.',
                    'InputObject'
                )),
                'PipelineArgumentOnly',
                [System.Management.Automation.ErrorCategory]::InvalidArgument,
                $InputObject
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }

    Process
    {
        #fail immediately
        #do not wait for all pipeline objects

        $message = 'Assertion failed: {0}, file {1}, line {2}' -f @(
            $MyInvocation.Line.Trim(),
            $MyInvocation.ScriptName,
            $MyInvocation.ScriptLineNumber
        )

        Write-Verbose -Message $message
        Write-Debug -Message $message

        $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
            (New-Object -TypeName 'System.Exception' -ArgumentList @($message)),
            'AssertionFailed',
            [System.Management.Automation.ErrorCategory]::OperationStopped,
            $InputObject
        )
        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    End
    {
        if ($VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue) {
            $message = 'Assertion passed: {0}, file {1}, line {2}' -f @(
                $MyInvocation.Line.Trim(),
                $MyInvocation.ScriptName,
                $MyInvocation.ScriptLineNumber
            )
            Write-Verbose -Message $message
        }
    }
}

function Assert-PipelineSingle
{
<#
.Synopsis
Assert that the pipeline only contains one object.
.Description
This function is useful for asserting that a function only returns a single object.

This function throws an error if any of the following conditions are met:
    *the pipeline contains less than one object
    *the pipeline contains more than one object
.Example
$letter = 'a', 'b', 'c' | Get-Random | Assert-PipelineSingle
Throws an error if Get-Random does not return a single object.
.Example
$letter = 'a', 'b', 'c' | Get-Random | Assert-PipelineSingle -Verbose
Throws an error if Get-Random does not return a single object.
The -Verbose switch will output the result of the assertion to the Verbose stream.
.Example
$letter = 'a', 'b', 'c' | Get-Random | Assert-PipelineSingle -Debug
Throws an error if Get-Random does not return a single object.
The -Debug switch gives you a chance to investigate a failing assertion before an error is thrown.
.Inputs
System.Object
.Outputs
System.Object
.Notes
An example of how this function might be used in a unit test.

#display passing assertions
$VerbosePreference = [System.Management.Automation.ActionPreference]::Continue

#display debug prompt on failing assertions
$DebugPreference = [System.Management.Automation.ActionPreference]::Inquire

$a = myFunc1 | Assert-PipelineSingle
$b = myFunc2 | Assert-PipelineSingle
$c = myFunc3 | Assert-PipelineSingle
.Link
Assert-True
Assert-False
Assert-Null
Assert-NotNull
Assert-PipelineEmpty
Assert-PipelineAny
Assert-PipelineCount
#>
    [CmdletBinding()]
    Param(
        #The object from the pipeline.
        #
        #Note:
        #The argument for this parameter must come from the pipeline.
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [AllowNull()]
        [System.Object]
        $InputObject
    )

    Begin
    {
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
            if ($null -eq $VerbosePreference) {
                $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
            }
        }
        if (-not $PSBoundParameters.ContainsKey('Debug')) {
            $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference]
            if ($null -eq $DebugPreference) {
                $DebugPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
            }
        }

        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                (New-Object -TypeName 'System.ArgumentException' -ArgumentList @(
                    'Assert-PipelineSingle must take its input from the pipeline.',
                    'InputObject'
                )),
                'PipelineArgumentOnly',
                [System.Management.Automation.ErrorCategory]::InvalidArgument,
                $InputObject
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }

        $anyItems = $false
    }

    Process
    {
        if ($anyItems) {
            #fail immediately
            #do not wait for all pipeline objects

            $message = 'Assertion failed: {0}, file {1}, line {2}' -f @(
                $MyInvocation.Line.Trim(),
                $MyInvocation.ScriptName,
                $MyInvocation.ScriptLineNumber
            )

            Write-Verbose -Message $message
            Write-Debug -Message $message

            $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                (New-Object -TypeName 'System.Exception' -ArgumentList @($message)),
                'AssertionFailed',
                [System.Management.Automation.ErrorCategory]::OperationStopped,
                $InputObject
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }

        $anyItems = $true
        ,$InputObject
    }

    End
    {
        $fail = -not $anyItems

        if ($fail -or ($VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue)) {
            $message = 'Assertion {0}: {1}, file {2}, line {3}' -f @(
                $(if ($fail) {'failed'} else {'passed'}),
                $MyInvocation.Line.Trim(),
                $MyInvocation.ScriptName,
                $MyInvocation.ScriptLineNumber
            )

            Write-Verbose -Message $message

            if ($fail) {
                Write-Debug -Message $message

                $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                    (New-Object -TypeName 'System.Exception' -ArgumentList @($message)),
                    'AssertionFailed',
                    [System.Management.Automation.ErrorCategory]::OperationStopped,
                    $InputObject
                )
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }
        }
    }
}

function Assert-True
{
<#
.Synopsis
Assert that a value is the Boolean value $true.
.Description
This function throws an error if any of the following conditions are met:
    *the value being asserted is $null
    *the value being asserted is not of type System.Boolean
    *the value being asserted is not $true
.Example
Assert-True ($a -eq $b)
Throws an error if the expression ($a -eq $b) does not evaluate to $true.
.Example
Assert-True ($a -eq $b) -Verbose
Throws an error if the expression ($a -eq $b) does not evaluate to $true.
The -Verbose switch will output the result of the assertion to the Verbose stream.
.Example
Assert-True ($a -eq $b) -Debug
Throws an error if the expression ($a -eq $b) does not evaluate to $true.
The -Debug switch gives you a chance to investigate a failing assertion before an error is thrown.
.Inputs
System.Boolean
System.Object
.Outputs
None
.Notes
An example of how this function might be used in a unit test.

#display passing assertions
$VerbosePreference = [System.Management.Automation.ActionPreference]::Continue

#display debug prompt on failing assertions
$DebugPreference = [System.Management.Automation.ActionPreference]::Inquire

Assert-True ($a -is [System.Int32])
Assert-True ($b -is [System.Int32])
Assert-True ($a -eq $b)
.Link
Assert-False
Assert-Null
Assert-NotNull
Assert-PipelineEmpty
Assert-PipelineAny
Assert-PipelineSingle
Assert-PipelineCount
#>
    [CmdletBinding()]
    Param(
        #The value to assert.
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
        if ($null -eq $VerbosePreference) {
            $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
        }
    }

    $fail = -not (($Value -is [System.Boolean]) -and $Value)

    if ($fail -or ($VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue)) {
        $message = 'Assertion {0}: {1}, file {2}, line {3}' -f @(
            $(if ($fail) {'failed'} else {'passed'}),
            $MyInvocation.Line.Trim(),
            $MyInvocation.ScriptName,
            $MyInvocation.ScriptLineNumber
        )

        Write-Verbose -Message $message

        if ($fail) {
            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference]
                if ($null -eq $DebugPreference) {
                    $DebugPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                }
            }
            Write-Debug -Message $message

            $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
                (New-Object -TypeName 'System.Exception' -ArgumentList @($message)),
                'AssertionFailed',
                [System.Management.Automation.ErrorCategory]::OperationStopped,
                $Value
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }
}

function Group-ListItem
{
<#
.Synopsis
Generates groups of items (such as combinations, permutations, and Cartesian products) from lists that make common testing tasks easy and simple.
.Description
The following list processing functions can be used to generate test data, to run functions and scripts with different parameter values, or even to generate parts of test scripts.

Function            Description
--------            -----------
Pair                groups adjacent items in a list into groups of 2 items
Window              groups adjacent items in a list into groups of 0 or more items
Combine             groups items in a list into combinations of 0 or more items
Permute             groups items in a list into permutations of 0 or more items
CoveringArray       groups items from n lists into a covering array for t-way tests
CartesianProduct    groups items from n lists into cartesian products of n items
Zip                 groups items from n lists with the same index into groups of n items

With these functions, many tasks that would require nested loops can be simplified to a single loop or a single pipeline.

Here is an example of testing multiple scripts using different PowerShell configurations. This kind of task typically requires nested loops (one loop for each parameter), but this example uses Group-ListItem -CartesianProduct to generate the parameter values for powershell.exe.

  $versions     = @(2, 4)
  $apStates     = @('-sta', '-mta')
  $execPolicies = @('remotesigned')
  $fileNames    = @('.\script1.ps1', '.\script2.ps1', '.\script3.ps1')

  Group-ListItem -CartesianProduct $versions, $apStates, $execPolicies, $fileNames | % {
    $ver, $aps, $exp, $file = $_.Items
    if (($ver -le 2) -and ($aps -eq '-mta')) {$aps = ''}    #PS2 has no -mta switch

    powershell -version $ver $aps -noprofile -noninteractive -executionpolicy $exp -file $file
  }
.Example
group-listItem -pair @(10, 20, 30, 40, 50)

Outputs the following arrays:

    Items
    -----
    {10, 20}
    {20, 30}
    {30, 40}
    {40, 50}
.Example
group-listItem -pair $numbers | foreach-object {$a, $b = $_.Items; assert-true ($a -le $b)}

Asserts that the items in $numbers are sorted in ascending order using the PowerShell -le operator for comparisons.

If $numbers were defined as

    $numbers = @(10, 20, 30, 40, 50)

then the this example is equivalent to

    assert-true (10 -le 20)
    assert-true (20 -le 30)
    assert-true (30 -le 40)
    assert-true (40 -le 50)
.Example
group-listItem -window @(1, 2, 3, 5, 8, 13, 21) -size 3

Outputs the following arrays:

    Items
    -----
    {1, 2, 3}
    {2, 3, 5}
    {3, 5, 8}
    {5, 8, 13}
    {8, 13, 21}
.Example
group-listItem -window $numbers -size 3 | foreach-object {$a, $b, $c = $_.Items; assert-true (($a + $b) -eq $c)}

Asserts that the numbers in the sequence is the sum of the two previous numbers in the sequence (Fibonacci sequence) using the PowerShell -eq operator for comparisons.

If $numbers were defined as

    $numbers = @(1, 2, 3, 5, 8, 13, 21)

then the example is equivalent to

    assert-true ((1 + 2) -eq 3)
    assert-true ((2 + 3) -eq 5)
    assert-true ((3 + 5) -eq 8)
    assert-true ((5 + 8) -eq 13)
    assert-true ((8 + 13) -eq 21)
.Example
group-listItem -combine @('a', 'b', 'c', 'd', 'e') -size 3

Outputs the following arrays:

    Items
    -----
    {a, b, c}
    {a, b, d}
    {a, b, e}
    {a, c, d}
    {a, c, e}
    {a, d, e}
    {b, c, d}
    {b, c, e}
    {b, d, e}
    {c, d, e}
.Example
group-listItem -combine $words -size 3 | foreach-object {assert-true (($_.items -join ' ').length -lt 10)}

Asserts that if any 3 items from $words are joined, the length of the string is less than 10, using the PowerShell -lt operator for comparisons.

If $words were defined as

    $words = @('a', 'b', 'c', 'd', 'e')

then the example is equivalent to

    assert-true (('a', 'b', 'c' -join ' ').length -lt 10)
    assert-true (('a', 'b', 'd' -join ' ').length -lt 10)
    assert-true (('a', 'b', 'e' -join ' ').length -lt 10)
    assert-true (('a', 'c', 'd' -join ' ').length -lt 10)
    assert-true (('a', 'c', 'e' -join ' ').length -lt 10)
    assert-true (('a', 'd', 'e' -join ' ').length -lt 10)
    assert-true (('b', 'c', 'd' -join ' ').length -lt 10)
    assert-true (('b', 'c', 'e' -join ' ').length -lt 10)
    assert-true (('b', 'd', 'e' -join ' ').length -lt 10)
    assert-true (('c', 'd', 'e' -join ' ').length -lt 10)
.Example
group-listItem -permute @(10, 20, 30)

Outputs the following arrays:

    Items
    -----
    {10, 20, 30}
    {10, 30, 20}
    {20, 10, 30}
    {20, 30, 10}
    {30, 10, 20}
    {30, 20, 10}
.Example
group-listItem -permute $numbers | foreach-object {assert-true ((add $_.items) -eq 60)}

Asserts that the result of "add" will be equal to 60, regardless of the order of the items in $numbers, using the PowerShell -eq operator for comparisons.

If $numbers and add were defined as

    $numbers = @(10, 20, 30)
    function add($list) {return ($list | measure -sum).sum}

then the example is equivalent to

    assert-true ((add @(10, 20, 30)) -eq 60)
    assert-true ((add @(10, 30, 20)) -eq 60)
    assert-true ((add @(20, 10, 30)) -eq 60)
    assert-true ((add @(20, 30, 10)) -eq 60)
    assert-true ((add @(30, 10, 20)) -eq 60)
    assert-true ((add @(30, 20, 10)) -eq 60)
.Example
group-listItem -cartesianProduct @(0), @(-2, -1, 0, 1, 2), @('stop', 'silentlycontinue')

Outputs the following arrays:

    Items
    -----
    {0, -2, stop}
    {0, -2, silentlycontinue}
    {0, -1, stop}
    {0, -1, silentlycontinue}
    {0, 0, stop}
    {0, 0, silentlycontinue}
    {0, 1, stop}
    {0, 1, silentlycontinue}
    {0, 2, stop}
    {0, 2, silentlycontinue}
.Example
group-listItem -cartesianProduct @(0), $numbers, $ea | foreach-object {$a, $b, $c = $_.Items; assert-true ((add $a $b -erroraction $c) -eq $b)}

Asserts that the result of (add 0 $number) is equal to $number, using the PowerShell -eq operator for comparisons.

If $numbers, $ea, and add were defined as

    $numbers = @(-2, -1, 0, 1, 2)
    $ea = @('stop', 'silentlycontinue')
    function add {[cmdletbinding()]param($a, $b) return $a + $b}

then the example is equivalent to

    assert-true ((add 0 -2 -erroraction stop) -eq -2)
    assert-true ((add 0 -2 -erroraction silentlycontinue) -eq -2)
    assert-true ((add 0 -1 -erroraction stop) -eq -1)
    assert-true ((add 0 -1 -erroraction silentlycontinue) -eq -1)
    assert-true ((add 0 0 -erroraction stop) -eq 0)
    assert-true ((add 0 0 -erroraction silentlycontinue) -eq 0)
    assert-true ((add 0 1 -erroraction stop) -eq 1)
    assert-true ((add 0 1 -erroraction silentlycontinue) -eq 1)
    assert-true ((add 0 2 -erroraction stop) -eq 2)
    assert-true ((add 0 2 -erroraction silentlycontinue) -eq 2)
.Example
group-listItem -coveringArray @('a1','a2','a3'), @('b1','b2','b3','b4','b5'), @('c1','c2') -strength 1

Outputs the following arrays:

    Items
    -----
    {a1, b1, c1}
    {a2, b2, c2}
    {a3, b3, c1}
    {a1, b4, c2}
    {a2, b5, c1}

Notice the following:
    *a1, a2, and a3 all appear in at least one row
    *b1, b2, b3, b4, and b5 all appear in at least one row
    *c1 and c2 all appear in at least one row

See the -Strength parameter for more details.
.Example
group-listItem -coveringArray $aList, $bList, $cList -strength 1 | foreach-object {$a, $b, $c = $_.Items; assert-notnull (f $a $b $c)}

Asserts that the result of (f $a $b $c) is never $null, using the covering array of strength 1 generated from the lists.

If $aList, $bList, $cList, and f were defined as

    $aList = @('a1','a2','a3')
    $bList = @('b1','b2','b3','b4','b5')
    $cList = @('c1','c2')
    function f($a, $b, $c) {"$a $b $c"}

then the example is equivalent to

    assert-notnull (f 'a1' 'b1' 'c1')
    assert-notnull (f 'a2' 'b2' 'c2')
    assert-notnull (f 'a3' 'b3' 'c1')
    assert-notnull (f 'a1' 'b4' 'c2')
    assert-notnull (f 'a2' 'b5' 'c1')


.Example
group-listItem -zip @('a', 'b', 'c'), @(1, 2, 3, 4, 5)

Outputs the following arrays:

    Items
    -----
    {a, 1}
    {b, 2}
    {c, 3}

Note:
Zip takes 0 or more lists, and the list with the fewest items determines the number of arrays that zip outputs.

In this example, the list with the fewest items (@('a', 'b', 'c')) only has 3 items, so zip outputs 3 arrays.
.Example
group-listItem -zip $aList, $bList | foreach-object {$a, $b = $_.Items; assert-true ($a -eq $b)}

Asserts that the first items in $aList are equal to the first items in $bList using the PowerShell -eq operator for comparisons.

If $aList and $bList were defined as

    $aList = @(1, 2, 3, 4, 5)
    $bList = @(1, 2, 3, 4, 5, 6, 7, 8, 9)

then the example is equivalent to

    assert-true (1 -eq 1)
    assert-true (2 -eq 2)
    assert-true (3 -eq 3)
    assert-true (4 -eq 4)
    assert-true (5 -eq 5)

Assert that two lists are equal
-------------------------------
assert-true ($aList.count -eq $bList.count)
group-listItem -zip $aList, $bList | foreach-object {$a, $b = $_.Items; assert-true ($a -eq $b)}
.Inputs
System.Collections.IList
.Outputs
System.Management.Automation.PSCustomObject

The PSCustomObject has a property called 'Items' which will always be an array.

The array in the 'Items' property has a type of [System.Object[]] by default. However, the 'Items' property may be constrained with a specific type, such as [System.Int32[]], if the list input to -Pair, -Window, -Combine, or -Permute is constrained to a specific type, or if the list inputs to -CartesianProduct or -Zip are constrained to the same specific type.
.Notes
Why not output a list of lists?

The ideal output for this function is a list of lists. That would allow, for example, to take the output of (Group-ListItem -Zip ...) and later on, feed it directly as input to (Group-ListItem -Zip ...). This is useful because if you look at multiple lists of the same length as rows and columns of data, then -Zip can be used to transpose the rows into columns, and calling -Zip a second time allows you to "undo" the transposition.

This was not done for this function because in PowerShell, functions returning lists can be error-prone when used in a pipeline. Also, by convention, public functions in PowerShell do not return lists, but return the contents of the list one at a time.

If you want the output to be a list of lists, then I suggest you create wrapper functions like this:

    function zip($listOfLists)
    {
        $a = @(Group-ListItem -Zip $listOfLists)
        for ($i = 0; $i -lt $a.length; $i++) {
            $a[$i] = $a[$i].Items
        }
        ,$a
    }

Note that using nested lists in the PowerShell pipeline will cause subtle bugs, so these wrapper functions should never be used in a pipeline and their implementations should never use the pipeline.
#>
    [CmdletBinding()]
    Param(
        #Groups adjacent items inside a list.
        #Each group has two items.
        #
        #Note:
        #This function does not return any groups if:
        #    *the length of the list is less than 2

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, ParameterSetName='Pair')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Pair,

        #Groups adjacent items inside a list.
        #The number of items in each group is specified with the -Size parameter.
        #If the -Size parameter is not specified, the number of items in each group is the same as the length of the list.
        #
        #Note:
        #This function does not return any groups if:
        #    *the value of the -Size parameter is less than 0
        #    *the value of the -Size parameter is greater than the length of the list
        #
        #This function will return 1 group with 0 items if:
        #    *the value of the -Size parameter is 0
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, ParameterSetName='Window')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Window,

        #Groups items inside a list into combinations.
        #The number of items in each group is specified with the -Size parameter.
        #If the -Size parameter is not specified, the number of items in each group is the same as the length of the list.
        #
        #Note:
        #This function does not return any groups if:
        #    *the value of the -Size parameter is less than 0
        #    *the value of the -Size parameter is greater than the length of the list
        #
        #This function will return 1 group with 0 items if:
        #    *the value of the -Size parameter is 0
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, ParameterSetName='Combine')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Combine,

        #Groups items inside a list into permutations.
        #The number of items in each group is specified with the -Size parameter.
        #If the -Size parameter is not specified, the number of items in each group is the same as the length of the list.
        #
        #Note:
        #This function does not return any groups if:
        #    *the value of the -Size parameter is less than 0
        #    *the value of the -Size parameter is greater than the length of the list
        #
        #This function will return 1 group with 0 items if:
        #    *the value of the -Size parameter is 0
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, ParameterSetName='Permute')]
        [AllowEmptyCollection()]
        [System.Collections.IList]
        $Permute,

        #The number of items per group for combinations, permutations, and windows.
        [Parameter(Mandatory=$false, ValueFromPipeline=$false, ParameterSetName='Combine')]
        [Parameter(Mandatory=$false, ValueFromPipeline=$false, ParameterSetName='Permute')]
        [Parameter(Mandatory=$false, ValueFromPipeline=$false, ParameterSetName='Window')]
        [System.Int32]
        $Size,

        #Groups items from 0 or more lists into a filtered output of cartesian product for t-way testing.
        #Each group has the same number of items as the number of lists specified.
        #
        #See the -Strength parameter for more details.
        #
        #Note:
        #This function does not return any groups if:
        #    *no lists are specified
        #    *any of the specified lists are empty
        #    *the value of the -Strength parameter is negative
        #    *the value of the -Strength parameter is 0 (this may change)
        #
        #This function will return the cartesian product if:
        #    *the -Strength parameter is not specified
        #    *the value of the -Strength parameter is greater than or equal to the number of lists
        #
        #The lists do not need to have the same number of items.
        #
        #
        #Implementation Notes:
        #    *does not always create the smallest covering array possible
        #    *repeatable covering array output (no randomization)
        #    *streaming covering array output (no unnecessary waiting)
        #
        #
        #=======================================================================
        #See nist.gov for more details about covering arrays:
        #    Practical Combinatorial Testing
        #    by D. Richard Kuhn, Raghu N. Kacker, and Yu Lei
        #    http://csrc.nist.gov/groups/SNS/acts/documents/SP800-142-101006.pdf
        #
        #    NIST Covering Array Tables - What is a covering array?
        #    http://math.nist.gov/coveringarrays/coveringarray.html
        #=======================================================================
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, ParameterSetName='CoveringArray')]
        [AllowEmptyCollection()]
        [ValidateNotNull()]
        [System.Collections.IList[]]
        $CoveringArray,

        #The strength of the covering array.
        #
        #A covering array of strength n is a filtered form of Cartesian product where all n-tuple of values from any n lists appears in at least 1 row of the output.
        #
        #Example:
        #
        #    $aList = @('a1','a2')
        #    $bList = @('b1','b2')
        #    $cList = @('c1','c2')
        #    $dList = @('d1','d2','d3')
        #
        #    group-listItem -coveringArray $aList, $bList, $cList, $dList -strength 2
        #
        #Outputs the covering array:
        #
        #    Items
        #    -----
        #    {a1, b1, c1, d1}
        #    {a1, b1, c1, d2}
        #    {a1, b1, c1, d3}
        #    {a1, b1, c2, d1}
        #    {a1, b1, c2, d2}
        #    {a1, b1, c2, d3}
        #    {a1, b2, c1, d1}
        #    {a1, b2, c1, d2}
        #    {a1, b2, c1, d3}
        #    {a1, b2, c2, d1}
        #    {a2, b1, c1, d1}
        #    {a2, b1, c1, d2}
        #    {a2, b1, c1, d3}
        #    {a2, b1, c2, d1}
        #    {a2, b2, c1, d1}
        #
        #The covering array above has a strength of 2 because if you take any 2 lists from the input, all the ways that the values from those 2 lists can be grouped appears in one or more rows in the output.
        #    $aList, $bList: (a1, b1) (a1, b2) (a2, b1) (a2, b2)
        #    $aList, $cList: (a1, c1) (a1, c2) (a2, c1) (a2, c2)
        #    $aList, $dList: (a1, d1) (a1, d2) (a1, d3) (a2, d1) (a2, d2) (a2, d3)
        #    $bList, $cList: (b1, c1) (b1, c2) (b2, c1) (b2, c2)
        #    $bList, $dList: (b1, d1) (b1, d2) (b1, d3) (b2, d1) (b2, d2) (b2, d3)
        #    $cList, $dList: (c1, d1) (c1, d2) (c1, d3) (c2, d1) (c2, d2) (c2, d3)
        #
        #The covering array above DOES NOT have a strength of 3 because if you take any 3 lists from the input, the output DOES NOT contain all the ways that the values from those 3 lists can be grouped.
        #    $aList, $bList, $cList: (a2, b2, c2) missing
        #    $aList, $bList, $dList: (a2, b2, d2) (a2, b2, d3) missing
        #    $aList, $cList, $dList: (a2, c2, d2) (a2, c2, d3) missing
        #    $bList, $cList, $dList: (b2, c2, d2) (b2, c2, d3) missing
        #
        #In general, covering arrays with a high strength have more rows than covering arrays with a low strength, and the Cartesian product is a covering array with the highest strength possible.
        #
        #
        #=======================================================================
        #See nist.gov for more details about covering arrays:
        #    Practical Combinatorial Testing
        #    by D. Richard Kuhn, Raghu N. Kacker, and Yu Lei
        #    http://csrc.nist.gov/groups/SNS/acts/documents/SP800-142-101006.pdf
        #
        #    NIST Covering Array Tables - What is a covering array?
        #    http://math.nist.gov/coveringarrays/coveringarray.html
        #=======================================================================
        [Parameter(Mandatory=$false, ValueFromPipeline=$false, ParameterSetName='CoveringArray')]
        [System.Int32]
        $Strength,

        #Groups items from 0 or more lists into cartesian products.
        #Each group has the same number of items as the number of lists specified.
        #
        #Note:
        #This function does not return any groups if:
        #    *no lists are specified
        #    *any of the specified lists are empty
        #
        #The lists do not need to have the same number of items.
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, ParameterSetName='CartesianProduct')]
        [AllowEmptyCollection()]
        [ValidateNotNull()]
        [System.Collections.IList[]]
        $CartesianProduct,

        #Groups items from 0 or more lists that have the same index.
        #Each group has the same number of items as the number of lists specified.
        #
        #Note:
        #This function does not return any groups if:
        #    *no lists are specified
        #    *any of the specified lists are empty
        #
        #If the lists do not have the same number of items, the number of groups in the output is equal to the number of items in the list with the fewest items.
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
                Group-ListItem -CartesianProduct $CoveringArray
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

                    $combinations = @(Group-ListItem -Combine $counter -Size $Strength)
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

function Test-Guid
{
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
System.Guid
System.Object
.Outputs
System.Boolean
$null
.Notes
An example of how this function might be used in a unit test.

#recommended alias
set-alias 'guid?' 'test-guid'

assert-true (guid? $a)
assert-true (guid? $a -variant standard -version 1,3,4,5)
assert-true (guid? $a -ne $b -variant standard -version 1,3,4,5 -matchvariant -matchversion)
#>
    [CmdletBinding(DefaultParameterSetName='IsGuid')]
    Param(
        #The value to test.
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Value,

        #Tests if the value is a GUID.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          never
        #$false         value is not a GUID*
        #$true          value is a GUID*
        #
        #*See the -Variant and -Version parameters for more details.
        [Parameter(Mandatory=$false, ParameterSetName='IsGuid')]
        [System.Management.Automation.SwitchParameter]
        $IsGuid = $true,

        #Tests if the first value is equal to the second.
        #
        #The -Equals parameter has the alias -eq.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not a GUID*
        #$false         System.Guid method CompareTo(Guid) != 0
        #$true          System.Guid method CompareTo(Guid) == 0
        #
        #*See the -Variant and -Version parameters for more details.
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
        #$null          one or both of the values is not a GUID*
        #$false         System.Guid method CompareTo(Guid) == 0
        #$true          System.Guid method CompareTo(Guid) != 0
        #
        #*See the -Variant and -Version parameters for more details.
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
        #$null          one or both of the values is not a GUID*
        #$false         System.Guid method CompareTo(Guid) >= 0
        #$true          System.Guid method CompareTo(Guid) < 0
        #
        #*See the -Variant and -Version parameters for more details.
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
        #$null          one or both of the values is not a GUID*
        #$false         System.Guid method CompareTo(Guid) > 0
        #$true          System.Guid method CompareTo(Guid) <= 0
        #
        #*See the -Variant and -Version parameters for more details.
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
        #$null          one or both of the values is not a GUID*
        #$false         System.Guid method CompareTo(Guid) <= 0
        #$true          System.Guid method CompareTo(Guid) > 0
        #
        #*See the -Variant and -Version parameters for more details.
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
        #$null          one or both of the values is not a GUID*
        #$false         System.Guid method CompareTo(Guid) < 0
        #$true          System.Guid method CompareTo(Guid) >= 0
        #
        #*See the -Variant and -Version parameters for more details.
        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [Alias('ge')]
        [System.Object]
        $GreaterThanOrEqualTo,

        #Causes the comparison of two GUIDs to return $null if they do not have an equivalent variant.
        #
        #*See the -Variant parameter for more details.
        [Parameter(Mandatory=$false, ParameterSetName='OpEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThanOrEqualTo')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $MatchVariant,

        #Causes the comparison of two GUIDs to return $null if they do not have the same value in their version fields.
        #
        #*See the -Version parameter for more details.
        [Parameter(Mandatory=$false, ParameterSetName='OpEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThanOrEqualTo')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $MatchVersion,

        #One or more Strings that can be used to define which variants of GUIDs are to be considered GUIDs.
        #
        #Allowed Variants
        #----------------
        #Standard, Microsoft, NCS, Reserved
        #
        #    The GUID variant field can be found in the nibble marked with v:
        #    00000000-0000-0000-v000-000000000000
        #
        #    Variant    v
        #    -------    -
        #    Standard   8, 9, A, B
        #    Microsoft  C, D
        #    NCS        0, 1, 2, 3, 4, 5, 6, 7
        #    Reserved   E, F
        #
        #Note:
        #Specifying this parameter with a $null or an empty array will cause this function to treat all objects as non-GUIDs.
        [Parameter(Mandatory=$false, ParameterSetName='IsGuid')]
        [Parameter(Mandatory=$false, ParameterSetName='OpEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThanOrEqualTo')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.String[]]
        $Variant,

        #One or more integers that can be used to define which versions of GUIDs are to be considered GUIDs.
        #
        #Allowed Versions
        #----------------
        #0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
        #
        #    The GUID version field can be found in the nibble marked with v:
        #    00000000-0000-v000-0000-000000000000
        #
        #    Note: The meaning of the value in the version field depends on the GUID variant.
        #
        #Note:
        #Specifying this parameter with a $null or an empty array will cause this function to treat all objects as non-GUIDs.
        [Parameter(Mandatory=$false, ParameterSetName='IsGuid')]
        [Parameter(Mandatory=$false, ParameterSetName='OpEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThanOrEqualTo')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Int32[]]
        $Version
    )

    $hasVersionConstraints = $PSBoundParameters.ContainsKey('Version')
    $hasVariantConstraints = $PSBoundParameters.ContainsKey('Variant')

    if ($hasVersionConstraints) {
        $versionConstraints = ''

        if (($null -ne $Version) -and ($Version.Length -gt 0)) {
            $intToHex = '0123456789ABCDEF'

            foreach ($item in $Version) {
                if (($item -lt 0) -or ($item -gt 15)) {
                    throw New-Object -TypeName 'System.ArgumentException' -ArgumentList @(
                        'Version',
                        'The GUID version field can only contain integers between 0 and 15.'
                    )
                }
                $versionConstraints += $intToHex[$item]
            }
        }
    }

    if ($hasVariantConstraints) {
        $variantConstraints = ''

        if (($null -ne $Variant) -and ($Variant.Length -gt 0)) {
            foreach ($item in $Variant) {
                switch ($item) {
                    'Standard'  {$variantConstraints += '89AB'; break;}
                    'Microsoft' {$variantConstraints += 'CD'; break;}
                    'NCS'       {$variantConstraints += '01234567'; break;}
                    'Reserved'  {$variantConstraints += 'EF'; break;}
                    default     {
                        throw New-Object -TypeName 'System.ArgumentException' -ArgumentList @(
                            "Invalid GUID variant: $item.`r`n" +
                            "Use one of the following values: Standard, Microsoft, NCS, Reserved"
                        )
                    }
                }
            }
        }
    }

    function isGuid($a)
    {
        $isGuid = $a -is [System.Guid]
        if ($isGuid) {
            $guidString = $a.psbase.ToString('D')
            $iOrdinal = [System.Stringcomparison]::OrdinalIgnoreCase

            if ($hasVersionConstraints) {
                $versionString = $guidString.Substring(14, 1)
                $isGuid = $versionConstraints.IndexOf($versionString, $iOrdinal) -ge 0
            }
            if ($isGuid -and $hasVariantConstraints) {
                $variantString = $guidString.Substring(19, 1)
                $isGuid = $variantConstraints.IndexOf($variantString, $iOrdinal) -ge 0
            }
        }
        return $isGuid
    }

    function compareGuid($a, $b)
    {
        $canCompare = (isGuid $a) -and (isGuid $b)
        if ($canCompare) {
            $aString = $a.psbase.ToString('D')
            $bString = $b.psbase.ToString('D')
            $iOrdinal = [System.StringComparison]::OrdinalIgnoreCase

            if ($MatchVersion) {
                $aVersion = $aString.SubString(14, 1)
                $bVersion = $bString.SubString(14, 1)

                $canCompare = [System.String]::Equals($aVersion, $bVersion, $iOrdinal)
            }
            if ($canCompare -and $MatchVariant) {
                $aVariant = $aString.SubString(19, 1)
                $bVariant = $bString.SubString(19, 1)

                $canCompare = $false
                foreach ($item in @('89AB', 'CD', '01234567', 'EF')) {
                    if ($item.IndexOf($aVariant, $iOrdinal) -ge 0) {
                        $canCompare = $item.IndexOf($bVariant, $iOrdinal) -ge 0
                        break
                    }
                }
            }
        }

        if ($canCompare) {
            return $a.psbase.CompareTo($b)
        }
        return $null
    }

    switch ($PSCmdlet.ParameterSetName) {
        'IsGuid' {
            return (isGuid $Value) -xor (-not $IsGuid)
        }
        'OpEquals' {
            $result = compareGuid $Value $Equals
            if ($result -is [System.Int32]) {
                return ($result -eq 0)
            }
            return $null
        }
        'OpNotEquals' {
            $result = compareGuid $Value $NotEquals
            if ($result -is [System.Int32]) {
                return ($result -ne 0)
            }
            return $null
        }
        'OpLessThan' {
            $result = compareGuid $Value $LessThan
            if ($result -is [System.Int32]) {
                return ($result -lt 0)
            }
            return $null
        }
        'OpLessThanOrEqualTo' {
            $result = compareGuid $Value $LessThanOrEqualTo
            if ($result -is [System.Int32]) {
                return ($result -le 0)
            }
            return $null
        }
        'OpGreaterThan' {
            $result = compareGuid $Value $GreaterThan
            if ($result -is [System.Int32]) {
                return ($result -gt 0)
            }
            return $null
        }
        'OpGreaterThanOrEqualTo' {
            $result = compareGuid $Value $GreaterThanOrEqualTo
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
        $IsNumber = $true,

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
            return (isNumber $Value) -xor (-not $IsNumber)
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

function Test-String
{
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
    [CmdletBinding(DefaultParameterSetName='IsString')]
    Param(
        #The value to test.
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $Value,

        #Tests if the value is a string.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          never
        #$false         the value is not a string*
        #$true          the value is a string*
        #
        #*See the -Normalization parameter for more details
        [Parameter(Mandatory=$false, ParameterSetName='IsString')]
        [System.Management.Automation.SwitchParameter]
        $IsString = $true,

        #Tests if the first string contains the second.
        #
        #Note: The empty string is inside all strings.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not a string*
        #$false         String method IndexOf(String, StringComparison) < 0
        #$true          String method IndexOf(String, StringComparison) >= 0
        #
        #*See the -Normalization parameter for more details
        [Parameter(Mandatory=$true, ParameterSetName='OpContains')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $Contains,

        #Tests if the string does not contain the second.
        #
        #Note: The empty string is inside all strings.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not a string*
        #$false         String method IndexOf(String, StringComparison) >= 0
        #$true          String method IndexOf(String, StringComparison) < 0
        #
        #*See the -Normalization parameter for more details
        [Parameter(Mandatory=$true, ParameterSetName='OpNotContains')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $NotContains,

        #Tests if the first string starts with the second string.
        #
        #Note: The empty string starts all strings.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not a string*
        #$false         String method StartsWith(String, StringComparison) returns $false
        #$true          String method StartsWith(String, StringComparison) returns $true
        #
        #*See the -Normalization parameter for more details
        [Parameter(Mandatory=$true, ParameterSetName='OpStartsWith')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $StartsWith,

        #Tests if the first string does not start with the second string.
        #
        #Note: The empty string starts all strings.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not a string*
        #$false         String method StartsWith(String, StringComparison) returns $true
        #$true          String method StartsWith(String, StringComparison) returns $false
        #
        #*See the -Normalization parameter for more details
        [Parameter(Mandatory=$true, ParameterSetName='OpNotStartsWith')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $NotStartsWith,

        #Tests if the first string ends with the second string.
        #
        #Note: The empty string ends all strings.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not a string*
        #$false         String method EndsWith(String, StringComparison) returns $false
        #$true          String method EndsWith(String, StringComparison) returns $true
        #
        #*See the -Normalization parameter for more details
        [Parameter(Mandatory=$true, ParameterSetName='OpEndsWith')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $EndsWith,

        #Tests if the first string does not end with the second string
        #
        #Note: The empty string ends all strings.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not a string*
        #$false         String method EndsWith(String, StringComparison) returns $true
        #$true          String method EndsWith(String, StringComparison) returns $false
        #
        #*See the -Normalization parameter for more details
        [Parameter(Mandatory=$true, ParameterSetName='OpNotEndsWith')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $NotEndsWith,

        #Tests if the first value is equal to the second.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not a string*
        #$false         String.Equals(String, String, StringComparison) returns $false
        #$true          String.Equals(String, String, StringComparison) returns $true
        #
        #*See the -Normalization parameter for more details
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
        #$null          one or both of the values is not a string*
        #$false         String.Equals(String, String, StringComparison) returns $true
        #$true          String.Equals(String, String, StringComparison) returns $false
        #
        #*See the -Normalization parameter for more details
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
        #$null          one or both of the values is not a string*
        #$false         String.Compare(String, String, StringComparison) >= 0
        #$true          String.Compare(String, String, StringComparison) < 0
        #
        #*See the -Normalization parameter for more details
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
        #$null          one or both of the values is not a string*
        #$false         String.Compare(String, String, StringComparison) > 0
        #$true          String.Compare(String, String, StringComparison) <= 0
        #
        #*See the -Normalization parameter for more details
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
        #$null          one or both of the values is not a string*
        #$false         String.Compare(String, String, StringComparison) <= 0
        #$true          String.Compare(String, String, StringComparison) > 0
        #
        #*See the -Normalization parameter for more details
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
        #$null          one or both of the values is not a string*
        #$false         String.Compare(String, String, StringComparison) < 0
        #$true          String.Compare(String, String, StringComparison) >= 0
        #
        #*See the -Normalization parameter for more details
        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('ge')]
        [System.Object]
        $GreaterThanOrEqualTo,

        #Makes the comparisons case sensitive.
        #
        #If this switch is set, the comparisons use
        #
        #    [System.StringComparison]::Ordinal
        #
        #otherwise, the comparisons use
        #
        #    [System.StringComparison]::OrdinalIgnoreCase
        #
        #as the default.
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

        #Causes the comparison of two strings to return $null if they are not normalized to compatible forms.
        #
        #See the -Normalization parameter for more details.
        [Parameter(Mandatory=$false, ParameterSetName='OpContains')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotContains')]
        [Parameter(Mandatory=$false, ParameterSetName='OpStartsWith')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotStartsWith')]
        [Parameter(Mandatory=$false, ParameterSetName='OpEndsWith')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEndsWith')]
        [Parameter(Mandatory=$false, ParameterSetName='OpEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThanOrEqualTo')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $FormCompatible,

        #One or more Enums that can be used to define which form of strings are to be considered strings.
        #
        #Normalization is a way of making sure that a Unicode character will only have one binary representation. This allows strings to be compared using only their binary representations. Comparing strings using only their binary representation is often desirable in scripts and programs because these comparisons are not affected by the rules of different cultures and languages.
        #
        #The Normalization Forms are: FormC, FormD, FormKC, and FormKD.
        #
        #You can use this parameter to specify which of the forms above a string must have in order for the string to be considered a string.
        #
        #Note:
        #* Specifying this parameter with a $null or an empty array will cause this function to treat all objects as non-strings.
        #
        #* This function does not normalize strings to a common form before performing the comparison.
        #
        #Reference:
        #For more details, see the MSDN documentation for the System.String methods called Normalize() and IsNormalized().
        [Parameter(Mandatory=$false)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Text.NormalizationForm[]]
        $Normalization
    )

    if ($CaseSensitive) {
        $comparisonType = [System.StringComparison]::Ordinal
    } else {
        $comparisonType = [System.StringComparison]::OrdinalIgnoreCase
    }

    $hasNormalizationConstraints = $PSBoundParameters.ContainsKey('Normalization')

    if (-not $hasNormalizationConstraints) {
        $allowedNormalizations = [System.Text.NormalizationForm[]]@(
            [System.Enum]::GetValues([System.Text.NormalizationForm])
        )
    } elseif (($null -eq $Normalization) -or ($Normalization.Length -eq 0)) {
        $allowedNormalizations = [System.Text.NormalizationForm[]]@()
    } else {
        $allowedNormalizations = [System.Text.NormalizationForm[]]@(
            [System.Enum]::GetValues([System.Text.NormalizationForm]) |
                Where-Object {$Normalization -contains $_}
        )
    }

    function isString($str)
    {
        $isStringType = $str -is [System.String]

        if ($isStringType -and $hasNormalizationConstraints) {
            foreach ($item in $allowedNormalizations) {
                if ($str.IsNormalized($item)) {
                    return $true
                }
            }
            return $false
        }

        return $isStringType
    }

    function canCompareStrings($strA, $strB)
    {
        $areStrings = ((isString $strA) -and (isString $strB))
        if ($areStrings -and $FormCompatible) {
            foreach ($item in $allowedNormalizations) {
                if ($strA.IsNormalized($item) -and $strB.IsNormalized($item)) {
                    return $true
                }
            }
            return $false
        }
        return $areStrings
    }

    switch ($PSCmdlet.ParameterSetName) {
        'IsString' {
            return (isString $Value) -xor (-not $IsString)
        }
        'OpContains' {
            if ((canCompareStrings $Value $Contains)) {
                return ($Value.IndexOf($Contains, $comparisonType) -ge 0)
            }
            return $null
        }
        'OpNotContains' {
            if ((canCompareStrings $Value $NotContains)) {
                return ($Value.IndexOf($NotContains, $comparisonType) -lt 0)
            }
            return $null
        }
        'OpStartsWith' {
            if ((canCompareStrings $Value $StartsWith)) {
                return ($Value.StartsWith($StartsWith, $comparisonType))
            }
            return $null
        }
        'OpNotStartsWith' {
            if ((canCompareStrings $Value $NotStartsWith)) {
                return (-not $Value.StartsWith($NotStartsWith, $comparisonType))
            }
            return $null
        }
        'OpEndsWith' {
            if ((canCompareStrings $Value $EndsWith)) {
                return ($Value.EndsWith($EndsWith, $comparisonType))
            }
            return $null
        }
        'OpNotEndsWith' {
            if ((canCompareStrings $Value $NotEndsWith)) {
                return (-not $Value.EndsWith($NotEndsWith, $comparisonType))
            }
            return $null
        }
        'OpEquals' {
            if ((canCompareStrings $Value $Equals)) {
                return ([System.String]::Equals($Value, $Equals, $comparisonType))
            }
            return $null
        }
        'OpNotEquals' {
            if ((canCompareStrings $Value $NotEquals)) {
                return (-not [System.String]::Equals($Value, $NotEquals, $comparisonType))
            }
            return $null
        }
        'OpLessThan' {
            if ((canCompareStrings $Value $LessThan)) {
                return ([System.String]::Compare($Value, $LessThan, $comparisonType) -lt 0)
            }
            return $null
        }
        'OpLessThanOrEqualTo' {
            if ((canCompareStrings $Value $LessThanOrEqualTo)) {
                return ([System.String]::Compare($Value, $LessThanOrEqualTo, $comparisonType) -le 0)
            }
            return $null
        }
        'OpGreaterThan' {
            if ((canCompareStrings $Value $GreaterThan)) {
                return ([System.String]::Compare($Value, $GreaterThan, $comparisonType) -gt 0)
            }
            return $null
        }
        'OpGreaterThanOrEqualTo' {
            if ((canCompareStrings $Value $GreaterThanOrEqualTo)) {
                return ([System.String]::Compare($Value, $GreaterThanOrEqualTo, $comparisonType) -ge 0)
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

function Test-TimeSpan
{
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
    [CmdletBinding(DefaultParameterSetName='IsTimeSpan')]
    Param(
        #The value to test.
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Value,

        #Tests if the value is a TimeSpan value.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          never
        #$false         value is not a TimeSpan
        #$true          value is a TimeSpan
        [Parameter(Mandatory=$false, ParameterSetName='IsTimeSpan')]
        [System.Management.Automation.SwitchParameter]
        $IsTimeSpan = $true,

        #Tests if the first value is equal to the second.
        #
        #The -Equals parameter has the alias -eq.
        #
        #Return Value   Condition
        #------------   ---------
        #$null          one or both of the values is not a TimeSpan
        #$false         System.TimeSpan.Compare(TimeSpan, TimeSpan) != 0
        #$true          System.TimeSpan.Compare(TimeSpan, TimeSpan) == 0
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
        #$null          one or both of the values is not a TimeSpan
        #$false         System.TimeSpan.Compare(TimeSpan, TimeSpan) == 0
        #$true          System.TimeSpan.Compare(TimeSpan, TimeSpan) != 0
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
        #$null          one or both of the values is not a TimeSpan
        #$false         System.TimeSpan.Compare(TimeSpan, TimeSpan) >= 0
        #$true          System.TimeSpan.Compare(TimeSpan, TimeSpan) < 0
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
        #$null          one or both of the values is not a TimeSpan
        #$false         System.TimeSpan.Compare(TimeSpan, TimeSpan) > 0
        #$true          System.TimeSpan.Compare(TimeSpan, TimeSpan) <= 0
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
        #$null          one or both of the values is not a TimeSpan
        #$false         System.TimeSpan.Compare(TimeSpan, TimeSpan) <= 0
        #$true          System.TimeSpan.Compare(TimeSpan, TimeSpan) > 0
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
        #$null          one or both of the values is not a TimeSpan
        #$false         System.TimeSpan.Compare(TimeSpan, TimeSpan) < 0
        #$true          System.TimeSpan.Compare(TimeSpan, TimeSpan) >= 0
        #
        #Note: If the -Property parameter is specified, a different comparison method is used.
        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [Alias('ge')]
        [System.Object]
        $GreaterThanOrEqualTo,

        #Compares the TimeSpan values using the specified properties.
        #
        #Note that the order that you specify the properties is significant. The first property specified has the highest priority in the comparison, and the last property specified has the lowest priority in the comparison.
        #
        #Allowed Properties
        #------------------
        #Days, Hours, Minutes, Seconds, Milliseconds, Ticks, TotalDays, TotalHours, TotalMilliseconds, TotalMinutes, TotalSeconds
        #
        #No wildcards are allowed.
        #No calculated properties (script blocks) are allowed.
        #Specifying this parameter with a $null or an empty array causes the comparisons to return $null.
        #
        #Comparison method
        #-----------------
        #1. Start with the first property specified.
        #2. Compare the properties from the two TimeSpan objects using the CompareTo method.
        #3. If the properties are equal, repeat steps 2 and 3 with the remaining properties.
        #4. Done.
        #
        #PowerShell Note:
        #Synthetic properties are not used in comparisons.
        #For example, when the hours property is compared, an expression like $a.psbase.hours is used instead of $a.hours.
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
            'Days', 'Hours', 'Minutes', 'Seconds', 'Milliseconds', 'Ticks',
            'TotalDays', 'TotalHours', 'TotalMilliseconds', 'TotalMinutes', 'TotalSeconds'
        )

        #Since the property names are going to be used directly in code,
        #make sure property names are valid and do not contain "ignorable" characters.

        foreach ($item in $Property) {
            if (($validProperties -notcontains $item) -or ($item -notmatch '^[a-zA-Z]+$')) {
                throw New-Object -TypeName 'System.ArgumentException' -ArgumentList @(
                    "Invalid TimeSpan Property: $item.`r`n" +
                    "Use one of the following values: $($validProperties -join ', ')"
                )
            }
        }
    }

    function compareTimeSpan($a, $b)
    {
        $canCompare = ($a -is [System.TimeSpan]) -and ($b -is [System.TimeSpan])
        if ($hasPropertyConstraints) {
            $canCompare = $canCompare -and ($Property.Length -gt 0)
        }

        if (-not $canCompare) {
            return $null
        }

        if (-not $hasPropertyConstraints) {
            return [System.TimeSpan]::Compare($a, $b)
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
        'IsTimeSpan' {
            return ($Value -is [System.TimeSpan]) -xor (-not $IsTimeSpan)
        }
        'OpEquals' {
            $result = compareTimeSpan $Value $Equals
            if ($result -is [System.Int32]) {
                return ($result -eq 0)
            }
            return $null
        }
        'OpNotEquals' {
            $result = compareTimeSpan $Value $NotEquals
            if ($result -is [System.Int32]) {
                return ($result -ne 0)
            }
            return $null
        }
        'OpLessThan' {
            $result = compareTimeSpan $Value $LessThan
            if ($result -is [System.Int32]) {
                return ($result -lt 0)
            }
            return $null
        }
        'OpLessThanOrEqualTo' {
            $result = compareTimeSpan $Value $LessThanOrEqualTo
            if ($result -is [System.Int32]) {
                return ($result -le 0)
            }
            return $null
        }
        'OpGreaterThan' {
            $result = compareTimeSpan $Value $GreaterThan
            if ($result -is [System.Int32]) {
                return ($result -gt 0)
            }
            return $null
        }
        'OpGreaterThanOrEqualTo' {
            $result = compareTimeSpan $Value $GreaterThanOrEqualTo
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


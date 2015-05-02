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

#Assert Library version 1.5.2.0
#
#PowerShell requirements
#requires -version 2.0

function _7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError
{
    Param(
        [System.String]
        $message,

        [System.Exception]
        $innerException,

        [System.Object]
        $value
    )

    New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
        (New-Object -TypeName 'System.Exception' -ArgumentList @($message, $innerException)),
        'AssertionFailed',
        [System.Management.Automation.ErrorCategory]::OperationStopped,
        $value
    )
}

function _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus
{
    Param(
        [System.Management.Automation.InvocationInfo]
        $invocation,

        [System.Management.Automation.SwitchParameter]
        $fail
    )

    'Assertion {0}: {1}, file {2}, line {3}' -f @(
        $(if ($fail) {'failed'} else {'passed'}),
        $invocation.Line.Trim(),
        $invocation.ScriptName,
        $invocation.ScriptLineNumber
    )
}

function _7ddd17460d1743b2b6e683ef649e01b7_newPipelineArgumentOnlyError
{
    Param(
        [System.String]
        $functionName,

        [System.String]
        $argumentName,

        [System.Object]
        $argumentValue
    )

    New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
        (New-Object -TypeName 'System.ArgumentException' -ArgumentList @(
            "$functionName must take its input from the pipeline.",
            $argumentName
        )),
        'PipelineArgumentOnly',
        [System.Management.Automation.ErrorCategory]::InvalidArgument,
        $argumentValue
    )
}

function _7ddd17460d1743b2b6e683ef649e01b7_newPredicateFailedError
{
    Param(
        [System.Management.Automation.ErrorRecord]
        $errorRecord,

        [System.Management.Automation.ScriptBlock]
        $predicate
    )

    New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList @(
        (New-Object -TypeName 'System.InvalidOperationException' -ArgumentList @('Could not invoke predicate.', $errorRecord.Exception)),
        'PredicateFailed',
        [System.Management.Automation.ErrorCategory]::OperationStopped,
        $predicate
    )
}

#.ExternalHelp Assert-All_help.xml
function Assert-All
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Collection,

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=1)]
        [System.Management.Automation.ScriptBlock]
        $Predicate
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
    }

    $fail = $true
    if ($Collection -is [System.Collections.ICollection]) {
        $fail = $false

        foreach ($item in $Collection.psbase.GetEnumerator()) {
            try   {$result = & $Predicate $item}
            catch {$PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newPredicateFailedError -errorRecord $_ -predicate $Predicate))}
        
            if (-not (($result -is [System.Boolean]) -and $result)) {
                $fail = $true
                break
            }
        }
    }

    if ($fail -or ([System.Int32]$VerbosePreference)) {
        $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

        Write-Verbose -Message $message

        if ($fail) {
            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $Collection))
        }
    }
}

#.ExternalHelp Assert-Exists_help.xml
function Assert-Exists
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Collection,

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=1)]
        [System.Management.Automation.ScriptBlock]
        $Predicate
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
    }

    $fail = $true
    if ($Collection -is [System.Collections.ICollection]) {
        foreach ($item in $Collection.psbase.GetEnumerator()) {
            try   {$result = & $Predicate $item}
            catch {$PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newPredicateFailedError -errorRecord $_ -predicate $Predicate))}
        
            if (($result -is [System.Boolean]) -and $result) {
                $fail = $false
                break
            }
        }
    }

    if ($fail -or ([System.Int32]$VerbosePreference)) {
        $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

        Write-Verbose -Message $message

        if ($fail) {
            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $Collection))
        }
    }
}

#.ExternalHelp Assert-False_help.xml
function Assert-False
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
    }

    $fail = -not (($Value -is [System.Boolean]) -and (-not $Value))

    if ($fail -or ([System.Int32]$VerbosePreference)) {
        $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

        Write-Verbose -Message $message

        if ($fail) {
            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $Value))
        }
    }
}

#.ExternalHelp Assert-NotExists_help.xml
function Assert-NotExists
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Collection,

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=1)]
        [System.Management.Automation.ScriptBlock]
        $Predicate
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
    }

    $fail = $true
    if ($Collection -is [System.Collections.ICollection]) {
        $fail = $false

        foreach ($item in $Collection.psbase.GetEnumerator()) {
            try   {$result = & $Predicate $item}
            catch {$PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newPredicateFailedError -errorRecord $_ -predicate $Predicate))}
        
            if (($result -is [System.Boolean]) -and $result) {
                $fail = $true
                break
            }
        }
    }

    if ($fail -or ([System.Int32]$VerbosePreference)) {
        $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

        Write-Verbose -Message $message

        if ($fail) {
            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $Collection))
        }
    }
}

#.ExternalHelp Assert-NotFalse_help.xml
function Assert-NotFalse
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
    }

    $fail = ($Value -is [System.Boolean]) -and (-not $Value)

    if ($fail -or ([System.Int32]$VerbosePreference)) {
        $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

        Write-Verbose -Message $message

        if ($fail) {
            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $Value))
        }
    }
}

#.ExternalHelp Assert-NotNull_help.xml
function Assert-NotNull
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
    }

    $fail = $null -eq $Value

    if ($fail -or ([System.Int32]$VerbosePreference)) {
        $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

        Write-Verbose -Message $message

        if ($fail) {
            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $Value))
        }
    }
}

#.ExternalHelp Assert-NotTrue_help.xml
function Assert-NotTrue
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
    }

    $fail = ($Value -is [System.Boolean]) -and $Value

    if ($fail -or ([System.Int32]$VerbosePreference)) {
        $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

        Write-Verbose -Message $message

        if ($fail) {
            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $Value))
        }
    }
}

#.ExternalHelp Assert-Null_help.xml
function Assert-Null
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
    }

    $fail = $null -ne $Value

    if ($fail -or ([System.Int32]$VerbosePreference)) {
        $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

        Write-Verbose -Message $message

        if ($fail) {
            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $Value))
        }
    }
}

#.ExternalHelp Assert-PipelineAll_help.xml
function Assert-PipelineAll
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [AllowNull()]
        [System.Object]
        $InputObject,

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [System.Management.Automation.ScriptBlock]
        $Predicate
    )

    Begin
    {
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
        }

        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newPipelineArgumentOnlyError -functionName 'Assert-PipelineCount' -argumentName 'InputObject' -argumentValue $InputObject))
        }
    }

    Process
    {
        try   {$result = & $Predicate $InputObject}
        catch {$PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newPredicateFailedError -errorRecord $_ -predicate $Predicate))}
        
        if (-not (($result -is [System.Boolean]) -and $result)) {
            $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail

            Write-Verbose -Message $message

            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $InputObject))
        }

        ,$InputObject
    }

    End
    {
        if (([System.Int32]$VerbosePreference)) {
            $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation
            Write-Verbose -Message $message
        }
    }
}

#.ExternalHelp Assert-PipelineAny_help.xml
function Assert-PipelineAny
{
    [CmdletBinding()]
    Param(
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
        }

        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newPipelineArgumentOnlyError -functionName 'Assert-PipelineAny' -argumentName 'InputObject' -argumentValue $InputObject))
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
        if ($fail -or ([System.Int32]$VerbosePreference)) {
            $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

            Write-Verbose -Message $message

            if ($fail) {
                if (-not $PSBoundParameters.ContainsKey('Debug')) {
                    $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
                }
                Write-Debug -Message $message
                $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $InputObject))
            }
        }
    }
}

#.ExternalHelp Assert-PipelineCount_help.xml
function Assert-PipelineCount
{
    [CmdletBinding(DefaultParameterSetName='Equals')]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [AllowNull()]
        [System.Object]
        $InputObject,

        [Parameter(Mandatory=$true, ParameterSetName='Equals', Position=0)]
        [System.Int64]
        $Equals,

        [Parameter(Mandatory=$true, ParameterSetName='Minimum')]
        [System.Int64]
        $Minimum,

        [Parameter(Mandatory=$true, ParameterSetName='Maximum')]
        [System.Int64]
        $Maximum
    )

    Begin
    {
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
        }

        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newPipelineArgumentOnlyError -functionName 'Assert-PipelineCount' -argumentName 'InputObject' -argumentValue $InputObject))
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

            $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail

            Write-Verbose -Message $message

            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $InputObject))
        }

        ,$InputObject
    }

    End
    {
        $fail = & $failAssert

        if ($fail -or ([System.Int32]$VerbosePreference)) {
            $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

            Write-Verbose -Message $message

            if ($fail) {
                if (-not $PSBoundParameters.ContainsKey('Debug')) {
                    $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
                }
                Write-Debug -Message $message
                $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $InputObject))
            }
        }
    }
}

#.ExternalHelp Assert-PipelineEmpty_help.xml
function Assert-PipelineEmpty
{
    [CmdletBinding()]
    Param(
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
        }

        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newPipelineArgumentOnlyError -functionName 'Assert-PipelineEmpty' -argumentName 'InputObject' -argumentValue $InputObject))
        }
    }

    Process
    {
        #fail immediately
        #do not wait for all pipeline objects

        $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail

        Write-Verbose -Message $message

        if (-not $PSBoundParameters.ContainsKey('Debug')) {
            $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
        }
        Write-Debug -Message $message
        $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $InputObject))
    }

    End
    {
        if (([System.Int32]$VerbosePreference)) {
            $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation
            Write-Verbose -Message $message
        }
    }
}

#.ExternalHelp Assert-PipelineExists_help.xml
function Assert-PipelineExists
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [AllowNull()]
        [System.Object]
        $InputObject,

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [System.Management.Automation.ScriptBlock]
        $Predicate
    )

    Begin
    {
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
        }

        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newPipelineArgumentOnlyError -functionName 'Assert-PipelineCount' -argumentName 'InputObject' -argumentValue $InputObject))
        }

        $fail = $true
    }

    Process
    {
        if ($fail) {
            try   {$result = & $Predicate $InputObject}
            catch {$PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newPredicateFailedError -errorRecord $_ -predicate $Predicate))}
        
            if (($result -is [System.Boolean]) -and $result) {
                $fail = $false
            }
        }
        ,$InputObject
    }

    End
    {
        if ($fail -or ([System.Int32]$VerbosePreference)) {
            $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

            Write-Verbose -Message $message

            if ($fail) {
                if (-not $PSBoundParameters.ContainsKey('Debug')) {
                    $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
                }
                Write-Debug -Message $message
                $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $null))
            }
        }
    }
}

#.ExternalHelp Assert-PipelineNotExists_help.xml
function Assert-PipelineNotExists
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [AllowNull()]
        [System.Object]
        $InputObject,

        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [System.Management.Automation.ScriptBlock]
        $Predicate
    )

    Begin
    {
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
        }

        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newPipelineArgumentOnlyError -functionName 'Assert-PipelineCount' -argumentName 'InputObject' -argumentValue $InputObject))
        }
    }

    Process
    {
        try   {$result = & $Predicate $InputObject}
        catch {$PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newPredicateFailedError -errorRecord $_ -predicate $Predicate))}
        
        if (($result -is [System.Boolean]) -and $result) {
            $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail

            Write-Verbose -Message $message

            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $InputObject))
        }

        ,$InputObject
    }

    End
    {
        if (([System.Int32]$VerbosePreference)) {
            $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation
            Write-Verbose -Message $message
        }
    }
}

#.ExternalHelp Assert-PipelineSingle_help.xml
function Assert-PipelineSingle
{
    [CmdletBinding()]
    Param(
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
        }

        if ($PSBoundParameters.ContainsKey('InputObject')) {
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newPipelineArgumentOnlyError -functionName 'Assert-PipelineSingle' -argumentName 'InputObject' -argumentValue $InputObject))
        }

        $anyItems = $false
    }

    Process
    {
        if ($anyItems) {
            #fail immediately
            #do not wait for all pipeline objects

            $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail

            Write-Verbose -Message $message

            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $InputObject))
        }

        $anyItems = $true
        ,$InputObject
    }

    End
    {
        $fail = -not $anyItems

        if ($fail -or ([System.Int32]$VerbosePreference)) {
            $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

            Write-Verbose -Message $message

            if ($fail) {
                if (-not $PSBoundParameters.ContainsKey('Debug')) {
                    $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
                }
                Write-Debug -Message $message
                $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $InputObject))
            }
        }
    }
}

#.ExternalHelp Assert-True_help.xml
function Assert-True
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Value
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
    }

    $fail = -not (($Value -is [System.Boolean]) -and $Value)

    if ($fail -or ([System.Int32]$VerbosePreference)) {
        $message = _7ddd17460d1743b2b6e683ef649e01b7_newAssertionStatus -invocation $MyInvocation -fail:$fail

        Write-Verbose -Message $message

        if ($fail) {
            if (-not $PSBoundParameters.ContainsKey('Debug')) {
                $DebugPreference = [System.Int32]($PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference])
            }
            Write-Debug -Message $message
            $PSCmdlet.ThrowTerminatingError((_7ddd17460d1743b2b6e683ef649e01b7_newAssertionFailedError -message $message -innerException $null -value $Value))
        }
    }
}

#.ExternalHelp Group-ListItem_help.xml
function Group-ListItem
{
    [CmdletBinding()]
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

#.ExternalHelp Test-DateTime_help.xml
function Test-DateTime
{
    [CmdletBinding(DefaultParameterSetName='IsDateTime')]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $Value,

        [Parameter(Mandatory=$false, ParameterSetName='IsDateTime')]
        [System.Management.Automation.SwitchParameter]
        $IsDateTime = $true,

        [Parameter(Mandatory=$true, ParameterSetName='OpEquals')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('eq')]
        [System.Object]
        $Equals,

        [Parameter(Mandatory=$true, ParameterSetName='OpNotEquals')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('ne')]
        [System.Object]
        $NotEquals,

        [Parameter(Mandatory=$true, ParameterSetName='OpLessThan')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('lt')]
        $LessThan,

        [Parameter(Mandatory=$true, ParameterSetName='OpLessThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('le')]
        $LessThanOrEqualTo,

        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThan')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('gt')]
        $GreaterThan,

        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('ge')]
        $GreaterThanOrEqualTo,

        [Parameter(Mandatory=$false, ParameterSetName='OpEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThanOrEqualTo')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $MatchKind,

        [Parameter(Mandatory=$false)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.DateTimeKind[]]
        $Kind,

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

#.ExternalHelp Test-Guid_help.xml
function Test-Guid
{
    [CmdletBinding(DefaultParameterSetName='IsGuid')]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Value,

        [Parameter(Mandatory=$false, ParameterSetName='IsGuid')]
        [System.Management.Automation.SwitchParameter]
        $IsGuid = $true,

        [Parameter(Mandatory=$true, ParameterSetName='OpEquals')]
        [AllowNull()]
        [Alias('eq')]
        [System.Object]
        $Equals,

        [Parameter(Mandatory=$true, ParameterSetName='OpNotEquals')]
        [AllowNull()]
        [Alias('ne')]
        [System.Object]
        $NotEquals,

        [Parameter(Mandatory=$true, ParameterSetName='OpLessThan')]
        [AllowNull()]
        [Alias('lt')]
        [System.Object]
        $LessThan,

        [Parameter(Mandatory=$true, ParameterSetName='OpLessThanOrEqualTo')]
        [AllowNull()]
        [Alias('le')]
        [System.Object]
        $LessThanOrEqualTo,

        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThan')]
        [AllowNull()]
        [Alias('gt')]
        [System.Object]
        $GreaterThan,

        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [Alias('ge')]
        [System.Object]
        $GreaterThanOrEqualTo,

        [Parameter(Mandatory=$false, ParameterSetName='OpEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThanOrEqualTo')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $MatchVariant,

        [Parameter(Mandatory=$false, ParameterSetName='OpEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThanOrEqualTo')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $MatchVersion,

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

#.ExternalHelp Test-Number_help.xml
function Test-Number
{
    [CmdletBinding(DefaultParameterSetName='IsNumber')]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $Value,

        [Parameter(Mandatory=$false, ParameterSetName='IsNumber')]
        [System.Management.Automation.SwitchParameter]
        $IsNumber = $true,

        [Parameter(Mandatory=$true, ParameterSetName='OpEquals')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('eq')]
        [System.Object]
        $Equals,

        [Parameter(Mandatory=$true, ParameterSetName='OpNotEquals')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('ne')]
        [System.Object]
        $NotEquals,

        [Parameter(Mandatory=$true, ParameterSetName='OpLessThan')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('lt')]
        [System.Object]
        $LessThan,
        
        [Parameter(Mandatory=$true, ParameterSetName='OpLessThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('le')]
        [System.Object]
        $LessThanOrEqualTo,

        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThan')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('gt')]
        [System.Object]
        $GreaterThan,

        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('ge')]
        [System.Object]
        $GreaterThanOrEqualTo,

        [Parameter(Mandatory=$false, ParameterSetName='OpEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpNotEquals')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpLessThanOrEqualTo')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThan')]
        [Parameter(Mandatory=$false, ParameterSetName='OpGreaterThanOrEqualTo')]
        [System.Management.Automation.SwitchParameter]
        $MatchType,

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
        'IsNumber' {
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

#.ExternalHelp Test-String_help.xml
function Test-String
{
    [CmdletBinding(DefaultParameterSetName='IsString')]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $Value,

        [Parameter(Mandatory=$false, ParameterSetName='IsString')]
        [System.Management.Automation.SwitchParameter]
        $IsString = $true,

        [Parameter(Mandatory=$true, ParameterSetName='OpContains')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $Contains,

        [Parameter(Mandatory=$true, ParameterSetName='OpNotContains')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $NotContains,

        [Parameter(Mandatory=$true, ParameterSetName='OpStartsWith')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $StartsWith,

        [Parameter(Mandatory=$true, ParameterSetName='OpNotStartsWith')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $NotStartsWith,

        [Parameter(Mandatory=$true, ParameterSetName='OpEndsWith')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $EndsWith,

        [Parameter(Mandatory=$true, ParameterSetName='OpNotEndsWith')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $NotEndsWith,

        [Parameter(Mandatory=$true, ParameterSetName='OpEquals')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('eq')]
        [System.Object]
        $Equals,

        [Parameter(Mandatory=$true, ParameterSetName='OpNotEquals')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('ne')]
        [System.Object]
        $NotEquals,

        [Parameter(Mandatory=$true, ParameterSetName='OpLessThan')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('lt')]
        [System.Object]
        $LessThan,

        [Parameter(Mandatory=$true, ParameterSetName='OpLessThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('le')]
        [System.Object]
        $LessThanOrEqualTo,

        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThan')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('gt')]
        [System.Object]
        $GreaterThan,

        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('ge')]
        [System.Object]
        $GreaterThanOrEqualTo,

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

#.ExternalHelp Test-Text_help.xml
function Test-Text
{
    [CmdletBinding(DefaultParameterSetName='IsText')]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $Value,

        [Parameter(Mandatory=$false, ParameterSetName='IsText')]
        [System.Management.Automation.SwitchParameter]
        $IsText = $true,

        [Parameter(Mandatory=$true, ParameterSetName='OpMatch')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $Match,

        [Parameter(Mandatory=$true, ParameterSetName='OpNotMatch')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $NotMatch,

        [Parameter(Mandatory=$true, ParameterSetName='OpContains')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $Contains,

        [Parameter(Mandatory=$true, ParameterSetName='OpNotContains')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $NotContains,

        [Parameter(Mandatory=$true, ParameterSetName='OpStartsWith')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $StartsWith,

        [Parameter(Mandatory=$true, ParameterSetName='OpNotStartsWith')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $NotStartsWith,

        [Parameter(Mandatory=$true, ParameterSetName='OpEndsWith')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $EndsWith,

        [Parameter(Mandatory=$true, ParameterSetName='OpNotEndsWith')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $NotEndsWith,

        [Parameter(Mandatory=$true, ParameterSetName='OpEquals')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('eq')]
        [System.Object]
        $Equals,

        [Parameter(Mandatory=$true, ParameterSetName='OpNotEquals')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('ne')]
        [System.Object]
        $NotEquals,

        [Parameter(Mandatory=$true, ParameterSetName='OpLessThan')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('lt')]
        [System.Object]
        $LessThan,

        [Parameter(Mandatory=$true, ParameterSetName='OpLessThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('le')]
        [System.Object]
        $LessThanOrEqualTo,

        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThan')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('gt')]
        [System.Object]
        $GreaterThan,

        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('ge')]
        [System.Object]
        $GreaterThanOrEqualTo,

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

#.ExternalHelp Test-TimeSpan_help.xml
function Test-TimeSpan
{
    [CmdletBinding(DefaultParameterSetName='IsTimeSpan')]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Value,

        [Parameter(Mandatory=$false, ParameterSetName='IsTimeSpan')]
        [System.Management.Automation.SwitchParameter]
        $IsTimeSpan = $true,

        [Parameter(Mandatory=$true, ParameterSetName='OpEquals')]
        [AllowNull()]
        [Alias('eq')]
        [System.Object]
        $Equals,

        [Parameter(Mandatory=$true, ParameterSetName='OpNotEquals')]
        [AllowNull()]
        [Alias('ne')]
        [System.Object]
        $NotEquals,

        [Parameter(Mandatory=$true, ParameterSetName='OpLessThan')]
        [AllowNull()]
        [Alias('lt')]
        [System.Object]
        $LessThan,

        [Parameter(Mandatory=$true, ParameterSetName='OpLessThanOrEqualTo')]
        [AllowNull()]
        [Alias('le')]
        [System.Object]
        $LessThanOrEqualTo,

        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThan')]
        [AllowNull()]
        [Alias('gt')]
        [System.Object]
        $GreaterThan,

        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [Alias('ge')]
        [System.Object]
        $GreaterThanOrEqualTo,

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

#.ExternalHelp Test-Version_help.xml
function Test-Version
{
    [CmdletBinding(DefaultParameterSetName='IsVersion')]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)]
        [AllowNull()]
        [System.Object]
        $Value,

        [Parameter(Mandatory=$false, ParameterSetName='IsVersion')]
        [System.Management.Automation.SwitchParameter]
        $IsVersion = $true,

        [Parameter(Mandatory=$true, ParameterSetName='OpEquals')]
        [AllowNull()]
        [Alias('eq')]
        [System.Object]
        $Equals,

        [Parameter(Mandatory=$true, ParameterSetName='OpNotEquals')]
        [AllowNull()]
        [Alias('ne')]
        [System.Object]
        $NotEquals,

        [Parameter(Mandatory=$true, ParameterSetName='OpLessThan')]
        [AllowNull()]
        [Alias('lt')]
        [System.Object]
        $LessThan,

        [Parameter(Mandatory=$true, ParameterSetName='OpLessThanOrEqualTo')]
        [AllowNull()]
        [Alias('le')]
        [System.Object]
        $LessThanOrEqualTo,

        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThan')]
        [AllowNull()]
        [Alias('gt')]
        [System.Object]
        $GreaterThan,

        [Parameter(Mandatory=$true, ParameterSetName='OpGreaterThanOrEqualTo')]
        [AllowNull()]
        [Alias('ge')]
        [System.Object]
        $GreaterThanOrEqualTo,

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

Export-ModuleMember -Function '*-*'

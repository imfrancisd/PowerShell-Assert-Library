[CmdletBinding()]
Param(
    [System.Management.Automation.SwitchParameter]
    $Silent
)

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
if ($Silent) {
    $headerVerbosity = [System.Management.Automation.ActionPreference]::SilentlyContinue
    $VerbosePreference = $headerVerbosity
} else {
    $headerVerbosity = [System.Management.Automation.ActionPreference]::Continue
}

& {
    Write-Verbose -Message 'Test Test-Version with get-help -full' -Verbose:$headerVerbosity

    $err = try {$fullHelp = Get-Help Test-Version -Full} catch {$_}

    Assert-Null $err
    Assert-True ($fullHelp.Name -is [System.String])
    Assert-True ($fullHelp.Name.Equals('Test-Version', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($fullHelp.description -is [System.Collections.ICollection])
    Assert-True ($fullHelp.description.Count -gt 0)
    Assert-NotNull $fullHelp.examples
    Assert-True (0 -lt @($fullHelp.examples.example).Count)
    Assert-True ('' -ne @($fullHelp.examples.example)[0].code)
}

& {
    Write-Verbose -Message 'Test Test-Version ParameterSet: IsVersion' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Version).ParameterSets |
        Where-Object {'IsVersion'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $isParam = $paramSet.Parameters |
        Where-Object {'IsVersion'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($valueParam.IsMandatory)
    Assert-False ($valueParam.ValueFromPipeline)
    Assert-False ($valueParam.ValueFromPipelineByPropertyName)
    Assert-False ($valueParam.ValueFromRemainingArguments)
    Assert-True (0 -eq $valueParam.Position)
    Assert-True (0 -eq $valueParam.Aliases.Count)

    Assert-False ($isParam.IsMandatory)
    Assert-False ($isParam.ValueFromPipeline)
    Assert-False ($isParam.ValueFromPipelineByPropertyName)
    Assert-False ($isParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $isParam.Position)
    Assert-True (0 -eq $isParam.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Test-Version ParameterSet: OpEquals' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Version).ParameterSets |
        Where-Object {'OpEquals'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $propertyParam = $paramSet.Parameters |
        Where-Object {'Property'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $eqParam = $paramSet.Parameters |
        Where-Object {'Equals'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($valueParam.IsMandatory)
    Assert-False ($valueParam.ValueFromPipeline)
    Assert-False ($valueParam.ValueFromPipelineByPropertyName)
    Assert-False ($valueParam.ValueFromRemainingArguments)
    Assert-True (0 -eq $valueParam.Position)
    Assert-True (0 -eq $valueParam.Aliases.Count)

    Assert-False ($propertyParam.IsMandatory)
    Assert-False ($propertyParam.ValueFromPipeline)
    Assert-False ($propertyParam.ValueFromPipelineByPropertyName)
    Assert-False ($propertyParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $propertyParam.Position)
    Assert-True (0 -eq $propertyParam.Aliases.Count)

    Assert-True ($eqParam.IsMandatory)
    Assert-False ($eqParam.ValueFromPipeline)
    Assert-False ($eqParam.ValueFromPipelineByPropertyName)
    Assert-False ($eqParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $eqParam.Position)
    Assert-True (1 -eq $eqParam.Aliases.Count)
    Assert-True ('eq'.Equals($eqParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Version ParameterSet: OpNotEquals' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Version).ParameterSets |
        Where-Object {'OpNotEquals'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $propertyParam = $paramSet.Parameters |
        Where-Object {'Property'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $neParam = $paramSet.Parameters |
        Where-Object {'NotEquals'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($valueParam.IsMandatory)
    Assert-False ($valueParam.ValueFromPipeline)
    Assert-False ($valueParam.ValueFromPipelineByPropertyName)
    Assert-False ($valueParam.ValueFromRemainingArguments)
    Assert-True (0 -eq $valueParam.Position)
    Assert-True (0 -eq $valueParam.Aliases.Count)

    Assert-False ($propertyParam.IsMandatory)
    Assert-False ($propertyParam.ValueFromPipeline)
    Assert-False ($propertyParam.ValueFromPipelineByPropertyName)
    Assert-False ($propertyParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $propertyParam.Position)
    Assert-True (0 -eq $propertyParam.Aliases.Count)

    Assert-True ($neParam.IsMandatory)
    Assert-False ($neParam.ValueFromPipeline)
    Assert-False ($neParam.ValueFromPipelineByPropertyName)
    Assert-False ($neParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $neParam.Position)
    Assert-True (1 -eq $neParam.Aliases.Count)
    Assert-True ('ne'.Equals($neParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Version ParameterSet: OpLessThan' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Version).ParameterSets |
        Where-Object {'OpLessThan'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $propertyParam = $paramSet.Parameters |
        Where-Object {'Property'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $ltParam = $paramSet.Parameters |
        Where-Object {'LessThan'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($valueParam.IsMandatory)
    Assert-False ($valueParam.ValueFromPipeline)
    Assert-False ($valueParam.ValueFromPipelineByPropertyName)
    Assert-False ($valueParam.ValueFromRemainingArguments)
    Assert-True (0 -eq $valueParam.Position)
    Assert-True (0 -eq $valueParam.Aliases.Count)

    Assert-False ($propertyParam.IsMandatory)
    Assert-False ($propertyParam.ValueFromPipeline)
    Assert-False ($propertyParam.ValueFromPipelineByPropertyName)
    Assert-False ($propertyParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $propertyParam.Position)
    Assert-True (0 -eq $propertyParam.Aliases.Count)

    Assert-True ($ltParam.IsMandatory)
    Assert-False ($ltParam.ValueFromPipeline)
    Assert-False ($ltParam.ValueFromPipelineByPropertyName)
    Assert-False ($ltParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $ltParam.Position)
    Assert-True (1 -eq $ltParam.Aliases.Count)
    Assert-True ('lt'.Equals($ltParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Version ParameterSet: OpLessThanOrEqualTo' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Version).ParameterSets |
        Where-Object {'OpLessThanOrEqualTo'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $propertyParam = $paramSet.Parameters |
        Where-Object {'Property'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $leParam = $paramSet.Parameters |
        Where-Object {'LessThanOrEqualTo'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($valueParam.IsMandatory)
    Assert-False ($valueParam.ValueFromPipeline)
    Assert-False ($valueParam.ValueFromPipelineByPropertyName)
    Assert-False ($valueParam.ValueFromRemainingArguments)
    Assert-True (0 -eq $valueParam.Position)
    Assert-True (0 -eq $valueParam.Aliases.Count)

    Assert-False ($propertyParam.IsMandatory)
    Assert-False ($propertyParam.ValueFromPipeline)
    Assert-False ($propertyParam.ValueFromPipelineByPropertyName)
    Assert-False ($propertyParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $propertyParam.Position)
    Assert-True (0 -eq $propertyParam.Aliases.Count)

    Assert-True ($leParam.IsMandatory)
    Assert-False ($leParam.ValueFromPipeline)
    Assert-False ($leParam.ValueFromPipelineByPropertyName)
    Assert-False ($leParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $leParam.Position)
    Assert-True (1 -eq $leParam.Aliases.Count)
    Assert-True ('le'.Equals($leParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Version ParameterSet: OpGreaterThan' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Version).ParameterSets |
        Where-Object {'OpGreaterThan'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $propertyParam = $paramSet.Parameters |
        Where-Object {'Property'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $gtParam = $paramSet.Parameters |
        Where-Object {'GreaterThan'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($valueParam.IsMandatory)
    Assert-False ($valueParam.ValueFromPipeline)
    Assert-False ($valueParam.ValueFromPipelineByPropertyName)
    Assert-False ($valueParam.ValueFromRemainingArguments)
    Assert-True (0 -eq $valueParam.Position)
    Assert-True (0 -eq $valueParam.Aliases.Count)

    Assert-False ($propertyParam.IsMandatory)
    Assert-False ($propertyParam.ValueFromPipeline)
    Assert-False ($propertyParam.ValueFromPipelineByPropertyName)
    Assert-False ($propertyParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $propertyParam.Position)
    Assert-True (0 -eq $propertyParam.Aliases.Count)

    Assert-True ($gtParam.IsMandatory)
    Assert-False ($gtParam.ValueFromPipeline)
    Assert-False ($gtParam.ValueFromPipelineByPropertyName)
    Assert-False ($gtParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $gtParam.Position)
    Assert-True (1 -eq $gtParam.Aliases.Count)
    Assert-True ('gt'.Equals($gtParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Version ParameterSet: OpGreaterThanOrEqualTo' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Version).ParameterSets |
        Where-Object {'OpGreaterThanOrEqualTo'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $propertyParam = $paramSet.Parameters |
        Where-Object {'Property'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $geParam = $paramSet.Parameters |
        Where-Object {'GreaterThanOrEqualTo'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($valueParam.IsMandatory)
    Assert-False ($valueParam.ValueFromPipeline)
    Assert-False ($valueParam.ValueFromPipelineByPropertyName)
    Assert-False ($valueParam.ValueFromRemainingArguments)
    Assert-True (0 -eq $valueParam.Position)
    Assert-True (0 -eq $valueParam.Aliases.Count)

    Assert-False ($propertyParam.IsMandatory)
    Assert-False ($propertyParam.ValueFromPipeline)
    Assert-False ($propertyParam.ValueFromPipelineByPropertyName)
    Assert-False ($propertyParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $propertyParam.Position)
    Assert-True (0 -eq $propertyParam.Aliases.Count)

    Assert-True ($geParam.IsMandatory)
    Assert-False ($geParam.ValueFromPipeline)
    Assert-False ($geParam.ValueFromPipelineByPropertyName)
    Assert-False ($geParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $geParam.Position)
    Assert-True (1 -eq $geParam.Aliases.Count)
    Assert-True ('ge'.Equals($geParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Version -IsVersion' -Verbose:$headerVerbosity

    $versions = [System.Version[]]@('0.0', '1.0', '2.7.2', '3.1.41.6')
    $nonVersions = @(@($versions[0]), @($versions[1]), $true, $false, $null, 0.0, 1.0, '0.0', '1.0')

    foreach ($version in $versions) {
        Assert-True  (Test-Version $version)
        Assert-True  (Test-Version $version -IsVersion)
        Assert-True  (Test-Version $version -IsVersion:$true)
        Assert-False (Test-Version $version -IsVersion:$false)
    }

    foreach ($nonVersion in $nonVersions) {
        Assert-False (Test-Version $nonVersion)
        Assert-False (Test-Version $nonVersion -IsVersion)
        Assert-False (Test-Version $nonVersion -IsVersion:$true)
        Assert-True  (Test-Version $nonVersion -IsVersion:$false)
    }
}

& {
    Write-Verbose -Message 'Test Test-Version -Eq' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Version -Eq not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Version -Ne' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Version -Ne not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Version -Lt' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Version -Lt not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Version -Le' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Version -Le not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Version -Gt' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Version -Gt not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Version -Ge' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Version -Ge not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Version -Eq -Property' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Version -Eq -Property not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Version -Ne -Property' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Version -Ne -Property not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Version -Lt -Property' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Version -Lt -Property not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Version -Le -Property' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Version -Le -Property not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Version -Gt -Property' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Version -Gt -Property not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Version -Ge -Property' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Version -Ge -Property not implemented here.' -WarningAction 'Continue'
}

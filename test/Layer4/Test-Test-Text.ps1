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
    Write-Verbose -Message 'Test Test-Text with get-help -full' -Verbose:$headerVerbosity

    $err = try {$fullHelp = Get-Help Test-Text -Full} catch {$_}

    Assert-Null $err
    Assert-True ($fullHelp.Name -is [System.String])
    Assert-True ($fullHelp.Name.Equals('Test-Text', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($fullHelp.description -is [System.Collections.ICollection])
    Assert-True ($fullHelp.description.Count -gt 0)
    Assert-NotNull $fullHelp.examples
    Assert-True (0 -lt @($fullHelp.examples.example).Count)
    Assert-True ('' -ne @($fullHelp.examples.example)[0].code)
}

& {
    Write-Verbose -Message 'Test Test-Text ParameterSet: IsText' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Text).ParameterSets |
        Where-Object {'IsText'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $isParam = $paramSet.Parameters |
        Where-Object {'IsText'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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
    Write-Verbose -Message 'Test Test-Text ParameterSet: OpEquals' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Text).ParameterSets |
        Where-Object {'OpEquals'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $useCurrentCultureParam = $paramSet.Parameters |
        Where-Object {'UseCurrentCulture'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($useCurrentCultureParam.IsMandatory)
    Assert-False ($useCurrentCultureParam.ValueFromPipeline)
    Assert-False ($useCurrentCultureParam.ValueFromPipelineByPropertyName)
    Assert-False ($useCurrentCultureParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $useCurrentCultureParam.Position)
    Assert-True (0 -eq $useCurrentCultureParam.Aliases.Count)

    Assert-True ($eqParam.IsMandatory)
    Assert-False ($eqParam.ValueFromPipeline)
    Assert-False ($eqParam.ValueFromPipelineByPropertyName)
    Assert-False ($eqParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $eqParam.Position)
    Assert-True (1 -eq $eqParam.Aliases.Count)
    Assert-True ('eq'.Equals($eqParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Text ParameterSet: OpNotEquals' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Text).ParameterSets |
        Where-Object {'OpNotEquals'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $useCurrentCultureParam = $paramSet.Parameters |
        Where-Object {'UseCurrentCulture'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($useCurrentCultureParam.IsMandatory)
    Assert-False ($useCurrentCultureParam.ValueFromPipeline)
    Assert-False ($useCurrentCultureParam.ValueFromPipelineByPropertyName)
    Assert-False ($useCurrentCultureParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $useCurrentCultureParam.Position)
    Assert-True (0 -eq $useCurrentCultureParam.Aliases.Count)

    Assert-True ($neParam.IsMandatory)
    Assert-False ($neParam.ValueFromPipeline)
    Assert-False ($neParam.ValueFromPipelineByPropertyName)
    Assert-False ($neParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $neParam.Position)
    Assert-True (1 -eq $neParam.Aliases.Count)
    Assert-True ('ne'.Equals($neParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Text ParameterSet: OpLessThan' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Text).ParameterSets |
        Where-Object {'OpLessThan'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $useCurrentCultureParam = $paramSet.Parameters |
        Where-Object {'UseCurrentCulture'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($useCurrentCultureParam.IsMandatory)
    Assert-False ($useCurrentCultureParam.ValueFromPipeline)
    Assert-False ($useCurrentCultureParam.ValueFromPipelineByPropertyName)
    Assert-False ($useCurrentCultureParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $useCurrentCultureParam.Position)
    Assert-True (0 -eq $useCurrentCultureParam.Aliases.Count)

    Assert-True ($ltParam.IsMandatory)
    Assert-False ($ltParam.ValueFromPipeline)
    Assert-False ($ltParam.ValueFromPipelineByPropertyName)
    Assert-False ($ltParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $ltParam.Position)
    Assert-True (1 -eq $ltParam.Aliases.Count)
    Assert-True ('lt'.Equals($ltParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Text ParameterSet: OpLessThanOrEqualTo' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Text).ParameterSets |
        Where-Object {'OpLessThanOrEqualTo'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $useCurrentCultureParam = $paramSet.Parameters |
        Where-Object {'UseCurrentCulture'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($useCurrentCultureParam.IsMandatory)
    Assert-False ($useCurrentCultureParam.ValueFromPipeline)
    Assert-False ($useCurrentCultureParam.ValueFromPipelineByPropertyName)
    Assert-False ($useCurrentCultureParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $useCurrentCultureParam.Position)
    Assert-True (0 -eq $useCurrentCultureParam.Aliases.Count)

    Assert-True ($leParam.IsMandatory)
    Assert-False ($leParam.ValueFromPipeline)
    Assert-False ($leParam.ValueFromPipelineByPropertyName)
    Assert-False ($leParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $leParam.Position)
    Assert-True (1 -eq $leParam.Aliases.Count)
    Assert-True ('le'.Equals($leParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Text ParameterSet: OpGreaterThan' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Text).ParameterSets |
        Where-Object {'OpGreaterThan'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $useCurrentCultureParam = $paramSet.Parameters |
        Where-Object {'UseCurrentCulture'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($useCurrentCultureParam.IsMandatory)
    Assert-False ($useCurrentCultureParam.ValueFromPipeline)
    Assert-False ($useCurrentCultureParam.ValueFromPipelineByPropertyName)
    Assert-False ($useCurrentCultureParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $useCurrentCultureParam.Position)
    Assert-True (0 -eq $useCurrentCultureParam.Aliases.Count)

    Assert-True ($gtParam.IsMandatory)
    Assert-False ($gtParam.ValueFromPipeline)
    Assert-False ($gtParam.ValueFromPipelineByPropertyName)
    Assert-False ($gtParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $gtParam.Position)
    Assert-True (1 -eq $gtParam.Aliases.Count)
    Assert-True ('gt'.Equals($gtParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Text ParameterSet: OpGreaterThanOrEqualTo' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Text).ParameterSets |
        Where-Object {'OpGreaterThanOrEqualTo'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $useCurrentCultureParam = $paramSet.Parameters |
        Where-Object {'UseCurrentCulture'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($useCurrentCultureParam.IsMandatory)
    Assert-False ($useCurrentCultureParam.ValueFromPipeline)
    Assert-False ($useCurrentCultureParam.ValueFromPipelineByPropertyName)
    Assert-False ($useCurrentCultureParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $useCurrentCultureParam.Position)
    Assert-True (0 -eq $useCurrentCultureParam.Aliases.Count)

    Assert-True ($geParam.IsMandatory)
    Assert-False ($geParam.ValueFromPipeline)
    Assert-False ($geParam.ValueFromPipelineByPropertyName)
    Assert-False ($geParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $geParam.Position)
    Assert-True (1 -eq $geParam.Aliases.Count)
    Assert-True ('ge'.Equals($geParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Text ParameterSet: OpContains' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Text).ParameterSets |
        Where-Object {'OpContains'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $useCurrentCultureParam = $paramSet.Parameters |
        Where-Object {'UseCurrentCulture'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $containsParam = $paramSet.Parameters |
        Where-Object {'Contains'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($valueParam.IsMandatory)
    Assert-False ($valueParam.ValueFromPipeline)
    Assert-False ($valueParam.ValueFromPipelineByPropertyName)
    Assert-False ($valueParam.ValueFromRemainingArguments)
    Assert-True (0 -eq $valueParam.Position)
    Assert-True (0 -eq $valueParam.Aliases.Count)

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($useCurrentCultureParam.IsMandatory)
    Assert-False ($useCurrentCultureParam.ValueFromPipeline)
    Assert-False ($useCurrentCultureParam.ValueFromPipelineByPropertyName)
    Assert-False ($useCurrentCultureParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $useCurrentCultureParam.Position)
    Assert-True (0 -eq $useCurrentCultureParam.Aliases.Count)

    Assert-True ($containsParam.IsMandatory)
    Assert-False ($containsParam.ValueFromPipeline)
    Assert-False ($containsParam.ValueFromPipelineByPropertyName)
    Assert-False ($containsParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $containsParam.Position)
    Assert-True (0 -eq $containsParam.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Test-Text ParameterSet: OpNotContains' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Text).ParameterSets |
        Where-Object {'OpNotContains'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $useCurrentCultureParam = $paramSet.Parameters |
        Where-Object {'UseCurrentCulture'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $notContainsParam = $paramSet.Parameters |
        Where-Object {'NotContains'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($valueParam.IsMandatory)
    Assert-False ($valueParam.ValueFromPipeline)
    Assert-False ($valueParam.ValueFromPipelineByPropertyName)
    Assert-False ($valueParam.ValueFromRemainingArguments)
    Assert-True (0 -eq $valueParam.Position)
    Assert-True (0 -eq $valueParam.Aliases.Count)

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($useCurrentCultureParam.IsMandatory)
    Assert-False ($useCurrentCultureParam.ValueFromPipeline)
    Assert-False ($useCurrentCultureParam.ValueFromPipelineByPropertyName)
    Assert-False ($useCurrentCultureParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $useCurrentCultureParam.Position)
    Assert-True (0 -eq $useCurrentCultureParam.Aliases.Count)

    Assert-True ($notContainsParam.IsMandatory)
    Assert-False ($notContainsParam.ValueFromPipeline)
    Assert-False ($notContainsParam.ValueFromPipelineByPropertyName)
    Assert-False ($notContainsParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $notContainsParam.Position)
    Assert-True (0 -eq $notContainsParam.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Test-Text ParameterSet: OpStartsWith' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Text).ParameterSets |
        Where-Object {'OpStartsWith'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $useCurrentCultureParam = $paramSet.Parameters |
        Where-Object {'UseCurrentCulture'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $startsWith = $paramSet.Parameters |
        Where-Object {'StartsWith'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($valueParam.IsMandatory)
    Assert-False ($valueParam.ValueFromPipeline)
    Assert-False ($valueParam.ValueFromPipelineByPropertyName)
    Assert-False ($valueParam.ValueFromRemainingArguments)
    Assert-True (0 -eq $valueParam.Position)
    Assert-True (0 -eq $valueParam.Aliases.Count)

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($useCurrentCultureParam.IsMandatory)
    Assert-False ($useCurrentCultureParam.ValueFromPipeline)
    Assert-False ($useCurrentCultureParam.ValueFromPipelineByPropertyName)
    Assert-False ($useCurrentCultureParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $useCurrentCultureParam.Position)
    Assert-True (0 -eq $useCurrentCultureParam.Aliases.Count)

    Assert-True ($startsWith.IsMandatory)
    Assert-False ($startsWith.ValueFromPipeline)
    Assert-False ($startsWith.ValueFromPipelineByPropertyName)
    Assert-False ($startsWith.ValueFromRemainingArguments)
    Assert-True (0 -gt $startsWith.Position)
    Assert-True (0 -eq $startsWith.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Test-Text ParameterSet: OpNotStartsWith' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Text).ParameterSets |
        Where-Object {'OpNotStartsWith'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $useCurrentCultureParam = $paramSet.Parameters |
        Where-Object {'UseCurrentCulture'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $notStartsWith = $paramSet.Parameters |
        Where-Object {'NotStartsWith'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($valueParam.IsMandatory)
    Assert-False ($valueParam.ValueFromPipeline)
    Assert-False ($valueParam.ValueFromPipelineByPropertyName)
    Assert-False ($valueParam.ValueFromRemainingArguments)
    Assert-True (0 -eq $valueParam.Position)
    Assert-True (0 -eq $valueParam.Aliases.Count)

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($useCurrentCultureParam.IsMandatory)
    Assert-False ($useCurrentCultureParam.ValueFromPipeline)
    Assert-False ($useCurrentCultureParam.ValueFromPipelineByPropertyName)
    Assert-False ($useCurrentCultureParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $useCurrentCultureParam.Position)
    Assert-True (0 -eq $useCurrentCultureParam.Aliases.Count)

    Assert-True ($notStartsWith.IsMandatory)
    Assert-False ($notStartsWith.ValueFromPipeline)
    Assert-False ($notStartsWith.ValueFromPipelineByPropertyName)
    Assert-False ($notStartsWith.ValueFromRemainingArguments)
    Assert-True (0 -gt $notStartsWith.Position)
    Assert-True (0 -eq $notStartsWith.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Test-Text ParameterSet: OpEndsWith' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Text).ParameterSets |
        Where-Object {'OpEndsWith'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $useCurrentCultureParam = $paramSet.Parameters |
        Where-Object {'UseCurrentCulture'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $endsWith = $paramSet.Parameters |
        Where-Object {'EndsWith'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($valueParam.IsMandatory)
    Assert-False ($valueParam.ValueFromPipeline)
    Assert-False ($valueParam.ValueFromPipelineByPropertyName)
    Assert-False ($valueParam.ValueFromRemainingArguments)
    Assert-True (0 -eq $valueParam.Position)
    Assert-True (0 -eq $valueParam.Aliases.Count)

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($useCurrentCultureParam.IsMandatory)
    Assert-False ($useCurrentCultureParam.ValueFromPipeline)
    Assert-False ($useCurrentCultureParam.ValueFromPipelineByPropertyName)
    Assert-False ($useCurrentCultureParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $useCurrentCultureParam.Position)
    Assert-True (0 -eq $useCurrentCultureParam.Aliases.Count)

    Assert-True ($endsWith.IsMandatory)
    Assert-False ($endsWith.ValueFromPipeline)
    Assert-False ($endsWith.ValueFromPipelineByPropertyName)
    Assert-False ($endsWith.ValueFromRemainingArguments)
    Assert-True (0 -gt $endsWith.Position)
    Assert-True (0 -eq $endsWith.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Test-Text ParameterSet: OpNotEndsWith' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Text).ParameterSets |
        Where-Object {'OpNotEndsWith'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $useCurrentCultureParam = $paramSet.Parameters |
        Where-Object {'UseCurrentCulture'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $notEndsWith = $paramSet.Parameters |
        Where-Object {'NotEndsWith'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($valueParam.IsMandatory)
    Assert-False ($valueParam.ValueFromPipeline)
    Assert-False ($valueParam.ValueFromPipelineByPropertyName)
    Assert-False ($valueParam.ValueFromRemainingArguments)
    Assert-True (0 -eq $valueParam.Position)
    Assert-True (0 -eq $valueParam.Aliases.Count)

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($useCurrentCultureParam.IsMandatory)
    Assert-False ($useCurrentCultureParam.ValueFromPipeline)
    Assert-False ($useCurrentCultureParam.ValueFromPipelineByPropertyName)
    Assert-False ($useCurrentCultureParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $useCurrentCultureParam.Position)
    Assert-True (0 -eq $useCurrentCultureParam.Aliases.Count)

    Assert-True ($notEndsWith.IsMandatory)
    Assert-False ($notEndsWith.ValueFromPipeline)
    Assert-False ($notEndsWith.ValueFromPipelineByPropertyName)
    Assert-False ($notEndsWith.ValueFromRemainingArguments)
    Assert-True (0 -gt $notEndsWith.Position)
    Assert-True (0 -eq $notEndsWith.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Test-Text ParameterSet: OpMatch' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Text).ParameterSets |
        Where-Object {'OpMatch'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $useCurrentCultureParam = $paramSet.Parameters |
        Where-Object {'UseCurrentCulture'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchParam = $paramSet.Parameters |
        Where-Object {'Match'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($valueParam.IsMandatory)
    Assert-False ($valueParam.ValueFromPipeline)
    Assert-False ($valueParam.ValueFromPipelineByPropertyName)
    Assert-False ($valueParam.ValueFromRemainingArguments)
    Assert-True (0 -eq $valueParam.Position)
    Assert-True (0 -eq $valueParam.Aliases.Count)

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($useCurrentCultureParam.IsMandatory)
    Assert-False ($useCurrentCultureParam.ValueFromPipeline)
    Assert-False ($useCurrentCultureParam.ValueFromPipelineByPropertyName)
    Assert-False ($useCurrentCultureParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $useCurrentCultureParam.Position)
    Assert-True (0 -eq $useCurrentCultureParam.Aliases.Count)

    Assert-True ($matchParam.IsMandatory)
    Assert-False ($matchParam.ValueFromPipeline)
    Assert-False ($matchParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchParam.Position)
    Assert-True (0 -eq $matchParam.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Test-Text ParameterSet: OpNotMatch' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Text).ParameterSets |
        Where-Object {'OpNotMatch'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $useCurrentCultureParam = $paramSet.Parameters |
        Where-Object {'UseCurrentCulture'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $notMatchParam = $paramSet.Parameters |
        Where-Object {'NotMatch'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($valueParam.IsMandatory)
    Assert-False ($valueParam.ValueFromPipeline)
    Assert-False ($valueParam.ValueFromPipelineByPropertyName)
    Assert-False ($valueParam.ValueFromRemainingArguments)
    Assert-True (0 -eq $valueParam.Position)
    Assert-True (0 -eq $valueParam.Aliases.Count)

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($useCurrentCultureParam.IsMandatory)
    Assert-False ($useCurrentCultureParam.ValueFromPipeline)
    Assert-False ($useCurrentCultureParam.ValueFromPipelineByPropertyName)
    Assert-False ($useCurrentCultureParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $useCurrentCultureParam.Position)
    Assert-True (0 -eq $useCurrentCultureParam.Aliases.Count)

    Assert-True ($notMatchParam.IsMandatory)
    Assert-False ($notMatchParam.ValueFromPipeline)
    Assert-False ($notMatchParam.ValueFromPipelineByPropertyName)
    Assert-False ($notMatchParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $notMatchParam.Position)
    Assert-True (0 -eq $notMatchParam.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Test-Text -IsText' -Verbose:$headerVerbosity

    $texts = [System.String[]]@('', ' ', '  ', '2.72', '2015-03-14', 'hello world')
    $nonTexts = @(@($texts[0]), @($texts[1]), $true, $false, $null, 0, 1)

    foreach ($text in $texts) {
        Assert-True  (Test-Text $text)
        Assert-True  (Test-Text $text -IsText)
        Assert-True  (Test-Text $text -IsText:$true)
        Assert-False (Test-Text $text -IsText:$false)
    }

    foreach ($nonText in $nonTexts) {
        Assert-False (Test-Text $nonText)
        Assert-False (Test-Text $nonText -IsText)
        Assert-False (Test-Text $nonText -IsText:$true)
        Assert-True  (Test-Text $nonText -IsText:$false)
    }
}

& {
    Write-Verbose -Message 'Test Test-Text -Eq' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -Eq not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -Ne' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -Ne not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -Lt' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -Lt not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -Le' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -Le not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -Gt' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -Gt not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -Ge' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -Ge not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -Contains' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -Contains not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -NotContains' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -NotContains not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -StartsWith' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -StartsWith not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -NotStartsWith' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -NotStartsWith not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -EndsWith' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -EndsWith not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -NotEndsWith' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -NotEndsWith not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -Match' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -Match not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -NotMatch' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -NotMatch not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -Eq -UseCurrentCulture' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -Eq -UseCurrentCulture not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -Ne -UseCurrentCulture' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -Ne -UseCurrentCulture not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -Lt -UseCurrentCulture' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -Lt -UseCurrentCulture not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -Le -UseCurrentCulture' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -Le -UseCurrentCulture not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -Gt -UseCurrentCulture' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -Gt -UseCurrentCulture not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -Ge -UseCurrentCulture' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -Ge -UseCurrentCulture not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -Contains -UseCurrentCulture' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -Contains -UseCurrentCulture not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -NotContains -UseCurrentCulture' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -NotContains -UseCurrentCulture not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -StartsWith -UseCurrentCulture' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -StartsWith -UseCurrentCulture not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -NotStartsWith -UseCurrentCulture' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -NotStartsWith -UseCurrentCulture not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -EndsWith -UseCurrentCulture' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -EndsWith -UseCurrentCulture not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -NotEndsWith -UseCurrentCulture' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -NotEndsWith -UseCurrentCulture not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -Match -UseCurrentCulture' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -Match -UseCurrentCulture not implemented here.' -WarningAction 'Continue'
}

& {
    Write-Verbose -Message 'Test Test-Text -NotMatch -UseCurrentCulture' -Verbose:$headerVerbosity

    Write-Warning -Message 'Test Test-Text -NotMatch -UseCurrentCulture not implemented here.' -WarningAction 'Continue'
}

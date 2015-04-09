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
    Write-Verbose -Message 'Test Test-String with get-help -full' -Verbose:$headerVerbosity

    $err = try {$fullHelp = Get-Help Test-String -Full} catch {$_}

    Assert-Null $err
    Assert-True ($fullHelp.Name -is [System.String])
    Assert-True ($fullHelp.Name.Equals('Test-String', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($fullHelp.description -is [System.Collections.ICollection])
    Assert-True ($fullHelp.description.Count -gt 0)
    Assert-NotNull $fullHelp.examples
    Assert-True (0 -lt @($fullHelp.examples.example).Count)
    Assert-True ('' -ne @($fullHelp.examples.example)[0].code)
}

& {
    Write-Verbose -Message 'Test Test-String ParameterSet: IsString' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-String).ParameterSets |
        Where-Object {'IsString'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $normalizationParam = $paramSet.Parameters |
        Where-Object {'Normalization'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $isParam = $paramSet.Parameters |
        Where-Object {'IsString'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($valueParam.IsMandatory)
    Assert-False ($valueParam.ValueFromPipeline)
    Assert-False ($valueParam.ValueFromPipelineByPropertyName)
    Assert-False ($valueParam.ValueFromRemainingArguments)
    Assert-True (0 -eq $valueParam.Position)
    Assert-True (0 -eq $valueParam.Aliases.Count)

    Assert-False ($normalizationParam.IsMandatory)
    Assert-False ($normalizationParam.ValueFromPipeline)
    Assert-False ($normalizationParam.ValueFromPipelineByPropertyName)
    Assert-False ($normalizationParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $normalizationParam.Position)
    Assert-True (0 -eq $normalizationParam.Aliases.Count)

    Assert-False ($isParam.IsMandatory)
    Assert-False ($isParam.ValueFromPipeline)
    Assert-False ($isParam.ValueFromPipelineByPropertyName)
    Assert-False ($isParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $isParam.Position)
    Assert-True (0 -eq $isParam.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Test-String ParameterSet: OpEquals' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-String).ParameterSets |
        Where-Object {'OpEquals'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $normalizationParam = $paramSet.Parameters |
        Where-Object {'Normalization'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $formCompatibleParam = $paramSet.Parameters |
        Where-Object {'FormCompatible'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($normalizationParam.IsMandatory)
    Assert-False ($normalizationParam.ValueFromPipeline)
    Assert-False ($normalizationParam.ValueFromPipelineByPropertyName)
    Assert-False ($normalizationParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $normalizationParam.Position)
    Assert-True (0 -eq $normalizationParam.Aliases.Count)

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($formCompatibleParam.IsMandatory)
    Assert-False ($formCompatibleParam.ValueFromPipeline)
    Assert-False ($formCompatibleParam.ValueFromPipelineByPropertyName)
    Assert-False ($formCompatibleParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $formCompatibleParam.Position)
    Assert-True (0 -eq $formCompatibleParam.Aliases.Count)

    Assert-True ($eqParam.IsMandatory)
    Assert-False ($eqParam.ValueFromPipeline)
    Assert-False ($eqParam.ValueFromPipelineByPropertyName)
    Assert-False ($eqParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $eqParam.Position)
    Assert-True (1 -eq $eqParam.Aliases.Count)
    Assert-True ('eq'.Equals($eqParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-String ParameterSet: OpNotEquals' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-String).ParameterSets |
        Where-Object {'OpNotEquals'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $normalizationParam = $paramSet.Parameters |
        Where-Object {'Normalization'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $formCompatibleParam = $paramSet.Parameters |
        Where-Object {'FormCompatible'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($normalizationParam.IsMandatory)
    Assert-False ($normalizationParam.ValueFromPipeline)
    Assert-False ($normalizationParam.ValueFromPipelineByPropertyName)
    Assert-False ($normalizationParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $normalizationParam.Position)
    Assert-True (0 -eq $normalizationParam.Aliases.Count)

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($formCompatibleParam.IsMandatory)
    Assert-False ($formCompatibleParam.ValueFromPipeline)
    Assert-False ($formCompatibleParam.ValueFromPipelineByPropertyName)
    Assert-False ($formCompatibleParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $formCompatibleParam.Position)
    Assert-True (0 -eq $formCompatibleParam.Aliases.Count)

    Assert-True ($neParam.IsMandatory)
    Assert-False ($neParam.ValueFromPipeline)
    Assert-False ($neParam.ValueFromPipelineByPropertyName)
    Assert-False ($neParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $neParam.Position)
    Assert-True (1 -eq $neParam.Aliases.Count)
    Assert-True ('ne'.Equals($neParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-String ParameterSet: OpLessThan' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-String).ParameterSets |
        Where-Object {'OpLessThan'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $normalizationParam = $paramSet.Parameters |
        Where-Object {'Normalization'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $formCompatibleParam = $paramSet.Parameters |
        Where-Object {'FormCompatible'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($normalizationParam.IsMandatory)
    Assert-False ($normalizationParam.ValueFromPipeline)
    Assert-False ($normalizationParam.ValueFromPipelineByPropertyName)
    Assert-False ($normalizationParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $normalizationParam.Position)
    Assert-True (0 -eq $normalizationParam.Aliases.Count)

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($formCompatibleParam.IsMandatory)
    Assert-False ($formCompatibleParam.ValueFromPipeline)
    Assert-False ($formCompatibleParam.ValueFromPipelineByPropertyName)
    Assert-False ($formCompatibleParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $formCompatibleParam.Position)
    Assert-True (0 -eq $formCompatibleParam.Aliases.Count)

    Assert-True ($ltParam.IsMandatory)
    Assert-False ($ltParam.ValueFromPipeline)
    Assert-False ($ltParam.ValueFromPipelineByPropertyName)
    Assert-False ($ltParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $ltParam.Position)
    Assert-True (1 -eq $ltParam.Aliases.Count)
    Assert-True ('lt'.Equals($ltParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-String ParameterSet: OpLessThanOrEqualTo' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-String).ParameterSets |
        Where-Object {'OpLessThanOrEqualTo'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $normalizationParam = $paramSet.Parameters |
        Where-Object {'Normalization'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $formCompatibleParam = $paramSet.Parameters |
        Where-Object {'FormCompatible'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($normalizationParam.IsMandatory)
    Assert-False ($normalizationParam.ValueFromPipeline)
    Assert-False ($normalizationParam.ValueFromPipelineByPropertyName)
    Assert-False ($normalizationParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $normalizationParam.Position)
    Assert-True (0 -eq $normalizationParam.Aliases.Count)

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($formCompatibleParam.IsMandatory)
    Assert-False ($formCompatibleParam.ValueFromPipeline)
    Assert-False ($formCompatibleParam.ValueFromPipelineByPropertyName)
    Assert-False ($formCompatibleParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $formCompatibleParam.Position)
    Assert-True (0 -eq $formCompatibleParam.Aliases.Count)

    Assert-True ($leParam.IsMandatory)
    Assert-False ($leParam.ValueFromPipeline)
    Assert-False ($leParam.ValueFromPipelineByPropertyName)
    Assert-False ($leParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $leParam.Position)
    Assert-True (1 -eq $leParam.Aliases.Count)
    Assert-True ('le'.Equals($leParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-String ParameterSet: OpGreaterThan' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-String).ParameterSets |
        Where-Object {'OpGreaterThan'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $normalizationParam = $paramSet.Parameters |
        Where-Object {'Normalization'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $formCompatibleParam = $paramSet.Parameters |
        Where-Object {'FormCompatible'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($normalizationParam.IsMandatory)
    Assert-False ($normalizationParam.ValueFromPipeline)
    Assert-False ($normalizationParam.ValueFromPipelineByPropertyName)
    Assert-False ($normalizationParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $normalizationParam.Position)
    Assert-True (0 -eq $normalizationParam.Aliases.Count)

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($formCompatibleParam.IsMandatory)
    Assert-False ($formCompatibleParam.ValueFromPipeline)
    Assert-False ($formCompatibleParam.ValueFromPipelineByPropertyName)
    Assert-False ($formCompatibleParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $formCompatibleParam.Position)
    Assert-True (0 -eq $formCompatibleParam.Aliases.Count)

    Assert-True ($gtParam.IsMandatory)
    Assert-False ($gtParam.ValueFromPipeline)
    Assert-False ($gtParam.ValueFromPipelineByPropertyName)
    Assert-False ($gtParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $gtParam.Position)
    Assert-True (1 -eq $gtParam.Aliases.Count)
    Assert-True ('gt'.Equals($gtParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-String ParameterSet: OpGreaterThanOrEqualTo' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-String).ParameterSets |
        Where-Object {'OpGreaterThanOrEqualTo'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $normalizationParam = $paramSet.Parameters |
        Where-Object {'Normalization'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $formCompatibleParam = $paramSet.Parameters |
        Where-Object {'FormCompatible'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($normalizationParam.IsMandatory)
    Assert-False ($normalizationParam.ValueFromPipeline)
    Assert-False ($normalizationParam.ValueFromPipelineByPropertyName)
    Assert-False ($normalizationParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $normalizationParam.Position)
    Assert-True (0 -eq $normalizationParam.Aliases.Count)

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($formCompatibleParam.IsMandatory)
    Assert-False ($formCompatibleParam.ValueFromPipeline)
    Assert-False ($formCompatibleParam.ValueFromPipelineByPropertyName)
    Assert-False ($formCompatibleParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $formCompatibleParam.Position)
    Assert-True (0 -eq $formCompatibleParam.Aliases.Count)

    Assert-True ($geParam.IsMandatory)
    Assert-False ($geParam.ValueFromPipeline)
    Assert-False ($geParam.ValueFromPipelineByPropertyName)
    Assert-False ($geParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $geParam.Position)
    Assert-True (1 -eq $geParam.Aliases.Count)
    Assert-True ('ge'.Equals($geParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-String ParameterSet: OpContains' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-String).ParameterSets |
        Where-Object {'OpContains'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $normalizationParam = $paramSet.Parameters |
        Where-Object {'Normalization'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $formCompatibleParam = $paramSet.Parameters |
        Where-Object {'FormCompatible'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($normalizationParam.IsMandatory)
    Assert-False ($normalizationParam.ValueFromPipeline)
    Assert-False ($normalizationParam.ValueFromPipelineByPropertyName)
    Assert-False ($normalizationParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $normalizationParam.Position)
    Assert-True (0 -eq $normalizationParam.Aliases.Count)

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($formCompatibleParam.IsMandatory)
    Assert-False ($formCompatibleParam.ValueFromPipeline)
    Assert-False ($formCompatibleParam.ValueFromPipelineByPropertyName)
    Assert-False ($formCompatibleParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $formCompatibleParam.Position)
    Assert-True (0 -eq $formCompatibleParam.Aliases.Count)

    Assert-True ($containsParam.IsMandatory)
    Assert-False ($containsParam.ValueFromPipeline)
    Assert-False ($containsParam.ValueFromPipelineByPropertyName)
    Assert-False ($containsParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $containsParam.Position)
    Assert-True (0 -eq $containsParam.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Test-String ParameterSet: OpNotContains' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-String).ParameterSets |
        Where-Object {'OpNotContains'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $normalizationParam = $paramSet.Parameters |
        Where-Object {'Normalization'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $formCompatibleParam = $paramSet.Parameters |
        Where-Object {'FormCompatible'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($normalizationParam.IsMandatory)
    Assert-False ($normalizationParam.ValueFromPipeline)
    Assert-False ($normalizationParam.ValueFromPipelineByPropertyName)
    Assert-False ($normalizationParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $normalizationParam.Position)
    Assert-True (0 -eq $normalizationParam.Aliases.Count)

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($formCompatibleParam.IsMandatory)
    Assert-False ($formCompatibleParam.ValueFromPipeline)
    Assert-False ($formCompatibleParam.ValueFromPipelineByPropertyName)
    Assert-False ($formCompatibleParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $formCompatibleParam.Position)
    Assert-True (0 -eq $formCompatibleParam.Aliases.Count)

    Assert-True ($notContainsParam.IsMandatory)
    Assert-False ($notContainsParam.ValueFromPipeline)
    Assert-False ($notContainsParam.ValueFromPipelineByPropertyName)
    Assert-False ($notContainsParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $notContainsParam.Position)
    Assert-True (0 -eq $notContainsParam.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Test-String ParameterSet: OpStartsWith' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-String).ParameterSets |
        Where-Object {'OpStartsWith'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $normalizationParam = $paramSet.Parameters |
        Where-Object {'Normalization'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $formCompatibleParam = $paramSet.Parameters |
        Where-Object {'FormCompatible'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($normalizationParam.IsMandatory)
    Assert-False ($normalizationParam.ValueFromPipeline)
    Assert-False ($normalizationParam.ValueFromPipelineByPropertyName)
    Assert-False ($normalizationParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $normalizationParam.Position)
    Assert-True (0 -eq $normalizationParam.Aliases.Count)

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($formCompatibleParam.IsMandatory)
    Assert-False ($formCompatibleParam.ValueFromPipeline)
    Assert-False ($formCompatibleParam.ValueFromPipelineByPropertyName)
    Assert-False ($formCompatibleParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $formCompatibleParam.Position)
    Assert-True (0 -eq $formCompatibleParam.Aliases.Count)

    Assert-True ($startsWith.IsMandatory)
    Assert-False ($startsWith.ValueFromPipeline)
    Assert-False ($startsWith.ValueFromPipelineByPropertyName)
    Assert-False ($startsWith.ValueFromRemainingArguments)
    Assert-True (0 -gt $startsWith.Position)
    Assert-True (0 -eq $startsWith.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Test-String ParameterSet: OpNotStartsWith' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-String).ParameterSets |
        Where-Object {'OpNotStartsWith'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $normalizationParam = $paramSet.Parameters |
        Where-Object {'Normalization'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $formCompatibleParam = $paramSet.Parameters |
        Where-Object {'FormCompatible'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($normalizationParam.IsMandatory)
    Assert-False ($normalizationParam.ValueFromPipeline)
    Assert-False ($normalizationParam.ValueFromPipelineByPropertyName)
    Assert-False ($normalizationParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $normalizationParam.Position)
    Assert-True (0 -eq $normalizationParam.Aliases.Count)

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($formCompatibleParam.IsMandatory)
    Assert-False ($formCompatibleParam.ValueFromPipeline)
    Assert-False ($formCompatibleParam.ValueFromPipelineByPropertyName)
    Assert-False ($formCompatibleParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $formCompatibleParam.Position)
    Assert-True (0 -eq $formCompatibleParam.Aliases.Count)

    Assert-True ($notStartsWith.IsMandatory)
    Assert-False ($notStartsWith.ValueFromPipeline)
    Assert-False ($notStartsWith.ValueFromPipelineByPropertyName)
    Assert-False ($notStartsWith.ValueFromRemainingArguments)
    Assert-True (0 -gt $notStartsWith.Position)
    Assert-True (0 -eq $notStartsWith.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Test-String ParameterSet: OpEndsWith' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-String).ParameterSets |
        Where-Object {'OpEndsWith'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $normalizationParam = $paramSet.Parameters |
        Where-Object {'Normalization'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $formCompatibleParam = $paramSet.Parameters |
        Where-Object {'FormCompatible'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($normalizationParam.IsMandatory)
    Assert-False ($normalizationParam.ValueFromPipeline)
    Assert-False ($normalizationParam.ValueFromPipelineByPropertyName)
    Assert-False ($normalizationParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $normalizationParam.Position)
    Assert-True (0 -eq $normalizationParam.Aliases.Count)

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($formCompatibleParam.IsMandatory)
    Assert-False ($formCompatibleParam.ValueFromPipeline)
    Assert-False ($formCompatibleParam.ValueFromPipelineByPropertyName)
    Assert-False ($formCompatibleParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $formCompatibleParam.Position)
    Assert-True (0 -eq $formCompatibleParam.Aliases.Count)

    Assert-True ($endsWith.IsMandatory)
    Assert-False ($endsWith.ValueFromPipeline)
    Assert-False ($endsWith.ValueFromPipelineByPropertyName)
    Assert-False ($endsWith.ValueFromRemainingArguments)
    Assert-True (0 -gt $endsWith.Position)
    Assert-True (0 -eq $endsWith.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Test-String ParameterSet: OpNotEndsWith' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-String).ParameterSets |
        Where-Object {'OpNotEndsWith'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $normalizationParam = $paramSet.Parameters |
        Where-Object {'Normalization'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $caseSensitiveParam = $paramSet.Parameters |
        Where-Object {'CaseSensitive'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $formCompatibleParam = $paramSet.Parameters |
        Where-Object {'FormCompatible'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($normalizationParam.IsMandatory)
    Assert-False ($normalizationParam.ValueFromPipeline)
    Assert-False ($normalizationParam.ValueFromPipelineByPropertyName)
    Assert-False ($normalizationParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $normalizationParam.Position)
    Assert-True (0 -eq $normalizationParam.Aliases.Count)

    Assert-False ($caseSensitiveParam.IsMandatory)
    Assert-False ($caseSensitiveParam.ValueFromPipeline)
    Assert-False ($caseSensitiveParam.ValueFromPipelineByPropertyName)
    Assert-False ($caseSensitiveParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $caseSensitiveParam.Position)
    Assert-True (0 -eq $caseSensitiveParam.Aliases.Count)

    Assert-False ($formCompatibleParam.IsMandatory)
    Assert-False ($formCompatibleParam.ValueFromPipeline)
    Assert-False ($formCompatibleParam.ValueFromPipelineByPropertyName)
    Assert-False ($formCompatibleParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $formCompatibleParam.Position)
    Assert-True (0 -eq $formCompatibleParam.Aliases.Count)

    Assert-True ($notEndsWith.IsMandatory)
    Assert-False ($notEndsWith.ValueFromPipeline)
    Assert-False ($notEndsWith.ValueFromPipelineByPropertyName)
    Assert-False ($notEndsWith.ValueFromRemainingArguments)
    Assert-True (0 -gt $notEndsWith.Position)
    Assert-True (0 -eq $notEndsWith.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Test-String -IsString' -Verbose:$headerVerbosity

    $strings = [System.String[]]@('', ' ', '  ', '2.72', '2015-03-14', 'hello world')
    $nonStrings = @(@($strings[0]), @($strings[1]), $true, $false, $null, 0, 1)

    foreach ($string in $strings) {
        Assert-True  (Test-String $string)
        Assert-True  (Test-String $string -IsString)
        Assert-True  (Test-String $string -IsString:$true)
        Assert-False (Test-String $string -IsString:$false)
    }

    foreach ($nonString in $nonStrings) {
        Assert-False (Test-String $nonString)
        Assert-False (Test-String $nonString -IsString)
        Assert-False (Test-String $nonString -IsString:$true)
        Assert-True  (Test-String $nonString -IsString:$false)
    }
}

Write-Warning -Message 'Remaining tests not implemented here.' -WarningAction 'Continue'

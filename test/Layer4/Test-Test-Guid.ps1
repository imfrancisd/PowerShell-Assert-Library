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
    Write-Verbose -Message 'Test Test-Guid with get-help -full' -Verbose:$headerVerbosity

    $err = try {$fullHelp = Get-Help Test-Guid -Full} catch {$_}

    Assert-Null $err
    Assert-True ($fullHelp.Name -is [System.String])
    Assert-True ($fullHelp.Name.Equals('Test-Guid', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($fullHelp.description -is [System.Collections.ICollection])
    Assert-True ($fullHelp.description.Count -gt 0)
    Assert-NotNull $fullHelp.examples
    Assert-True (0 -lt @($fullHelp.examples.example).Count)
    Assert-True ('' -ne @($fullHelp.examples.example)[0].code)
}

& {
    Write-Verbose -Message 'Test Test-Guid ParameterSet: IsGuid' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Guid).ParameterSets |
        Where-Object {'IsGuid'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $variantParam = $paramSet.Parameters |
        Where-Object {'Variant'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $versionParam = $paramSet.Parameters |
        Where-Object {'Version'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $isParam = $paramSet.Parameters |
        Where-Object {'IsGuid'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($valueParam.IsMandatory)
    Assert-False ($valueParam.ValueFromPipeline)
    Assert-False ($valueParam.ValueFromPipelineByPropertyName)
    Assert-False ($valueParam.ValueFromRemainingArguments)
    Assert-True (0 -eq $valueParam.Position)
    Assert-True (0 -eq $valueParam.Aliases.Count)

    Assert-False ($variantParam.IsMandatory)
    Assert-False ($variantParam.ValueFromPipeline)
    Assert-False ($variantParam.ValueFromPipelineByPropertyName)
    Assert-False ($variantParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $variantParam.Position)
    Assert-True (0 -eq $variantParam.Aliases.Count)

    Assert-False ($versionParam.IsMandatory)
    Assert-False ($versionParam.ValueFromPipeline)
    Assert-False ($versionParam.ValueFromPipelineByPropertyName)
    Assert-False ($versionParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $versionParam.Position)
    Assert-True (0 -eq $versionParam.Aliases.Count)

    Assert-False ($isParam.IsMandatory)
    Assert-False ($isParam.ValueFromPipeline)
    Assert-False ($isParam.ValueFromPipelineByPropertyName)
    Assert-False ($isParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $isParam.Position)
    Assert-True (0 -eq $isParam.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Test-Guid ParameterSet: OpEquals' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Guid).ParameterSets |
        Where-Object {'OpEquals'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $variantParam = $paramSet.Parameters |
        Where-Object {'Variant'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $versionParam = $paramSet.Parameters |
        Where-Object {'Version'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchVariantParam = $paramSet.Parameters |
        Where-Object {'MatchVariant'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchVersionParam = $paramSet.Parameters |
        Where-Object {'MatchVersion'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($variantParam.IsMandatory)
    Assert-False ($variantParam.ValueFromPipeline)
    Assert-False ($variantParam.ValueFromPipelineByPropertyName)
    Assert-False ($variantParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $variantParam.Position)
    Assert-True (0 -eq $variantParam.Aliases.Count)

    Assert-False ($versionParam.IsMandatory)
    Assert-False ($versionParam.ValueFromPipeline)
    Assert-False ($versionParam.ValueFromPipelineByPropertyName)
    Assert-False ($versionParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $versionParam.Position)
    Assert-True (0 -eq $versionParam.Aliases.Count)

    Assert-False ($matchVariantParam.IsMandatory)
    Assert-False ($matchVariantParam.ValueFromPipeline)
    Assert-False ($matchVariantParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchVariantParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchVariantParam.Position)
    Assert-True (0 -eq $matchVariantParam.Aliases.Count)

    Assert-False ($matchVersionParam.IsMandatory)
    Assert-False ($matchVersionParam.ValueFromPipeline)
    Assert-False ($matchVersionParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchVersionParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchVersionParam.Position)
    Assert-True (0 -eq $matchVersionParam.Aliases.Count)

    Assert-True ($eqParam.IsMandatory)
    Assert-False ($eqParam.ValueFromPipeline)
    Assert-False ($eqParam.ValueFromPipelineByPropertyName)
    Assert-False ($eqParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $eqParam.Position)
    Assert-True (1 -eq $eqParam.Aliases.Count)
    Assert-True ('eq'.Equals($eqParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Guid ParameterSet: OpNotEquals' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Guid).ParameterSets |
        Where-Object {'OpNotEquals'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $variantParam = $paramSet.Parameters |
        Where-Object {'Variant'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $versionParam = $paramSet.Parameters |
        Where-Object {'Version'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchVariantParam = $paramSet.Parameters |
        Where-Object {'MatchVariant'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchVersionParam = $paramSet.Parameters |
        Where-Object {'MatchVersion'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($variantParam.IsMandatory)
    Assert-False ($variantParam.ValueFromPipeline)
    Assert-False ($variantParam.ValueFromPipelineByPropertyName)
    Assert-False ($variantParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $variantParam.Position)
    Assert-True (0 -eq $variantParam.Aliases.Count)

    Assert-False ($versionParam.IsMandatory)
    Assert-False ($versionParam.ValueFromPipeline)
    Assert-False ($versionParam.ValueFromPipelineByPropertyName)
    Assert-False ($versionParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $versionParam.Position)
    Assert-True (0 -eq $versionParam.Aliases.Count)

    Assert-False ($matchVariantParam.IsMandatory)
    Assert-False ($matchVariantParam.ValueFromPipeline)
    Assert-False ($matchVariantParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchVariantParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchVariantParam.Position)
    Assert-True (0 -eq $matchVariantParam.Aliases.Count)

    Assert-False ($matchVersionParam.IsMandatory)
    Assert-False ($matchVersionParam.ValueFromPipeline)
    Assert-False ($matchVersionParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchVersionParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchVersionParam.Position)
    Assert-True (0 -eq $matchVersionParam.Aliases.Count)

    Assert-True ($neParam.IsMandatory)
    Assert-False ($neParam.ValueFromPipeline)
    Assert-False ($neParam.ValueFromPipelineByPropertyName)
    Assert-False ($neParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $neParam.Position)
    Assert-True (1 -eq $neParam.Aliases.Count)
    Assert-True ('ne'.Equals($neParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Guid ParameterSet: OpLessThan' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Guid).ParameterSets |
        Where-Object {'OpLessThan'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $variantParam = $paramSet.Parameters |
        Where-Object {'Variant'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $versionParam = $paramSet.Parameters |
        Where-Object {'Version'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchVariantParam = $paramSet.Parameters |
        Where-Object {'MatchVariant'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchVersionParam = $paramSet.Parameters |
        Where-Object {'MatchVersion'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($variantParam.IsMandatory)
    Assert-False ($variantParam.ValueFromPipeline)
    Assert-False ($variantParam.ValueFromPipelineByPropertyName)
    Assert-False ($variantParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $variantParam.Position)
    Assert-True (0 -eq $variantParam.Aliases.Count)

    Assert-False ($versionParam.IsMandatory)
    Assert-False ($versionParam.ValueFromPipeline)
    Assert-False ($versionParam.ValueFromPipelineByPropertyName)
    Assert-False ($versionParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $versionParam.Position)
    Assert-True (0 -eq $versionParam.Aliases.Count)

    Assert-False ($matchVariantParam.IsMandatory)
    Assert-False ($matchVariantParam.ValueFromPipeline)
    Assert-False ($matchVariantParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchVariantParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchVariantParam.Position)
    Assert-True (0 -eq $matchVariantParam.Aliases.Count)

    Assert-False ($matchVersionParam.IsMandatory)
    Assert-False ($matchVersionParam.ValueFromPipeline)
    Assert-False ($matchVersionParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchVersionParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchVersionParam.Position)
    Assert-True (0 -eq $matchVersionParam.Aliases.Count)

    Assert-True ($ltParam.IsMandatory)
    Assert-False ($ltParam.ValueFromPipeline)
    Assert-False ($ltParam.ValueFromPipelineByPropertyName)
    Assert-False ($ltParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $ltParam.Position)
    Assert-True (1 -eq $ltParam.Aliases.Count)
    Assert-True ('lt'.Equals($ltParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Guid ParameterSet: OpLessThanOrEqualTo' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Guid).ParameterSets |
        Where-Object {'OpLessThanOrEqualTo'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $variantParam = $paramSet.Parameters |
        Where-Object {'Variant'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $versionParam = $paramSet.Parameters |
        Where-Object {'Version'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchVariantParam = $paramSet.Parameters |
        Where-Object {'MatchVariant'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchVersionParam = $paramSet.Parameters |
        Where-Object {'MatchVersion'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($variantParam.IsMandatory)
    Assert-False ($variantParam.ValueFromPipeline)
    Assert-False ($variantParam.ValueFromPipelineByPropertyName)
    Assert-False ($variantParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $variantParam.Position)
    Assert-True (0 -eq $variantParam.Aliases.Count)

    Assert-False ($versionParam.IsMandatory)
    Assert-False ($versionParam.ValueFromPipeline)
    Assert-False ($versionParam.ValueFromPipelineByPropertyName)
    Assert-False ($versionParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $versionParam.Position)
    Assert-True (0 -eq $versionParam.Aliases.Count)

    Assert-False ($matchVariantParam.IsMandatory)
    Assert-False ($matchVariantParam.ValueFromPipeline)
    Assert-False ($matchVariantParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchVariantParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchVariantParam.Position)
    Assert-True (0 -eq $matchVariantParam.Aliases.Count)

    Assert-False ($matchVersionParam.IsMandatory)
    Assert-False ($matchVersionParam.ValueFromPipeline)
    Assert-False ($matchVersionParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchVersionParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchVersionParam.Position)
    Assert-True (0 -eq $matchVersionParam.Aliases.Count)

    Assert-True ($leParam.IsMandatory)
    Assert-False ($leParam.ValueFromPipeline)
    Assert-False ($leParam.ValueFromPipelineByPropertyName)
    Assert-False ($leParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $leParam.Position)
    Assert-True (1 -eq $leParam.Aliases.Count)
    Assert-True ('le'.Equals($leParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Guid ParameterSet: OpGreaterThan' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Guid).ParameterSets |
        Where-Object {'OpGreaterThan'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $variantParam = $paramSet.Parameters |
        Where-Object {'Variant'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $versionParam = $paramSet.Parameters |
        Where-Object {'Version'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchVariantParam = $paramSet.Parameters |
        Where-Object {'MatchVariant'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchVersionParam = $paramSet.Parameters |
        Where-Object {'MatchVersion'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($variantParam.IsMandatory)
    Assert-False ($variantParam.ValueFromPipeline)
    Assert-False ($variantParam.ValueFromPipelineByPropertyName)
    Assert-False ($variantParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $variantParam.Position)
    Assert-True (0 -eq $variantParam.Aliases.Count)

    Assert-False ($versionParam.IsMandatory)
    Assert-False ($versionParam.ValueFromPipeline)
    Assert-False ($versionParam.ValueFromPipelineByPropertyName)
    Assert-False ($versionParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $versionParam.Position)
    Assert-True (0 -eq $versionParam.Aliases.Count)

    Assert-False ($matchVariantParam.IsMandatory)
    Assert-False ($matchVariantParam.ValueFromPipeline)
    Assert-False ($matchVariantParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchVariantParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchVariantParam.Position)
    Assert-True (0 -eq $matchVariantParam.Aliases.Count)

    Assert-False ($matchVersionParam.IsMandatory)
    Assert-False ($matchVersionParam.ValueFromPipeline)
    Assert-False ($matchVersionParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchVersionParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchVersionParam.Position)
    Assert-True (0 -eq $matchVersionParam.Aliases.Count)

    Assert-True ($gtParam.IsMandatory)
    Assert-False ($gtParam.ValueFromPipeline)
    Assert-False ($gtParam.ValueFromPipelineByPropertyName)
    Assert-False ($gtParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $gtParam.Position)
    Assert-True (1 -eq $gtParam.Aliases.Count)
    Assert-True ('gt'.Equals($gtParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Guid ParameterSet: OpGreaterThanOrEqualTo' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Guid).ParameterSets |
        Where-Object {'OpGreaterThanOrEqualTo'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $variantParam = $paramSet.Parameters |
        Where-Object {'Variant'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $versionParam = $paramSet.Parameters |
        Where-Object {'Version'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchVariantParam = $paramSet.Parameters |
        Where-Object {'MatchVariant'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchVersionParam = $paramSet.Parameters |
        Where-Object {'MatchVersion'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($variantParam.IsMandatory)
    Assert-False ($variantParam.ValueFromPipeline)
    Assert-False ($variantParam.ValueFromPipelineByPropertyName)
    Assert-False ($variantParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $variantParam.Position)
    Assert-True (0 -eq $variantParam.Aliases.Count)

    Assert-False ($versionParam.IsMandatory)
    Assert-False ($versionParam.ValueFromPipeline)
    Assert-False ($versionParam.ValueFromPipelineByPropertyName)
    Assert-False ($versionParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $versionParam.Position)
    Assert-True (0 -eq $versionParam.Aliases.Count)

    Assert-False ($matchVariantParam.IsMandatory)
    Assert-False ($matchVariantParam.ValueFromPipeline)
    Assert-False ($matchVariantParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchVariantParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchVariantParam.Position)
    Assert-True (0 -eq $matchVariantParam.Aliases.Count)

    Assert-False ($matchVersionParam.IsMandatory)
    Assert-False ($matchVersionParam.ValueFromPipeline)
    Assert-False ($matchVersionParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchVersionParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchVersionParam.Position)
    Assert-True (0 -eq $matchVersionParam.Aliases.Count)

    Assert-True ($geParam.IsMandatory)
    Assert-False ($geParam.ValueFromPipeline)
    Assert-False ($geParam.ValueFromPipelineByPropertyName)
    Assert-False ($geParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $geParam.Position)
    Assert-True (1 -eq $geParam.Aliases.Count)
    Assert-True ('ge'.Equals($geParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Guid -IsGuid' -Verbose:$headerVerbosity

    $guids = [System.Guid[]]@('00000000-0000-0000-0000-000000000000', '7ddd1746-0d17-43b2-b6e6-83ef649e01b7')
    $nonGuids = @(@($guids[0]), @($guids[1]), $true, $false, $null, 0, 1, '00000000-0000-0000-0000-000000000000', '7ddd1746-0d17-43b2-b6e6-83ef649e01b7')

    foreach ($guid in $guids) {
        Assert-True  (Test-Guid $guid)
        Assert-True  (Test-Guid $guid -IsGuid)
        Assert-True  (Test-Guid $guid -IsGuid:$true)
        Assert-False (Test-Guid $guid -IsGuid:$false)
    }

    foreach ($nonGuid in $nonGuids) {
        Assert-False (Test-Guid $nonGuid)
        Assert-False (Test-Guid $nonGuid -IsGuid)
        Assert-False (Test-Guid $nonGuid -IsGuid:$true)
        Assert-True  (Test-Guid $nonGuid -IsGuid:$false)
    }
}

Write-Warning -Message 'Remaining tests not implemented here.' -WarningAction 'Continue'

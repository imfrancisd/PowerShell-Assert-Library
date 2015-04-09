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
    Write-Verbose -Message 'Test Test-Number with get-help -full' -Verbose:$headerVerbosity

    $err = try {$fullHelp = Get-Help Test-Number -Full} catch {$_}

    Assert-Null $err
    Assert-True ($fullHelp.Name -is [System.String])
    Assert-True ($fullHelp.Name.Equals('Test-Number', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($fullHelp.description -is [System.Collections.ICollection])
    Assert-True ($fullHelp.description.Count -gt 0)
    Assert-NotNull $fullHelp.examples
    Assert-True (0 -lt @($fullHelp.examples.example).Count)
    Assert-True ('' -ne @($fullHelp.examples.example)[0].code)
}

& {
    Write-Verbose -Message 'Test Test-Number ParameterSet: IsNumber' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Number).ParameterSets |
        Where-Object {'IsNumber'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $typeParam = $paramSet.Parameters |
        Where-Object {'Type'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $isParam = $paramSet.Parameters |
        Where-Object {'IsNumber'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($valueParam.IsMandatory)
    Assert-False ($valueParam.ValueFromPipeline)
    Assert-False ($valueParam.ValueFromPipelineByPropertyName)
    Assert-False ($valueParam.ValueFromRemainingArguments)
    Assert-True (0 -eq $valueParam.Position)
    Assert-True (0 -eq $valueParam.Aliases.Count)

    Assert-False ($typeParam.IsMandatory)
    Assert-False ($typeParam.ValueFromPipeline)
    Assert-False ($typeParam.ValueFromPipelineByPropertyName)
    Assert-False ($typeParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $typeParam.Position)
    Assert-True (0 -eq $typeParam.Aliases.Count)

    Assert-False ($isParam.IsMandatory)
    Assert-False ($isParam.ValueFromPipeline)
    Assert-False ($isParam.ValueFromPipelineByPropertyName)
    Assert-False ($isParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $isParam.Position)
    Assert-True (0 -eq $isParam.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Test-Number ParameterSet: OpEquals' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Number).ParameterSets |
        Where-Object {'OpEquals'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $typeParam = $paramSet.Parameters |
        Where-Object {'Type'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchTypeParam = $paramSet.Parameters |
        Where-Object {'MatchType'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($typeParam.IsMandatory)
    Assert-False ($typeParam.ValueFromPipeline)
    Assert-False ($typeParam.ValueFromPipelineByPropertyName)
    Assert-False ($typeParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $typeParam.Position)
    Assert-True (0 -eq $typeParam.Aliases.Count)

    Assert-False ($matchTypeParam.IsMandatory)
    Assert-False ($matchTypeParam.ValueFromPipeline)
    Assert-False ($matchTypeParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchTypeParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchTypeParam.Position)
    Assert-True (0 -eq $matchTypeParam.Aliases.Count)

    Assert-True ($eqParam.IsMandatory)
    Assert-False ($eqParam.ValueFromPipeline)
    Assert-False ($eqParam.ValueFromPipelineByPropertyName)
    Assert-False ($eqParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $eqParam.Position)
    Assert-True (1 -eq $eqParam.Aliases.Count)
    Assert-True ('eq'.Equals($eqParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Number ParameterSet: OpNotEquals' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Number).ParameterSets |
        Where-Object {'OpNotEquals'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $typeParam = $paramSet.Parameters |
        Where-Object {'Type'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchTypeParam = $paramSet.Parameters |
        Where-Object {'MatchType'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($typeParam.IsMandatory)
    Assert-False ($typeParam.ValueFromPipeline)
    Assert-False ($typeParam.ValueFromPipelineByPropertyName)
    Assert-False ($typeParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $typeParam.Position)
    Assert-True (0 -eq $typeParam.Aliases.Count)

    Assert-False ($matchTypeParam.IsMandatory)
    Assert-False ($matchTypeParam.ValueFromPipeline)
    Assert-False ($matchTypeParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchTypeParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchTypeParam.Position)
    Assert-True (0 -eq $matchTypeParam.Aliases.Count)

    Assert-True ($neParam.IsMandatory)
    Assert-False ($neParam.ValueFromPipeline)
    Assert-False ($neParam.ValueFromPipelineByPropertyName)
    Assert-False ($neParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $neParam.Position)
    Assert-True (1 -eq $neParam.Aliases.Count)
    Assert-True ('ne'.Equals($neParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Number ParameterSet: OpLessThan' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Number).ParameterSets |
        Where-Object {'OpLessThan'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $typeParam = $paramSet.Parameters |
        Where-Object {'Type'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchTypeParam = $paramSet.Parameters |
        Where-Object {'MatchType'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($typeParam.IsMandatory)
    Assert-False ($typeParam.ValueFromPipeline)
    Assert-False ($typeParam.ValueFromPipelineByPropertyName)
    Assert-False ($typeParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $typeParam.Position)
    Assert-True (0 -eq $typeParam.Aliases.Count)

    Assert-False ($matchTypeParam.IsMandatory)
    Assert-False ($matchTypeParam.ValueFromPipeline)
    Assert-False ($matchTypeParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchTypeParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchTypeParam.Position)
    Assert-True (0 -eq $matchTypeParam.Aliases.Count)

    Assert-True ($ltParam.IsMandatory)
    Assert-False ($ltParam.ValueFromPipeline)
    Assert-False ($ltParam.ValueFromPipelineByPropertyName)
    Assert-False ($ltParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $ltParam.Position)
    Assert-True (1 -eq $ltParam.Aliases.Count)
    Assert-True ('lt'.Equals($ltParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Number ParameterSet: OpLessThanOrEqualTo' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Number).ParameterSets |
        Where-Object {'OpLessThanOrEqualTo'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $typeParam = $paramSet.Parameters |
        Where-Object {'Type'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchTypeParam = $paramSet.Parameters |
        Where-Object {'MatchType'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($typeParam.IsMandatory)
    Assert-False ($typeParam.ValueFromPipeline)
    Assert-False ($typeParam.ValueFromPipelineByPropertyName)
    Assert-False ($typeParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $typeParam.Position)
    Assert-True (0 -eq $typeParam.Aliases.Count)

    Assert-False ($matchTypeParam.IsMandatory)
    Assert-False ($matchTypeParam.ValueFromPipeline)
    Assert-False ($matchTypeParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchTypeParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchTypeParam.Position)
    Assert-True (0 -eq $matchTypeParam.Aliases.Count)

    Assert-True ($leParam.IsMandatory)
    Assert-False ($leParam.ValueFromPipeline)
    Assert-False ($leParam.ValueFromPipelineByPropertyName)
    Assert-False ($leParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $leParam.Position)
    Assert-True (1 -eq $leParam.Aliases.Count)
    Assert-True ('le'.Equals($leParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Number ParameterSet: OpGreaterThan' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Number).ParameterSets |
        Where-Object {'OpGreaterThan'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $typeParam = $paramSet.Parameters |
        Where-Object {'Type'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchTypeParam = $paramSet.Parameters |
        Where-Object {'MatchType'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($typeParam.IsMandatory)
    Assert-False ($typeParam.ValueFromPipeline)
    Assert-False ($typeParam.ValueFromPipelineByPropertyName)
    Assert-False ($typeParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $typeParam.Position)
    Assert-True (0 -eq $typeParam.Aliases.Count)

    Assert-False ($matchTypeParam.IsMandatory)
    Assert-False ($matchTypeParam.ValueFromPipeline)
    Assert-False ($matchTypeParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchTypeParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchTypeParam.Position)
    Assert-True (0 -eq $matchTypeParam.Aliases.Count)

    Assert-True ($gtParam.IsMandatory)
    Assert-False ($gtParam.ValueFromPipeline)
    Assert-False ($gtParam.ValueFromPipelineByPropertyName)
    Assert-False ($gtParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $gtParam.Position)
    Assert-True (1 -eq $gtParam.Aliases.Count)
    Assert-True ('gt'.Equals($gtParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Number ParameterSet: OpGreaterThanOrEqualTo' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-Number).ParameterSets |
        Where-Object {'OpGreaterThanOrEqualTo'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $typeParam = $paramSet.Parameters |
        Where-Object {'Type'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchTypeParam = $paramSet.Parameters |
        Where-Object {'MatchType'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($typeParam.IsMandatory)
    Assert-False ($typeParam.ValueFromPipeline)
    Assert-False ($typeParam.ValueFromPipelineByPropertyName)
    Assert-False ($typeParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $typeParam.Position)
    Assert-True (0 -eq $typeParam.Aliases.Count)

    Assert-False ($matchTypeParam.IsMandatory)
    Assert-False ($matchTypeParam.ValueFromPipeline)
    Assert-False ($matchTypeParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchTypeParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchTypeParam.Position)
    Assert-True (0 -eq $matchTypeParam.Aliases.Count)

    Assert-True ($geParam.IsMandatory)
    Assert-False ($geParam.ValueFromPipeline)
    Assert-False ($geParam.ValueFromPipelineByPropertyName)
    Assert-False ($geParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $geParam.Position)
    Assert-True (1 -eq $geParam.Aliases.Count)
    Assert-True ('ge'.Equals($geParam.Aliases[0], [System.StringComparison]::OrdinalIgnoreCase))
}

& {
    Write-Verbose -Message 'Test Test-Number -IsNumber' -Verbose:$headerVerbosity

    $numbers = [System.Object[]]@(0, [System.Single]1.0, 2.718, [System.Decimal]3.1416)
    $nonNumbers = @(@($numbers[0]), @($numbers[1]), $true, $false, $null, '2.718', '3.1416')

    foreach ($number in $numbers) {
        Assert-True  (Test-Number $number)
        Assert-True  (Test-Number $number -IsNumber)
        Assert-True  (Test-Number $number -IsNumber:$true)
        Assert-False (Test-Number $number -IsNumber:$false)
    }

    foreach ($nonNumber in $nonNumbers) {
        Assert-False (Test-Number $nonNumber)
        Assert-False (Test-Number $nonNumber -IsNumber)
        Assert-False (Test-Number $nonNumber -IsNumber:$true)
        Assert-True  (Test-Number $nonNumber -IsNumber:$false)
    }
}

Write-Warning -Message 'Remaining tests not implemented here.' -WarningAction 'Continue'

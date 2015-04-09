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
    Write-Verbose -Message 'Test Test-DateTime with get-help -full' -Verbose:$headerVerbosity

    $err = try {$fullHelp = Get-Help Test-DateTime -Full} catch {$_}

    Assert-Null $err
    Assert-True ($fullHelp.Name -is [System.String])
    Assert-True ($fullHelp.Name.Equals('Test-DateTime', [System.StringComparison]::OrdinalIgnoreCase))
    Assert-True ($fullHelp.description -is [System.Collections.ICollection])
    Assert-True ($fullHelp.description.Count -gt 0)
    Assert-NotNull $fullHelp.examples
    Assert-True (0 -lt @($fullHelp.examples.example).Count)
    Assert-True ('' -ne @($fullHelp.examples.example)[0].code)
}

& {
    Write-Verbose -Message 'Test Test-DateTime ParameterSet: IsDateTime' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-DateTime).ParameterSets |
        Where-Object {'IsDateTime'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $kindParam = $paramSet.Parameters |
        Where-Object {'Kind'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $isParam = $paramSet.Parameters |
        Where-Object {'IsDateTime'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    Assert-True ($valueParam.IsMandatory)
    Assert-False ($valueParam.ValueFromPipeline)
    Assert-False ($valueParam.ValueFromPipelineByPropertyName)
    Assert-False ($valueParam.ValueFromRemainingArguments)
    Assert-True (0 -eq $valueParam.Position)
    Assert-True (0 -eq $valueParam.Aliases.Count)

    Assert-False ($kindParam.IsMandatory)
    Assert-False ($kindParam.ValueFromPipeline)
    Assert-False ($kindParam.ValueFromPipelineByPropertyName)
    Assert-False ($kindParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $kindParam.Position)
    Assert-True (0 -eq $kindParam.Aliases.Count)

    Assert-False ($isParam.IsMandatory)
    Assert-False ($isParam.ValueFromPipeline)
    Assert-False ($isParam.ValueFromPipelineByPropertyName)
    Assert-False ($isParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $isParam.Position)
    Assert-True (0 -eq $isParam.Aliases.Count)
}

& {
    Write-Verbose -Message 'Test Test-DateTime ParameterSet: OpEquals' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-DateTime).ParameterSets |
        Where-Object {'OpEquals'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $kindParam = $paramSet.Parameters |
        Where-Object {'Kind'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchKindParam = $paramSet.Parameters |
        Where-Object {'MatchKind'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($kindParam.IsMandatory)
    Assert-False ($kindParam.ValueFromPipeline)
    Assert-False ($kindParam.ValueFromPipelineByPropertyName)
    Assert-False ($kindParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $kindParam.Position)
    Assert-True (0 -eq $kindParam.Aliases.Count)

    Assert-False ($matchKindParam.IsMandatory)
    Assert-False ($matchKindParam.ValueFromPipeline)
    Assert-False ($matchKindParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchKindParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchKindParam.Position)
    Assert-True (0 -eq $matchKindParam.Aliases.Count)

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
    Write-Verbose -Message 'Test Test-DateTime ParameterSet: OpNotEquals' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-DateTime).ParameterSets |
        Where-Object {'OpNotEquals'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $kindParam = $paramSet.Parameters |
        Where-Object {'Kind'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchKindParam = $paramSet.Parameters |
        Where-Object {'MatchKind'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($kindParam.IsMandatory)
    Assert-False ($kindParam.ValueFromPipeline)
    Assert-False ($kindParam.ValueFromPipelineByPropertyName)
    Assert-False ($kindParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $kindParam.Position)
    Assert-True (0 -eq $kindParam.Aliases.Count)

    Assert-False ($matchKindParam.IsMandatory)
    Assert-False ($matchKindParam.ValueFromPipeline)
    Assert-False ($matchKindParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchKindParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchKindParam.Position)
    Assert-True (0 -eq $matchKindParam.Aliases.Count)

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
    Write-Verbose -Message 'Test Test-DateTime ParameterSet: OpLessThan' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-DateTime).ParameterSets |
        Where-Object {'OpLessThan'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $kindParam = $paramSet.Parameters |
        Where-Object {'Kind'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchKindParam = $paramSet.Parameters |
        Where-Object {'MatchKind'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($kindParam.IsMandatory)
    Assert-False ($kindParam.ValueFromPipeline)
    Assert-False ($kindParam.ValueFromPipelineByPropertyName)
    Assert-False ($kindParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $kindParam.Position)
    Assert-True (0 -eq $kindParam.Aliases.Count)

    Assert-False ($matchKindParam.IsMandatory)
    Assert-False ($matchKindParam.ValueFromPipeline)
    Assert-False ($matchKindParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchKindParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchKindParam.Position)
    Assert-True (0 -eq $matchKindParam.Aliases.Count)

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
    Write-Verbose -Message 'Test Test-DateTime ParameterSet: OpLessThanOrEqualTo' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-DateTime).ParameterSets |
        Where-Object {'OpLessThanOrEqualTo'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $kindParam = $paramSet.Parameters |
        Where-Object {'Kind'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchKindParam = $paramSet.Parameters |
        Where-Object {'MatchKind'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($kindParam.IsMandatory)
    Assert-False ($kindParam.ValueFromPipeline)
    Assert-False ($kindParam.ValueFromPipelineByPropertyName)
    Assert-False ($kindParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $kindParam.Position)
    Assert-True (0 -eq $kindParam.Aliases.Count)

    Assert-False ($matchKindParam.IsMandatory)
    Assert-False ($matchKindParam.ValueFromPipeline)
    Assert-False ($matchKindParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchKindParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchKindParam.Position)
    Assert-True (0 -eq $matchKindParam.Aliases.Count)

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
    Write-Verbose -Message 'Test Test-DateTime ParameterSet: OpGreaterThan' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-DateTime).ParameterSets |
        Where-Object {'OpGreaterThan'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $kindParam = $paramSet.Parameters |
        Where-Object {'Kind'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchKindParam = $paramSet.Parameters |
        Where-Object {'MatchKind'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($kindParam.IsMandatory)
    Assert-False ($kindParam.ValueFromPipeline)
    Assert-False ($kindParam.ValueFromPipelineByPropertyName)
    Assert-False ($kindParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $kindParam.Position)
    Assert-True (0 -eq $kindParam.Aliases.Count)

    Assert-False ($matchKindParam.IsMandatory)
    Assert-False ($matchKindParam.ValueFromPipeline)
    Assert-False ($matchKindParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchKindParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchKindParam.Position)
    Assert-True (0 -eq $matchKindParam.Aliases.Count)

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
    Write-Verbose -Message 'Test Test-DateTime ParameterSet: OpGreaterThanOrEqualTo' -Verbose:$headerVerbosity

    $paramSet = (Get-Command -Name Test-DateTime).ParameterSets |
        Where-Object {'OpGreaterThanOrEqualTo'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $valueParam = $paramSet.Parameters |
        Where-Object {'Value'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $kindParam = $paramSet.Parameters |
        Where-Object {'Kind'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
        Assert-PipelineSingle

    $matchKindParam = $paramSet.Parameters |
        Where-Object {'MatchKind'.Equals($_.Name, [System.StringComparison]::OrdinalIgnoreCase)} |
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

    Assert-False ($kindParam.IsMandatory)
    Assert-False ($kindParam.ValueFromPipeline)
    Assert-False ($kindParam.ValueFromPipelineByPropertyName)
    Assert-False ($kindParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $kindParam.Position)
    Assert-True (0 -eq $kindParam.Aliases.Count)

    Assert-False ($matchKindParam.IsMandatory)
    Assert-False ($matchKindParam.ValueFromPipeline)
    Assert-False ($matchKindParam.ValueFromPipelineByPropertyName)
    Assert-False ($matchKindParam.ValueFromRemainingArguments)
    Assert-True (0 -gt $matchKindParam.Position)
    Assert-True (0 -eq $matchKindParam.Aliases.Count)

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
    Write-Verbose -Message 'Test Test-DateTime -IsDateTime' -Verbose:$headerVerbosity

    $dateTimes = [System.DateTime[]]@(0, 1, '2015-06-28', '2016-03-14')
    $nonDateTimes = @(@($dateTimes[0]), @($dateTimes[1]), $true, $false, $null, 0, 1, '2015-06-28', '2016-03-14')

    foreach ($dateTime in $dateTimes) {
        Assert-True  (Test-DateTime $dateTime)
        Assert-True  (Test-DateTime $dateTime -IsDateTime)
        Assert-True  (Test-DateTime $dateTime -IsDateTime:$true)
        Assert-False (Test-DateTime $dateTime -IsDateTime:$false)
    }

    foreach ($nonDateTime in $nonDateTimes) {
        Assert-False (Test-DateTime $nonDateTime)
        Assert-False (Test-DateTime $nonDateTime -IsDateTime)
        Assert-False (Test-DateTime $nonDateTime -IsDateTime:$true)
        Assert-True  (Test-DateTime $nonDateTime -IsDateTime:$false)
    }
}

Write-Warning -Message 'Remaining tests not implemented here.' -WarningAction 'Continue'

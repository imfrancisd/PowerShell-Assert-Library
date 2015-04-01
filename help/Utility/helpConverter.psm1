$shared = @{
    'xmlDoc' = $null
    'xmlRoot' = $null
    'cmdUri' = 'http://schemas.microsoft.com/maml/dev/command/2004/10'
    'mamlUri' = 'http://schemas.microsoft.com/maml/2004/10'
    'devUri' = 'http://schemas.microsoft.com/maml/dev/2004/10'
    'helpUri' = 'http://msdn.microsoft.com/mshelp'
}

function Clear-MamlHelp
{
    [CmdletBinding()]
    Param()

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    $xmlDoc = New-Object -TypeName 'System.Xml.XmlDocument'

        $xmlDec = $xmlDoc.CreateXmlDeclaration('1.0', 'utf-8', '')
        [System.Void]$xmlDoc.AppendChild($xmlDec)

        $xmlRoot = $xmlDoc.CreateElement('helpItems')
            $xmlAttr = $xmlDoc.CreateAttribute('schema')
                $xmlAttrValue = $xmlDoc.CreateTextNode('maml')
                [System.Void]$xmlAttr.AppendChild($xmlAttrValue)
            [System.Void]$xmlRoot.Attributes.Append($xmlAttr)
        [System.Void]$xmlDoc.AppendChild($xmlRoot)

    $shared.xmlDoc = $xmlDoc
    $shared.xmlRoot = $xmlRoot
}

function Get-MamlHelp
{
    [CmdletBinding()]
    Param()

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    $tmp = [System.IO.Path]::GetTempFileName()
    try {
        $shared.xmlDoc.Save($tmp)
        Get-Content -LiteralPath $tmp
    } finally {
        Remove-Item -LiteralPath $tmp
    }
}

function Add-MamlHelpCommand
{
    [CmdletBinding()]
    Param($CommandName)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    $cmd = $shared.xmlDoc.CreateElement('command', 'command', $shared.cmdUri)
        $attributes = @(
            @('xmlns:maml', $shared.mamlUri),
            @('xmlns:dev', $shared.devUri),
            @('xmlns:MSHelp', $shared.helpUri)
        )
        foreach ($item in $attributes) {
            $xmlAttr = $shared.xmlDoc.CreateAttribute($item[0])
                $xmlAttrValue = $shared.xmlDoc.CreateTextNode($item[1])
                [System.Void]$xmlAttr.AppendChild($xmlAttrValue)
            [System.Void]$cmd.Attributes.Append($xmlAttr)
        }

        $cmdSyntax = $shared.xmlDoc.CreateElement('command', 'syntax', $shared.cmdUri)
        foreach ($syntaxItem in (Get-Help $CommandName -Full).syntax.syntaxItem) {
            $cmdSyntaxItem = $shared.xmlDoc.CreateElement('command', 'syntaxItem', $shared.cmdUri)

                $cmdSyntaxItemName = $shared.xmlDoc.CreateElement('maml', 'name', $shared.mamlUri)
                    $cmdSyntaxItemNameValue = $shared.xmlDoc.CreateTextNode($syntaxItem.name)
                    [System.Void]$cmdSyntaxItemName.AppendChild($cmdSyntaxItemNameValue)
                [System.Void]$cmdSyntaxItem.AppendChild($cmdSyntaxItemName)

                foreach ($syntaxItemParameter in $syntaxItem.parameter) {
                    $cmdSyntaxItemParameter = $shared.xmlDoc.CreateElement('command', 'parameter', $shared.cmdUri)
                        $attributes = @(
                            @('required', $syntaxItemParameter.required),
                            @('globbing', $syntaxItemParameter.globbing),
                            @('pipelineInput', $syntaxItemParameter.pipelineInput),
                            @('position', $syntaxItemParameter.position)
                        )
                        foreach ($item in $attributes) {
                            $xmlAttr = $shared.xmlDoc.CreateAttribute($item[0])
                                $xmlAttrValue = $shared.xmlDoc.CreateTextNode($item[1])
                                [System.Void]$xmlAttr.AppendChild($xmlAttrValue)
                            [System.Void]$cmdSyntaxItemParameter.Attributes.Append($xmlAttr)
                        }

                        $cmdSyntaxItemParameterName = $shared.xmlDoc.CreateElement('maml', 'name', $shared.mamlUri)
                            $cmdSyntaxItemParameterNameValue = $shared.xmlDoc.CreateTextNode($syntaxItemParameter.name)
                            [System.Void]$cmdSyntaxItemParameterName.AppendChild($cmdSyntaxItemParameterNameValue)
                        [System.Void]$cmdSyntaxItemParameter.AppendChild($cmdSyntaxItemParameterName)

                        if ($null -ne $syntaxItemParameter.parameterValue) {
                            $cmdSyntaxItemParameterValue = $shared.xmlDoc.CreateElement('command', 'parameterValue', $shared.cmdUri)
                                $xmlAttr = $shared.xmlDoc.CreateAttribute('required')
                                    $xmlAttrValue = $shared.xmlDoc.CreateTextNode($syntaxItemParameter.parameterValue.required)
                                    [System.Void]$xmlAttr.AppendChild($xmlAttrValue)
                                [System.Void]$cmdSyntaxItemParameterValue.Attributes.Append($xmlAttr)

                                $cmdSyntaxItemParameterValueValue = $shared.xmlDoc.CreateTextNode($syntaxItemParameter.parameterValue)
                                [System.Void]$cmdSyntaxItemParameterValue.AppendChild($cmdSyntaxItemParameterValueValue)
                            [System.Void]$cmdSyntaxItemParameter.AppendChild($cmdSyntaxItemParameterValue)
                        }

                    [System.Void]$cmdSyntaxItem.AppendChild($cmdSyntaxItemParameter)
                }

            [System.Void]$cmdSyntax.AppendChild($cmdSyntaxItem)
        }
        [System.Void]$cmd.AppendChild($cmdSyntax)

        $cmdParameters = $shared.xmlDoc.CreateElement('command', 'parameters', $shared.cmdUri)
        foreach ($parameter in (Get-Help $CommandName -Full).parameters.parameter) {
            $cmdParameter = $shared.xmlDoc.CreateElement('command', 'parameter', $shared.cmdUri)
                $attributes = @(
                    @('required', $parameter.required),
                    @('globbing', $parameter.globbing),
                    @('pipelineInput', $parameter.pipelineInput),
                    @('position', $parameter.position)
                )
                foreach ($item in $attributes) {
                    $xmlAttr = $shared.xmlDoc.CreateAttribute($item[0])
                        $xmlAttrValue = $shared.xmlDoc.CreateTextNode($item[1])
                        [System.Void]$xmlAttr.AppendChild($xmlAttrValue)
                    [System.Void]$cmdParameter.Attributes.Append($xmlAttr)
                }

                $cmdParameterName = $shared.xmlDoc.CreateElement('maml', 'name', $shared.mamlUri)
                    $cmdParameterNameValue = $shared.xmlDoc.CreateTextNode($parameter.name)
                    [System.Void]$cmdParameterName.AppendChild($cmdParameterNameValue)
                [System.Void]$cmdParameter.AppendChild($cmdParameterName)

                $cmdParameterDescription = $shared.xmlDoc.CreateElement('maml', 'description', $shared.mamlUri)
                    $para = $shared.xmlDoc.CreateElement('maml', 'para', $shared.mamlUri)
                        $paraValue = $shared.xmlDoc.CreateTextNode($parameter.description[0].Text)
                        [System.Void]$para.AppendChild($paraValue)
                    [System.Void]$cmdParameterDescription.AppendChild($para)
                [System.Void]$cmdParameter.AppendChild($cmdParameterDescription)

                $cmdParameterValue = $shared.xmlDoc.CreateElement('command', 'parameterValue', $shared.cmdUri)
                    $xmlAttr = $shared.xmlDoc.CreateAttribute('required')
                        $xmlAttrValue = $shared.xmlDoc.CreateTextNode($parameter.parameterValue.required)
                        [System.Void]$xmlAttr.AppendChild($xmlAttrValue)
                    [System.Void]$cmdParameterValue.Attributes.Append($xmlAttr)

                    $cmdParameterValueValue = $shared.xmlDoc.CreateTextNode($parameter.parameterValue)
                    [System.Void]$cmdParameterValue.AppendChild($cmdParameterValueValue)
                [System.Void]$cmdParameter.AppendChild($cmdParameterValue)

                $cmdParameterType = $shared.xmlDoc.CreateElement('dev', 'type', $shared.devUri)
                    $cmdParameterTypeName = $shared.xmlDoc.CreateElement('maml', 'name', $shared.mamlUri)
                        $cmdParameterTypeNameValue = $shared.xmlDoc.CreateTextNode($parameter.type.name)
                        [System.Void]$cmdParameterTypeName.AppendChild($cmdParameterTypeNameValue)
                    [System.Void]$cmdParameterType.AppendChild($cmdParameterTypeName)
                [System.Void]$cmdParameter.AppendChild($cmdParameterType)

                $cmdParameterDefaultValue = $shared.xmlDoc.CreateElement('dev', 'defaultValue', $shared.devUri)
                    $cmdParameterDefaultValueValue = $shared.xmlDoc.CreateTextNode($parameter.defaultValue)
                    [System.Void]$cmdParameterDefaultValue.AppendChild($cmdParameterDefaultValueValue)
                [System.Void]$cmdParameter.AppendChild($cmdParameterDefaultValue)

            [System.Void]$cmdParameters.AppendChild($cmdParameter)
        }
        [System.Void]$cmd.AppendChild($cmdParameters)

        $cmdDetails = $shared.xmlDoc.CreateElement('command', 'details', $shared.cmdUri)

            $cmdName = $shared.xmlDoc.CreateElement('command', 'name', $shared.cmdUri)
                $cmdNameValue = $shared.xmlDoc.CreateTextNode($CommandName)
                [System.Void]$cmdName.AppendChild($cmdNameValue)
            [System.Void]$cmdDetails.AppendChild($cmdName)

            $cmdVerb = $shared.xmlDoc.CreateElement('command', 'verb', $shared.cmdUri)
                $cmdVerbValue = $shared.xmlDoc.CreateTextNode((Get-Command $CommandName).Verb)
                [System.Void]$cmdVerb.AppendChild($cmdVerbValue)
            [System.Void]$cmdDetails.AppendChild($cmdVerb)

            $cmdNoun = $shared.xmlDoc.CreateElement('command', 'noun', $shared.cmdUri)
                $cmdNounValue = $shared.xmlDoc.CreateTextNode((Get-Command $CommandName).Noun)
                [System.Void]$cmdNoun.AppendChild($cmdNounValue)
            [System.Void]$cmdDetails.AppendChild($cmdNoun)

            $cmdSynopsis = $shared.xmlDoc.CreateElement('maml', 'description', $shared.mamlUri)
                $para = $shared.xmlDoc.CreateElement('maml', 'para', $shared.mamlUri)
                    $paraValue = $shared.xmlDoc.CreateTextNode((Get-Help $CommandName -Full).details.description[0].Text)
                    [System.Void]$para.AppendChild($paraValue)
                [System.Void]$cmdSynopsis.AppendChild($para)
            [System.Void]$cmdDetails.AppendChild($cmdSynopsis)

        [System.Void]$cmd.AppendChild($cmdDetails)

        $cmdDescription = $shared.xmlDoc.CreateElement('maml', 'description', $shared.mamlUri)
            $para = $shared.xmlDoc.CreateElement('maml', 'para', $shared.mamlUri)
                $paraValue = $shared.xmlDoc.CreateTextNode((Get-Help $CommandName -Full).description[0].Text)
                [System.Void]$para.AppendChild($paraValue)
            [System.Void]$cmdDescription.AppendChild($para)
        [System.Void]$cmd.AppendChild($cmdDescription)

        $cmdInputs = $shared.xmlDoc.CreateElement('command', 'inputTypes', $shared.cmdUri)
            $cmdInput = $shared.xmlDoc.CreateElement('command', 'inputType', $shared.cmdUri)
                $cmdInputType = $shared.xmlDoc.CreateElement('dev', 'type', $shared.devUri)
                    $cmdInputTypeName = $shared.xmlDoc.CreateElement('maml', 'name', $shared.mamlUri)
                        $cmdInputTypeNameValue = $shared.xmlDoc.CreateTextNode((Get-Help $CommandName -Full).inputTypes.inputType.type.name)
                        [System.Void]$cmdInputTypeName.AppendChild($cmdInputTypeNameValue)
                    [System.Void]$cmdInputType.AppendChild($cmdInputTypeName)
                [System.Void]$cmdInput.AppendChild($cmdInputType)
            [System.Void]$cmdInputs.AppendChild($cmdInput)
        [System.Void]$cmd.AppendChild($cmdInputs)

        $cmdOutputs = $shared.xmlDoc.CreateElement('command', 'returnValues', $shared.cmdUri)
            $cmdOutput = $shared.xmlDoc.CreateElement('command', 'returnValue', $shared.cmdUri)
                $cmdOutputType = $shared.xmlDoc.CreateElement('dev', 'type', $shared.devUri)
                    $cmdOutputTypeName = $shared.xmlDoc.CreateElement('maml', 'name', $shared.mamlUri)
                        $cmdOutputTypeNameValue = $shared.xmlDoc.CreateTextNode((Get-Help $CommandName -Full).returnValues.returnValue.type.name)
                        [System.Void]$cmdOutputTypeName.AppendChild($cmdOutputTypeNameValue)
                    [System.Void]$cmdOutputType.AppendChild($cmdOutputTypeName)
                [System.Void]$cmdOutput.AppendChild($cmdOutputType)
            [System.Void]$cmdOutputs.AppendChild($cmdOutput)
        [System.Void]$cmd.AppendChild($cmdOutputs)

        $cmdNotes = $shared.xmlDoc.CreateElement('maml', 'alertSet', $shared.mamlUri)
            $cmdNote = $shared.xmlDoc.CreateElement('maml', 'alert', $shared.mamlUri)
                $para = $shared.xmlDoc.CreateElement('maml', 'para', $shared.mamlUri)
                    $paraValue = $shared.xmlDoc.CreateTextNode((Get-Help $CommandName -Full).alertSet.alert[0].Text)
                    [System.Void]$para.AppendChild($paraValue)
                [System.Void]$cmdNote.AppendChild($para)
            [System.Void]$cmdNotes.AppendChild($cmdNote)
        [System.Void]$cmd.AppendChild($cmdNotes)

        $cmdExamples = $shared.xmlDoc.CreateElement('command', 'examples', $shared.cmdUri)
        foreach ($example in (Get-Help $CommandName -Full).examples.example) {
            $cmdExample = $shared.xmlDoc.CreateElement('command', 'example', $shared.cmdUri)

                $cmdExampleTitle = $shared.xmlDoc.CreateElement('maml', 'title', $shared.mamlUri)
                    $cmdExampleTitleValue = $shared.xmlDoc.CreateTextNode($example.title)
                    [System.Void]$cmdExampleTitle.AppendChild($cmdExampleTitleValue)
                [System.Void]$cmdExample.AppendChild($cmdExampleTitle)

                $cmdExampleIntroduction = $shared.xmlDoc.CreateElement('maml', 'introduction', $shared.mamlUri)
                    $para = $shared.xmlDoc.CreateElement('maml', 'para', $shared.mamlUri)
                        $paraValue = $shared.xmlDoc.CreateTextNode($example.introduction[0].Text)
                        [System.Void]$para.AppendChild($paraValue)
                    [System.Void]$cmdExampleIntroduction.AppendChild($para)
                [System.Void]$cmdExample.AppendChild($cmdExampleIntroduction)

                $cmdExampleCode = $shared.xmlDoc.CreateElement('dev', 'code', $shared.devUri)
                    $cmdExampleCodeValue = $shared.xmlDoc.CreateTextNode($example.code)
                    [System.Void]$cmdExampleCode.AppendChild($cmdExampleCodeValue)
                [System.Void]$cmdExample.AppendChild($cmdExampleCode)

                $cmdExampleRemarks = $shared.xmlDoc.CreateElement('dev', 'remarks', $shared.devUri)
                foreach ($remark in $example.remarks) {
                    $para = $shared.xmlDoc.CreateElement('maml', 'para', $shared.mamlUri)
                        $paraValue = $shared.xmlDoc.CreateTextNode($remark.Text)
                        [System.Void]$para.AppendChild($paraValue)
                    [System.Void]$cmdExampleRemarks.AppendChild($para)
                }
                [System.Void]$cmdExample.AppendChild($cmdExampleRemarks)

            [System.Void]$cmdExamples.AppendChild($cmdExample)
        }
        [System.Void]$cmd.AppendChild($cmdExamples)

        $cmdRelatedLinks = $shared.xmlDoc.CreateElement('maml', 'relatedLinks', $shared.mamlUri)
            $cmdRelatedLink = $shared.xmlDoc.CreateElement('maml', 'navigationLink', $shared.mamlUri)
                $cmdRelatedLinkText = $shared.xmlDoc.CreateElement('maml', 'linkText', $shared.mamlUri)
                    $cmdRelatedLinkTextValue = $shared.xmlDoc.CreateTextNode((Get-Help $CommandName -Full).relatedLinks.navigationLink.linkText)
                    [System.Void]$cmdRelatedLinkText.AppendChild($cmdRelatedLinkTextValue)
                [System.Void]$cmdRelatedLink.AppendChild($cmdRelatedLinkText)
            [System.Void]$cmdRelatedLinks.AppendChild($cmdRelatedLink)
        [System.Void]$cmd.AppendChild($cmdRelatedLinks)

    [System.Void]$shared.xmlRoot.AppendChild($cmd)
}

Clear-MamlHelp

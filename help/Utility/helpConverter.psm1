$shared = @{
    'xmlDoc' = $null
    'xmlRoot' = $null
    'cmdUri' = 'http://schemas.microsoft.com/maml/dev/command/2004/10'
    'mamlUri' = 'http://schemas.microsoft.com/maml/2004/10'
    'devUri' = 'http://schemas.microsoft.com/maml/dev/2004/10'
    'helpUri' = 'http://msdn.microsoft.com/mshelp'
}

function _addAttribute
{
    [CmdletBinding()]
    Param($parent, $attributeName, $attributeText)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    $xmlAttr = $shared.xmlDoc.CreateAttribute($attributeName)
        $xmlAttrValue = $shared.xmlDoc.CreateTextNode($attributeText)
        [System.Void]$xmlAttr.AppendChild($xmlAttrValue)
    [System.Void]$parent.Attributes.Append($xmlAttr)
}

function _addTextElement
{
    [CmdletBinding()]
    Param($parent, $text)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    if (-not [System.String]::IsNullOrEmpty($text)) {
        $child = $shared.xmlDoc.CreateTextNode($text)
        [System.Void]$parent.AppendChild($child)
    }
}

function _addParaCollection
{
    [CmdletBinding()]
    Param($parent, $paraCollection)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    if (($null -eq $paraCollection) -or (0 -eq $paraCollection.Count)) {
        [System.Void]$parent.AppendChild($shared.xmlDoc.CreateElement('maml', 'para', $shared.mamlUri))
        return
    }

    foreach ($item in $paraCollection) {
        $para = $shared.xmlDoc.CreateElement('maml', 'para', $shared.mamlUri)
            _addTextElement $para $item.Text
        [System.Void]$parent.AppendChild($para)
    }
}

function Clear-MamlHelp
{
    [CmdletBinding()]
    Param()

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    $xmlDoc = New-Object -TypeName 'System.Xml.XmlDocument'

        $xmlDec = $xmlDoc.CreateXmlDeclaration('1.0', 'utf-8', '')
        [System.Void]$xmlDoc.AppendChild($xmlDec)
        $shared.xmlDoc = $xmlDoc

        $xmlRoot = $xmlDoc.CreateElement('helpItems', 'http://msh')
            _addAttribute $xmlRoot 'xmlns' 'http://msh'
            _addAttribute $xmlRoot 'schema' 'maml'
        [System.Void]$xmlDoc.AppendChild($xmlRoot)
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

    $fullCmd = Get-Command $CommandName

    $fullHelp = Get-Help $CommandName -Full
    $fullHelpHasDetails = $null -ne $fullHelp.details
    $fullHelpHasDescription = $null -ne $fullHelp.description
    $fullHelpHasSyntax =
        ($null -ne $fullHelp.syntax) -and
        ($null -ne $fullHelp.syntax.syntaxItem) -and
        (0 -lt @($fullHelp.syntax.syntaxItem).Count)
    $fullHelpHasParameters =
        ($null -ne $fullHelp.parameters) -and
        ($null -ne $fullHelp.parameters.parameter) -and
        (0 -lt @($fullHelp.parameters.parameter).Count)
    $fullHelpHasInputs =
        ($null -ne $fullHelp.inputTypes) -and
        ($null -ne $fullHelp.inputTypes.inputType) -and
        (0 -lt @($fullHelp.inputTypes.inputType).Count)
    $fullHelpHasOutputs =
        ($null -ne $fullHelp.returnValues) -and
        ($null -ne $fullHelp.returnValues.returnValue) -and
        (0 -lt @($fullHelp.returnValues.returnValue).Count)
    $fullHelpHasNotes =
        ($null -ne $fullHelp.alertSet) -and
        ($null -ne $fullHelp.alertSet.alert) -and
        (0 -lt @($fullHelp.alertSet.alert).Count)
    $fullHelpHasExamples =
        ($null -ne $fullHelp.examples) -and
        ($null -ne $fullHelp.examples.example) -and
        (0 -lt @($fullHelp.examples.example).Count)
    $fullHelpHasRelatedLinks =
        ($null -ne $fullHelp.relatedLinks) -and
        ($null -ne $fullHelp.relatedLinks.navigationLink) -and
        (0 -lt @($fullHelp.relatedLinks.navigationLink).Count)
        
    $cmd = $shared.xmlDoc.CreateElement('command', 'command', $shared.cmdUri)

        _addAttribute $cmd 'xmlns:maml' $shared.mamlUri
        _addAttribute $cmd 'xmlns:command' $shared.cmdUri
        _addAttribute $cmd 'xmlns:dev' $shared.devUri
        _addAttribute $cmd 'xmlns:MSHelp' $shared.helpUri

        #===========
        #PSMaml Note
        #===========
        #Name, Synopsis, Copyright, Verb, Noun, and Version must always be present, in that order.

        $cmdDetails = $shared.xmlDoc.CreateElement('command', 'details', $shared.cmdUri)

            $cmdName = $shared.xmlDoc.CreateElement('command', 'name', $shared.cmdUri)
                _addTextElement $cmdName $fullCmd.Name
            [System.Void]$cmdDetails.AppendChild($cmdName)

            $cmdSynopsis = $shared.xmlDoc.CreateElement('maml', 'description', $shared.mamlUri)
                _addParaCollection $cmdSynopsis $(if ($fullHelpHasDetails) {,$fullHelp.details.description} else {,@()})
            [System.Void]$cmdDetails.AppendChild($cmdSynopsis)

            $cmdCopyright = $shared.xmlDoc.CreateElement('maml', 'copyright', $shared.mamlUri)
                _addParaCollection $cmdCopyright $(if ($fullHelpHasDetails) {,$fullHelp.details.copyright} else {,@()})
            [System.Void]$cmdDetails.AppendChild($cmdCopyright)

            $cmdVerb = $shared.xmlDoc.CreateElement('command', 'verb', $shared.cmdUri)
                _addTextElement $cmdVerb $fullCmd.Verb
            [System.Void]$cmdDetails.AppendChild($cmdVerb)

            $cmdNoun = $shared.xmlDoc.CreateElement('command', 'noun', $shared.cmdUri)
                _addTextElement $cmdNoun $fullCmd.Noun
            [System.Void]$cmdDetails.AppendChild($cmdNoun)

            $cmdVersion = $shared.xmlDoc.CreateElement('dev', 'version', $shared.devUri)
                _addTextElement $cmdVersion $(if ($fullHelpHasDetails) {$fullHelp.details.version} else {''})
            [System.Void]$cmdDetails.AppendChild($cmdVersion)

        [System.Void]$cmd.AppendChild($cmdDetails)

        #===========
        #PSMaml Note
        #===========
        #Description must always be present.

        $cmdDescription = $shared.xmlDoc.CreateElement('maml', 'description', $shared.mamlUri)

            _addParaCollection $cmdDescription $(if ($fullHelpHasDescription) {,$fullHelp.description} else {,@()})

        [System.Void]$cmd.AppendChild($cmdDescription)

        #===========
        #PSMaml Note
        #===========
        #Syntax may be present?

        if ($fullHelpHasSyntax) {
            $cmdSyntax = $shared.xmlDoc.CreateElement('command', 'syntax', $shared.cmdUri)
                foreach ($syntaxItem in $fullHelp.syntax.syntaxItem) {
                    $cmdSyntaxItem = $shared.xmlDoc.CreateElement('command', 'syntaxItem', $shared.cmdUri)

                        $cmdSyntaxItemName = $shared.xmlDoc.CreateElement('maml', 'name', $shared.mamlUri)
                            _addTextElement $cmdSyntaxItemName $syntaxItem.name
                        [System.Void]$cmdSyntaxItem.AppendChild($cmdSyntaxItemName)

                        foreach ($syntaxItemParameter in $syntaxItem.parameter) {
                            $cmdSyntaxItemParameter = $shared.xmlDoc.CreateElement('command', 'parameter', $shared.cmdUri)
                                _addAttribute $cmdSyntaxItemParameter 'required' $syntaxItemParameter.required
                                _addAttribute $cmdSyntaxItemParameter 'globbing' $syntaxItemParameter.globbing
                                _addAttribute $cmdSyntaxItemParameter 'pipelineInput' $syntaxItemParameter.pipelineInput
                                _addAttribute $cmdSyntaxItemParameter 'position' $syntaxItemParameter.position
                                _addAttribute $cmdSyntaxItemParameter 'aliases' ([System.String]::Join(',', $fullCmd.Parameters[$syntaxItemParameter.name].Aliases))

                                $cmdSyntaxItemParameterName = $shared.xmlDoc.CreateElement('maml', 'name', $shared.mamlUri)
                                    _addTextElement $cmdSyntaxItemParameterName $syntaxItemParameter.name
                                [System.Void]$cmdSyntaxItemParameter.AppendChild($cmdSyntaxItemParameterName)

                                #null check for SwitchParameter
                                if ($null -ne $syntaxItemParameter.parameterValue) {
                                    $cmdSyntaxItemParameterValue = $shared.xmlDoc.CreateElement('command', 'parameterValue', $shared.cmdUri)
                                        _addAttribute $cmdSyntaxItemParameterValue 'required' $syntaxItemParameter.parameterValue.required
                                        _addTextElement $cmdSyntaxItemParameterValue $syntaxItemParameter.parameterValue
                                    [System.Void]$cmdSyntaxItemParameter.AppendChild($cmdSyntaxItemParameterValue)
                                }

                            [System.Void]$cmdSyntaxItem.AppendChild($cmdSyntaxItemParameter)
                        }

                    [System.Void]$cmdSyntax.AppendChild($cmdSyntaxItem)
                }
            [System.Void]$cmd.AppendChild($cmdSyntax)
        }

        #===========
        #PSMaml Note
        #===========
        #Parameters may be present?

        if ($fullHelpHasParameters) {
            $cmdParameters = $shared.xmlDoc.CreateElement('command', 'parameters', $shared.cmdUri)
                foreach ($parameter in $fullHelp.parameters.parameter) {
                    $cmdParameter = $shared.xmlDoc.CreateElement('command', 'parameter', $shared.cmdUri)

                        _addAttribute $cmdParameter 'required' $parameter.required
                        _addAttribute $cmdParameter 'globbing' $parameter.globbing
                        _addAttribute $cmdParameter 'pipelineInput' $parameter.pipelineInput
                        _addAttribute $cmdParameter 'position' $parameter.position
                        _addAttribute $cmdParameter 'aliases' ([System.String]::Join(',', $fullCmd.Parameters[$parameter.name].Aliases))

                        $cmdParameterName = $shared.xmlDoc.CreateElement('maml', 'name', $shared.mamlUri)
                            _addTextElement $cmdParameterName $parameter.name
                        [System.Void]$cmdParameter.AppendChild($cmdParameterName)

                        $cmdParameterDescription = $shared.xmlDoc.CreateElement('maml', 'description', $shared.mamlUri)
                            _addParaCollection $cmdParameterDescription $parameter.description
                        [System.Void]$cmdParameter.AppendChild($cmdParameterDescription)

                        $cmdParameterValue = $shared.xmlDoc.CreateElement('command', 'parameterValue', $shared.cmdUri)
                            _addAttribute $cmdParameterValue 'required' $parameter.parameterValue.required

                            _addTextElement $cmdParameterValue $parameter.parameterValue
                        [System.Void]$cmdParameter.AppendChild($cmdParameterValue)

                        $cmdParameterType = $shared.xmlDoc.CreateElement('dev', 'type', $shared.devUri)
                            $cmdParameterTypeName = $shared.xmlDoc.CreateElement('maml', 'name', $shared.mamlUri)
                                _addTextElement $cmdParameterTypeName $parameter.type.name
                            [System.Void]$cmdParameterType.AppendChild($cmdParameterTypeName)
                            
                            $cmdParameterTypeUri = $shared.xmlDoc.CreateElement('maml', 'uri', $shared.mamlUri)
                                _addTextElement $cmdParameterTypeUri $parameter.type.uri
                            [System.Void]$cmdParameterType.AppendChild($cmdParameterTypeUri)
                        [System.Void]$cmdParameter.AppendChild($cmdParameterType)

                        $cmdParameterDefaultValue = $shared.xmlDoc.CreateElement('dev', 'defaultValue', $shared.devUri)
                            $cmdParameterDefaultValueValue = $shared.xmlDoc.CreateTextNode($parameter.defaultValue)
                            [System.Void]$cmdParameterDefaultValue.AppendChild($cmdParameterDefaultValueValue)
                        [System.Void]$cmdParameter.AppendChild($cmdParameterDefaultValue)

                    [System.Void]$cmdParameters.AppendChild($cmdParameter)
                }
            [System.Void]$cmd.AppendChild($cmdParameters)
        }

        #===========
        #PSMaml Note
        #===========
        #Inputs may be present?

        if ($fullHelpHasInputs) {
            $cmdInputs = $shared.xmlDoc.CreateElement('command', 'inputTypes', $shared.cmdUri)
                foreach ($inputType in $fullHelp.inputTypes.inputType) {
                    $cmdInput = $shared.xmlDoc.CreateElement('command', 'inputType', $shared.cmdUri)

                        $cmdInputType = $shared.xmlDoc.CreateElement('dev', 'type', $shared.devUri)

                            $cmdInputTypeName = $shared.xmlDoc.CreateElement('maml', 'name', $shared.mamlUri)
                                _addTextElement $cmdInputTypeName $inputType.type.name
                            [System.Void]$cmdInputType.AppendChild($cmdInputTypeName)

                            $cmdInputTypeUri = $shared.xmlDoc.CreateElement('maml', 'uri', $shared.mamlUri)
                                _addTextElement $cmdInputTypeUri $inputType.type.uri
                            [System.Void]$cmdInputType.AppendChild($cmdInputTypeUri)

                        [System.Void]$cmdInput.AppendChild($cmdInputType)

                    [System.Void]$cmdInputs.AppendChild($cmdInput)
                }
            [System.Void]$cmd.AppendChild($cmdInputs)
        }

        #===========
        #PSMaml Note
        #===========
        #Outputs may be present?

        if ($fullHelpHasOutputs) {
            $cmdOutputs = $shared.xmlDoc.CreateElement('command', 'returnValues', $shared.cmdUri)
                foreach ($outputType in $fullHelp.returnValues.returnValue) {
                    $cmdOutput = $shared.xmlDoc.CreateElement('command', 'returnValue', $shared.cmdUri)

                        $cmdOutputType = $shared.xmlDoc.CreateElement('dev', 'type', $shared.devUri)

                            $cmdOutputTypeName = $shared.xmlDoc.CreateElement('maml', 'name', $shared.mamlUri)
                                _addTextElement $cmdOutputTypeName $outputType.type.name
                            [System.Void]$cmdOutputType.AppendChild($cmdOutputTypeName)

                            $cmdOutputTypeUri = $shared.xmlDoc.CreateElement('maml', 'uri', $shared.mamlUri)
                                _addTextElement $cmdOutputTypeUri $outputType.type.uri
                            [System.Void]$cmdOutputType.AppendChild($cmdOutputTypeUri)

                        [System.Void]$cmdOutput.AppendChild($cmdOutputType)

                    [System.Void]$cmdOutputs.AppendChild($cmdOutput)
                }
            [System.Void]$cmd.AppendChild($cmdOutputs)
        }

        #===========
        #PSMaml Note
        #===========
        #Outputs may be present?

        if ($fullHelpHasNotes) {
            $cmdNotes = $shared.xmlDoc.CreateElement('maml', 'alertSet', $shared.mamlUri)
                foreach ($note in $fullHelp.alertSet.alert) {
                    $cmdNote = $shared.xmlDoc.CreateElement('maml', 'alert', $shared.mamlUri)
                        _addParaCollection $cmdNote $note
                    [System.Void]$cmdNotes.AppendChild($cmdNote)
                }
            [System.Void]$cmd.AppendChild($cmdNotes)
        }

        #===========
        #PSMaml Note
        #===========
        #Examples may be present?

        if ($fullHelpHasExamples) {
            $cmdExamples = $shared.xmlDoc.CreateElement('command', 'examples', $shared.cmdUri)
                foreach ($example in $fullHelp.examples.example) {
                    $cmdExample = $shared.xmlDoc.CreateElement('command', 'example', $shared.cmdUri)

                        $cmdExampleTitle = $shared.xmlDoc.CreateElement('maml', 'title', $shared.mamlUri)
                            _addTextElement $cmdExampleTitle $example.title
                        [System.Void]$cmdExample.AppendChild($cmdExampleTitle)

                        $cmdExampleIntroduction = $shared.xmlDoc.CreateElement('maml', 'introduction', $shared.mamlUri)
                            _addParaCollection $cmdExampleIntroduction $example.introduction
                        [System.Void]$cmdExample.AppendChild($cmdExampleIntroduction)

                        $cmdExampleCode = $shared.xmlDoc.CreateElement('dev', 'code', $shared.devUri)
                            _addTextElement $cmdExampleCode $example.code
                        [System.Void]$cmdExample.AppendChild($cmdExampleCode)

                        $cmdExampleRemarks = $shared.xmlDoc.CreateElement('dev', 'remarks', $shared.devUri)
                            _addParaCollection $cmdExampleRemarks $example.remarks
                        [System.Void]$cmdExample.AppendChild($cmdExampleRemarks)

                    [System.Void]$cmdExamples.AppendChild($cmdExample)
                }
            [System.Void]$cmd.AppendChild($cmdExamples)
        }

        if ($fullHelpHasRelatedLinks) {
            $cmdRelatedLinks = $shared.xmlDoc.CreateElement('maml', 'relatedLinks', $shared.mamlUri)
                foreach ($navigationLink in $fullHelp.relatedLinks.navigationLink) {
                    $cmdRelatedLink = $shared.xmlDoc.CreateElement('maml', 'navigationLink', $shared.mamlUri)

                        $cmdRelatedLinkText = $shared.xmlDoc.CreateElement('maml', 'linkText', $shared.mamlUri)
                            _addTextElement $cmdRelatedLinkText $navigationLink.linkText
                        [System.Void]$cmdRelatedLink.AppendChild($cmdRelatedLinkText)

                        $cmdRelatedLinkUri = $shared.xmlDoc.CreateElement('maml', 'uri', $shared.mamlUri)
                            _addTextElement $cmdRelatedLinkUri $navigationLink.uri
                        [System.Void]$cmdRelatedLink.AppendChild($cmdRelatedLinkUri)

                    [System.Void]$cmdRelatedLinks.AppendChild($cmdRelatedLink)
                }
            [System.Void]$cmd.AppendChild($cmdRelatedLinks)
        }

    [System.Void]$shared.xmlRoot.AppendChild($cmd)
}

Clear-MamlHelp

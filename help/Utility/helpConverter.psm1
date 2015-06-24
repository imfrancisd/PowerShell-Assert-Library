$shared = @{
    'xmlDoc' = $null
    'xmlRoot' = $null
    'cmdUri' = 'http://schemas.microsoft.com/maml/dev/command/2004/10'
    'mamlUri' = 'http://schemas.microsoft.com/maml/2004/10'
    'devUri' = 'http://schemas.microsoft.com/maml/dev/2004/10'
    'helpUri' = 'http://msdn.microsoft.com/mshelp'
    'fullCmd' = $null
    'fullHelp' = $null
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

function _addElement
{
    [CmdletBinding()]
    Param($parent, $child)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    [System.Void]$parent.AppendChild($child)
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

function _newCommandName
{
    [CmdletBinding()]
    Param($name)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    #====================
    #PSMaml Note
    #developerCommand.xsd
    #====================
    #<element name="name" type="command:nameType"/>
    #<complexType name="nameType" mixed="true">
    #  <complexContent>
    #    <extension base="maml:nameType">
    #      <attribute name="commandType">
    #        <simpleType>
    #          <restriction base="token">
    #            <enumeration value="provider"/>
    #          </restriction>
    #        </simpleType>
    #      </attribute>
    #    </extension>
    #  </complexContent>
    #</complexType>

    #=============
    #PSMaml Note
    #structure.xsd
    #=============
    #<complexType name="nameType" mixed="true">
    #  <complexContent>
    #    <extension base="maml:textType"/>
    #  </complexContent>
    #</complexType>

    $xmlName = $shared.xmlDoc.CreateElement('command', 'name', $shared.cmdUri)

        if (-not [System.String]::IsNullOrEmpty($name)) {
            _addElement $xmlName (_newMamlTextType $name)
        }

    $xmlName
}

function _newCommandNoun
{
    [CmdletBinding()]
    Param($noun)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    #====================
    #PSMaml Note
    #developerCommand.xsd
    #====================
    #<element name="noun" type="maml:textType"/>

    $xmlNoun = $shared.xmlDoc.CreateElement('command', 'noun', $shared.cmdUri)

        if (-not [System.String]::IsNullOrEmpty($noun)) {
            _addElement $xmlNoun (_newMamlTextType $noun)
        }

    $xmlNoun
}

function _newCommandParameter
{
    [CmdletBinding()]
    Param($parameter)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    #====================
    #PSMaml Note
    #developerCommand.xsd
    #====================
    #<element name="parameter" type="command:parameterType"/>
    #<complexType name="parameterType">
    #  <sequence>
    #    <element ref="maml:name"/>
    #    <element ref="maml:description"/>
    #    <choice minOccurs="0">
    #      <element ref="command:parameterValue"/>
    #      <element ref="command:parameterValueGroup"/>
    #    </choice>
    #    <element ref="dev:type" minOccurs="0"/>
    #    <element ref="dev:defaultValue" minOccurs="0"/>
    #    <element ref="dev:possibleValues" minOccurs="0"/>
    #    <element ref="command:validation" minOccurs="0"/>
    #  </sequence>
    #  <attributeGroup ref="maml:contentIdentificationSharingAndConditionGroup"/>
    #  <attribute name="required" type="boolean" use="required"/>
    #  <attribute name="variableLength" type="boolean" use="required"/>
    #  <attribute name="globbing" type="boolean" use="required"/>
    #  <attribute name="pipelineInput" type="string" use="required"/>
    #  <attribute name="position" type="string" use="required"/>
    #  <attribute ref="command:requiresTrustedData" use="optional"/>
    #</complexType>
    #
    #<element name="parameterValue" type="command:parameterValueType"/>
    #<complexType name="parameterValueType" mixed="true">
    #  <complexContent>
    #    <extension base="maml:textType">
    #      <attribute name="required" type="boolean" use="required"/>
    #      <attribute name="variableLength" type="boolean" use="required"/>
    #      <attribute name="type" use="optional" default="literal">
    #        <simpleType>
    #          <restriction base="token">
    #            <enumeration value="literal"/>
    #            <enumeration value="placeHolder"/>
    #          </restriction>
    #        </simpleType>
    #      </attribute>
    #    </extension>
    #  </complexContent>
    #</complexType>

    $xmlParameter = $shared.xmlDoc.CreateElement('command', 'parameter', $shared.cmdUri)

        #PSMaml Note
        #variableLength seems to mean IList (true for arrays and false for hashtables)
        #however, some switch parameters also have variableLength as true.
        #If the information is not available, just make it true for IList and nothing else.

        if (-not [System.String]::IsNullOrEmpty($parameter.variableLength)) {
            $xmlParameterVariableLength = $parameter.variableLength
        } else {
            $typeInfo = $shared.fullCmd.Parameters[$parameter.name].ParameterType
            $xmlParameterVariableLength = $(
                ([System.Collections.IList] -eq $typeInfo) -or
                (0 -lt @($typeInfo.GetInterfaces() | Where-Object {[System.Collections.IList] -eq $_}).Count)
            ).ToString().ToLowerInvariant()
        }

        _addAttribute $xmlParameter 'required' $parameter.required
        _addAttribute $xmlParameter 'variableLength' $xmlParameterVariableLength
        _addAttribute $xmlParameter 'globbing' $parameter.globbing
        _addAttribute $xmlParameter 'pipelineInput' $parameter.pipelineInput
        _addAttribute $xmlParameter 'position' $parameter.position
        _addAttribute $xmlParameter 'aliases' ([System.String]::Join(',', $shared.fullCmd.Parameters[$parameter.name].Aliases))

        [System.Void]$xmlParameter.AppendChild((_newMamlName $parameter.name))
        [System.Void]$xmlParameter.AppendChild((_newMamlDescription $parameter.description))

        if ($null -ne $parameter.parameterValue) {
            $xmlParameterValue = $shared.xmlDoc.CreateElement('command', 'parameterValue', $shared.cmdUri)
                _addAttribute $xmlParameterValue 'required' $parameter.parameterValue.required
                _addAttribute $xmlParameterValue 'variableLength' $xmlParameterVariableLength
                _addElement $xmlParameterValue (_newMamlTextType $parameter.parameterValue)
            [System.Void]$xmlParameter.AppendChild($xmlParameterValue)
        }

        #TODO: Figure out command:parameterValueGroup.

        if ($null -ne $parameter.type) {
            [System.Void]$xmlParameter.AppendChild((_newDevType $parameter.type))
        }

        if ($null -ne $parameter.defaultValue) {
            [System.Void]$xmlParameter.AppendChild((_newDevDefaultValue $parameter.defaultValue))
        }

        #TODO: Add optional dev:possibleValues.
        #TODO: Add optional command:validation.

    $xmlParameter
}

function _newCommandVerb
{
    [CmdletBinding()]
    Param($verb)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    #====================
    #PSMaml Note
    #developerCommand.xsd
    #====================
    #<element name="verb" type="maml:textType"/>

    $xmlVerb = $shared.xmlDoc.CreateElement('command', 'verb', $shared.cmdUri)

        if (-not [System.String]::IsNullOrEmpty($verb)) {
            _addElement $xmlVerb (_newMamlTextType $verb)
        }

    $xmlVerb
}

function _newDevCodeGroup
{
    [CmdletBinding()]
    Param($codeGroup)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    #=============
    #PSMaml Note
    #developer.xsd
    #=============
    #<group name="codeGroup">
    #  <choice>
    #    <element ref="dev:code"/>
    #    <element ref="dev:codeReference"/>
    #  </choice>
    #</group>
    #
    #<element name="code" type="dev:codeType">
    #  <annotation>
    #    <documentation>Describes a block of example code text.</documentation>
    #  </annotation>
    #</element>
    #
    #<complexType name="codeType" mixed="true">
    #  <simpleContent>
    #    <extension base="string">
    #      <attributeGroup ref="maml:contentIdentificationSharingAndConditionGroup"/>
    #      <attribute name="language" type="maml:devLanguagesType">
    #        <annotation>
    #          <documentation>Specifies the programming language used in a code example or some other programmatic structure.</documentation>
    #        </annotation>
    #      </attribute>
    #    </extension>
    #  </simpleContent>
    #</complexType>

    #TODO: Figure out dev:codeReference.

    $xmlCodeGroup = $shared.xmlDoc.CreateElement('dev', 'code', $shared.devUri)

        _addTextElement $xmlCodeGroup $codeGroup

    $xmlCodeGroup
}

function _newDevDefaultValue
{
    [CmdletBinding()]
    Param($defaultValue)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    #=============
    #PSMaml Note
    #developer.xsd
    #=============
    #<element name="defaultValue" type="maml:textType"/>

    $xmlDefaultValue = $shared.xmlDoc.CreateElement('dev', 'defaultValue', $shared.devUri)

        if (-not [System.String]::IsNullOrEmpty($defaultValue)) {
            _addElement $xmlDefaultValue (_newMamlTextType $defaultValue)
        }

    $xmlDefaultValue
}

function _newDevRemarks
{
    [CmdletBinding()]
    Param($remarks)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    #=============
    #PSMaml Note
    #developer.xsd
    #=============
    #<element name="remarks" type="maml:structureType">
    #  <annotation>
    #    <documentation>Contains a detailed discussion of the current item.</documentation>
    #    <appinfo>
    #      <doc:localizable>n/a</doc:localizable>
    #    </appinfo>
    #  </annotation>
    #</element>

    $xmlRemarks = $shared.xmlDoc.CreateElement('dev', 'remarks', $shared.devUri)

        if ($null -ne $remarks) {
            foreach ($item in $remarks) {
                _addElement $xmlRemarks (_newMamlPara $item)
            }
        }

        if (-not $xmlRemarks.HasChildNodes) {
            _addElement $xmlRemarks (_newMamlPara $null)
        }

    $xmlRemarks
}

function _newDevType
{
    [CmdletBinding()]
    Param($type)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    #=============
    #PSMaml Note
    #developer.xsd
    #=============
    #<element name="type" type="dev:typeType"/>
    #<complexType name="typeType">
    #  <sequence>
    #    <element ref="maml:name" minOccurs="0"/>
    #    <element ref="maml:uri"/>
    #    <element ref="maml:description" minOccurs="0"/>
    #  </sequence>
    #  <attributeGroup ref="maml:contentIdentificationSharingAndConditionGroup"/>
    #</complexType>

    $xmlType = $shared.xmlDoc.CreateElement('dev', 'type', $shared.devUri)

        if ($null -ne $type) {
            if ($null -ne $type.name) {
                [System.Void]$xmlType.AppendChild((_newMamlName $type.name))
            }

            [System.Void]$xmlType.AppendChild((_newMamlUri $type.uri))

            if ($null -ne $type.description) {
                [System.Void]$xmlType.AppendChild((_newMamlDescription $type.description))
            }
        }
        
        if (-not $xmlType.HasChildNodes) {
            [System.Void]$xmlType.AppendChild((_newMamlUri $type.uri))
        }

    $xmlType
}

function _newDevVersion
{
    [CmdletBinding()]
    Param($version)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    #=============
    #PSMaml Note
    #developer.xsd
    #=============
    #<element name="version" type="maml:textType"/>

    $xmlVersion = $shared.xmlDoc.CreateElement('dev', 'version', $shared.devUri)

        if (-not [System.String]::IsNullOrEmpty($version)) {
            _addElement $xmlVersion (_newMamlTextType $version)
        }

    $xmlVersion
}

function _newMamlAlert
{
    [CmdletBinding()]
    Param($alert)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    #=================
    #PSMaml Note
    #structureList.xsd
    #=================
    #<element name="alert">
    #  <annotation>
    #    <documentation>Specifies content of elevated importance or otherwise that needs to be called out. The alert element is a single-level alert structure.</documentation>
    #  </annotation>
    #  <complexType>
    #    <group ref="maml:structureGroup" maxOccurs="unbounded"/>
    #    <attributeGroup ref="maml:contentIdentificationSharingAndConditionGroup"/>
    #  </complexType>
    #</element>
    #

    #=============
    #PSMaml Note
    #structure.xsd
    #=============
    #<group name="structureGroup">
    #  <choice>
    #    <group ref="maml:blockGroup"/>
    #    <group ref="maml:structureListGroup"/>
    #    <element ref="maml:definitionList"/>
    #    <element ref="maml:table"/>
    #    <element ref="maml:procedure"/>
    #    <element ref="maml:example"/>
    #    <element ref="maml:sections"/>
    #  </choice>
    #</group>

    #TODO: Figure out maml:structureGroup.
    #      For now, just treate structureGroup as a collection of 'para' elements.

    $xmlAlert = $shared.xmlDoc.CreateElement('maml', 'alert', $shared.mamlUri)

        if ($null -ne $alert) {
            foreach ($item in $alert) {
                _addElement $xmlAlert (_newMamlPara $item)
            }
        }

        if (-not $xmlAlert.HasChildNodes) {
            _addElement $xmlAlert (_newMamlPara $null)
        }

    $xmlAlert
}

function _newMamlCopyright
{
    [CmdletBinding()]
    Param($copyright)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    #=============
    #PSMaml Note
    #hierarchy.xsd
    #=============
    #<element name="copyright">
    #  <annotation>
    #    <documentation>Describes copyright information for a document.</documentation>
    #  </annotation>
    #  <complexType>
    #    <sequence maxOccurs="unbounded">
    #      <element ref="maml:para"/>
    #    </sequence>
    #    <attributeGroup ref="maml:contentIdentificationSharingAndConditionGroup"/>
    #  </complexType>
    #</element>

    $xmlCopyright = $shared.xmlDoc.CreateElement('maml', 'copyright', $shared.mamlUri)

        if ($null -ne $copyright) {
            foreach ($item in $copyright) {
                _addElement $xmlCopyright (_newMamlPara $item)
            }
        }

        if (-not $xmlCopyright.HasChildNodes) {
            _addElement $xmlCopyright (_newMamlPara $null)
        }

    $xmlCopyright
}

function _newMamlDescription
{
    [CmdletBinding()]
    Param($description)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    #=============
    #PSMaml Note
    #structure.xsd
    #=============
    #<element name="description" type="maml:textBlockType"/>
    #<complexType name="textBlockType">
    #  <annotation>
    #    <documentation>Describes the schema for any block of text that can occur in an ACW panel.</documentation>
    #  </annotation>
    #  <choice maxOccurs="unbounded">
    #    <element ref="maml:para" minOccurs="0" maxOccurs="unbounded"/>
    #    <element ref="maml:list" minOccurs="0" maxOccurs="unbounded"/>
    #    <element ref="maml:table" minOccurs="0" maxOccurs="unbounded"/>
    #    <element ref="maml:example" minOccurs="0" maxOccurs="unbounded"/>
    #    <element ref="maml:alertSet" minOccurs="0" maxOccurs="unbounded"/>
    #    <element ref="maml:quote" minOccurs="0" maxOccurs="unbounded"/>
    #    <element ref="maml:definitionList" minOccurs="0" maxOccurs="unbounded"/>
    #  </choice>
    #</complexType>

    $xmlDescription = $shared.xmlDoc.CreateElement('maml', 'description', $shared.mamlUri)

        #TODO: Support all elements that can be inside maml:description.

        if ($null -ne $description) {
            foreach ($item in $description) {
                _addElement $xmlDescription (_newMamlPara $item)
            }
        }

        if (-not $xmlDescription.HasChildNodes) {
            _addElement $xmlDescription (_newMamlPara $null)
        }

    $xmlDescription
}

function _newMamlIntroduction
{
    [CmdletBinding()]
    Param($introduction)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    #=============
    #PSMaml Note
    #structure.xsd
    #=============
    #<element name="introduction" type="maml:structureType">
    #  <annotation>
    #    <documentation>Contains a summary, introduction, or short description of the current item. This text typically appears in a topic and may also be used as the description of the topic that appears in a jump table when the topic is being linked to.</documentation>
    #    <appinfo>
    #      <doc:localizable>n/a</doc:localizable>
    #    </appinfo>
    #  </annotation>
    #</element>
    #
    #<complexType name="structureType">
    #  <annotation>
    #    <documentation>Describes the common structure elements. It is intended for use in page types and structure elements.</documentation>
    #  </annotation>
    #  <group ref="maml:structureGroup" minOccurs="0" maxOccurs="unbounded"/>
    #  <attributeGroup ref="maml:contentIdentificationSharingAndConditionGroup"/>
    #</complexType>

    $xmlIntroduction = $shared.xmlDoc.CreateElement('maml', 'introduction', $shared.mamlUri)

        if ($null -ne $introduction) {
            foreach ($item in $introduction) {
                _addElement $xmlIntroduction (_newMamlPara $item)
            }
        }

        if (-not $xmlIntroduction.HasChildNodes) {
            _addElement $xmlIntroduction (_newMamlPara $null)
        }

    $xmlIntroduction
}

function _newMamlLinkText
{
    [CmdletBinding()]
    Param($linkText)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    #===========
    #PSMaml Note
    #inline.xsd
    #===========
    #<element name="linkText">
    #  <annotation>
    #    <documentation>Contains descriptive text for a link.</documentation>
    #  </annotation>
    #  <complexType mixed="true">
    #    <sequence minOccurs="0" maxOccurs="unbounded">
    #      <choice>
    #        <element ref="maml:notLocalizable"/>
    #        <element ref="maml:embedObject"/>
    #      </choice>
    #    </sequence>
    #  </complexType>
    #</element>

    #TODO: Figure out maml:notLocalizable and maml:embedObject.

    $xmlLinkText = $shared.xmlDoc.CreateElement('maml', 'linkText', $shared.mamlUri)

        if (-not [System.String]::IsNullOrEmpty($linkText)) {
            _addTextElement $xmlLinkText $linkText
        }

    $xmlLinkText
}

function _newMamlName
{
    [CmdletBinding()]
    Param($name)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    #=============
    #PSMaml Note
    #structure.xsd
    #=============
    #<element name="name" type="maml:nameType"/>
    #<complexType name="nameType" mixed="true">
    #  <complexContent>
    #    <extension base="maml:textType"/>
    #  </complexContent>
    #</complexType>

    $xmlName = $shared.xmlDoc.CreateElement('maml', 'name', $shared.mamlUri)
    
        if (-not [System.String]::IsNullOrEmpty($name)) {
            _addElement $xmlName (_newMamlTextType $name)
        }

    $xmlName
}

function _newMamlNavigationLink
{
    [CmdletBinding()]
    Param($navigationLink)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    #===========
    #PSMaml Note
    #inline.xsd
    #==========
    #<element name="navigationLink" type="maml:navigationLinkType"/>
    #
    #<complexType name="navigationLinkType">
    #  <annotation>
    #    <documentation>The navigationLink element is the navigational link in MAML, intended to produce a jump-type link in the help pane. Glossary links are navigation links.</documentation>
    #  </annotation>
    #  <sequence>
    #    <element ref="maml:linkText"/>
    #    <element ref="maml:uri"/>
    #  </sequence>
    #  <attribute name="targetVerification" type="boolean" default="false"/>
    #  <attributeGroup ref="maml:contentIdentificationSharingAndConditionGroup"/>
    #</complexType>

    $xmlNavigationLink = $shared.xmlDoc.CreateElement('maml', 'navigationLink', $shared.mamlUri)

        if ($null -ne $navigationLink) {
            [System.Void]$xmlNavigationLink.AppendChild((_newMamlLinkText $navigationLink.linkText))
            [System.Void]$xmlNavigationLink.AppendChild((_newMamlUri $navigationLink.uri))
        } else {
            [System.Void]$xmlNavigationLink.AppendChild((_newMamlLinkText $null))
            [System.Void]$xmlNavigationLink.AppendChild((_newMamlUri $null))
        }

    $xmlNavigationLink
}

function _newMamlPara
{
    [CmdletBinding()]
    Param($para)

    #===============
    #PSMaml Note
    #blockCommon.xsd
    #===============
    #<element name="para">
    #  <annotation>
    #    <documentation>Describes a paragraph, the most basic documentation unit. In addition to text, it can contain child elements to indicate various inline text types, or to add functionality such as a task or a shortcut.</documentation>
    #  </annotation>
    #  <complexType mixed="true">
    #    <sequence>
    #      <element ref="maml:leadInPhrase" minOccurs="0"/>
    #      <group ref="maml:inlineGroup" minOccurs="0" maxOccurs="unbounded"/>
    #    </sequence>
    #    <attributeGroup ref="maml:contentIdentificationSharingAndConditionGroup"/>
    #  </complexType>
    #</element>

    $xmlPara = $shared.xmlDoc.CreateElement('maml', 'para', $shared.mamlUri)

        #TODO: Figure out maml:leadInPhrase and maml:inlineGroup.

        if ($null -ne $para) {
            _addTextElement $xmlPara $para.Text
        }

    $xmlPara
}

function _newMamlTextType
{
    [CmdletBinding()]
    Param($text)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    #===========
    #PSMaml Note
    #base.xsd
    #===========
    #<complexType name="textType" mixed="true">
    #  <annotation>
    #    <documentation>Includes the common attributes, allows character data and the notLocalizable element.</documentation>
    #  </annotation>
    #  <sequence minOccurs="0" maxOccurs="unbounded">
    #    <choice>
    #      <element ref="maml:notLocalizable"/>
    #    </choice>
    #  </sequence>
    #  <attributeGroup ref="maml:contentIdentificationSharingAndConditionGroup"/>
    #</complexType>
    #
    #<element name="notLocalizable" type="maml:inlineType">
    #  <annotation>
    #    <documentation>Identifies a span of text that should not be localized.</documentation>
    #  </annotation>
    #</element>

    #TODO: Figure out maml:notLocalizable and maml:inlineType.

    $shared.xmlDoc.CreateTextNode($text)
}

function _newMamlTitle
{
    [CmdletBinding()]
    Param($title)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    #===============
    #PSMaml Note
    #blockCommon.xsd
    #===============
    #<element name="title" type="maml:titleType">
    #  <annotation>
    #    <documentation>Specifies the title of a document, or part of a document.</documentation>
    #  </annotation>
    #</element>
    #
    #<complexType name="titleType" mixed="true">
    #  <sequence minOccurs="0" maxOccurs="unbounded">
    #    <choice>
    #      <element ref="maml:conditionalInline"/>
    #      <element ref="maml:acronym"/>
    #      <element ref="maml:notLocalizable"/>
    #    </choice>
    #  </sequence>
    #  <attributeGroup ref="maml:contentIdentificationSharingAndConditionGroup"/>
    #</complexType>

    #TODO: Figure out maml:conditionalInline, maml:acronym, and maml:notLocalizable.

    $xmlTitle = $shared.xmlDoc.CreateElement('maml', 'title', $shared.mamlUri)

        if (-not [System.String]::IsNullOrEmpty($title)) {
            _addTextElement $xmlTitle $title
        }

    $xmlTitle
}

function _newMamlUri
{
    [CmdletBinding()]
    Param($uri)

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    #===========
    #PSMaml Note
    #base.xsd
    #===========
    #<element name="uri" type="maml:textType">
    #  <annotation>
    #    <documentation>Specifies the URI for a navigation link.</documentation>
    #  </annotation>
    #</element>

    $xmlUri = $shared.xmlDoc.CreateElement('maml', 'uri', $shared.mamlUri)
    
        if (-not [System.String]::IsNullOrEmpty($uri)) {
            _addElement $xmlUri (_newMamlTextType $uri)
        }

    $xmlUri
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

    $shared.fullCmd = $null
    $shared.fullHelp = $null
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

    $shared.fullCmd = Get-Command $CommandName
    $shared.fullHelp = Get-Help $CommandName -Full

    #region command
    <#
    #====================
    #PSMaml Note
    #developerCommand.xsd
    #====================
    #<complexType name="commandType">
    #  <sequence>
    #    <element ref="command:details"/>
    #    <element ref="maml:description"/>
    #    <element ref="command:syntax"/>
    #    <element ref="command:parameters" minOccurs="0"/>
    #    <element ref="command:inputTypes"/>
    #    <element ref="command:returnValues"/>
    #    <element ref="command:terminatingErrors"/>
    #    <element ref="command:nonTerminatingErrors"/>
    #    <element ref="maml:alertSet" minOccurs="0" maxOccurs="unbounded"/>
    #    <element ref="command:examples" minOccurs="0"/>
    #    <element ref="maml:relatedLinks" maxOccurs="unbounded"/>
    #  </sequence>
    #  <attribute name="contentType" type="token"/>
    #</complexType>
    #>

    $cmd = $shared.xmlDoc.CreateElement('command', 'command', $shared.cmdUri)

        _addAttribute $cmd 'xmlns:maml' $shared.mamlUri
        _addAttribute $cmd 'xmlns:command' $shared.cmdUri
        _addAttribute $cmd 'xmlns:dev' $shared.devUri
        _addAttribute $cmd 'xmlns:MSHelp' $shared.helpUri

        #region details
        <#
        #====================
        #PSMaml Note
        #developerCommand.xsd
        #====================
        #<element name="details" type="command:detailsType"/>
        #<complexType name="detailsType">
        #  <sequence>
        #    <element ref="command:name"/>
        #    <element ref="maml:description"/>
        #    <element ref="command:synonyms" minOccurs="0"/>
        #    <element ref="maml:copyright"/>
        #    <element ref="command:verb"/>
        #    <element ref="command:noun"/>
        #    <element ref="dev:version"/>
        #    <element ref="command:vendor" minOccurs="0"/>
        #  </sequence>
        #  <attributeGroup ref="maml:contentIdentificationSharingAndConditionGroup"/>
        #</complexType>
        #>

        $cmdDetails = $shared.xmlDoc.CreateElement('command', 'details', $shared.cmdUri)

            [System.Void]$cmdDetails.AppendChild((_newCommandName $shared.fullCmd.Name))
            [System.Void]$cmdDetails.AppendChild((_newMamlDescription $(if ($null -ne $shared.fullHelp.details) {,$shared.fullHelp.details.description} else {,@()})))

            #TODO: Add optional command:synonyms.

            [System.Void]$cmdDetails.AppendChild((_newMamlCopyright  $(if ($null -ne $shared.fullHelp.details) {,$shared.fullHelp.details.copyright} else {,@()})))
            [System.Void]$cmdDetails.AppendChild((_newCommandVerb $shared.fullCmd.Verb))
            [System.Void]$cmdDetails.AppendChild((_newCommandNoun $shared.fullCmd.Noun))
            [System.Void]$cmdDetails.AppendChild((_newDevVersion $(if ($null -ne $shared.fullHelp.details) {$shared.fullHelp.details.version} else {''})))

            #TODO: Add optional command:vendor.

        [System.Void]$cmd.AppendChild($cmdDetails)
        #endregion details

        #region description
        [System.Void]$cmd.AppendChild((_newMamlDescription $shared.fullHelp.description))
        #endregion description

        #region syntax
        <#
        #====================
        #PSMaml Note
        #developerCommand.xsd
        #====================
        #<element name="syntax" type="command:syntaxType"/>
        #<complexType name="syntaxType">
        #  <sequence>
        #    <element ref="command:syntaxItem" maxOccurs="unbounded"/>
        #  </sequence>
        #  <attributeGroup ref="maml:contentIdentificationSharingAndConditionGroup"/>
        #</complexType>
        #
        #<element name="syntaxItem" type="command:syntaxItemType"/>
        #<complexType name="syntaxItemType">
        #  <sequence>
        #    <element ref="maml:name"/>
        #    <element ref="command:parameter" minOccurs="0" maxOccurs="unbounded"/>
        #    <element ref="command:parameterGroup" minOccurs="0" maxOccurs="unbounded"/>
        #  </sequence>
        #  <attributeGroup ref="maml:contentIdentificationSharingAndConditionGroup"/>
        #</complexType>
        #>

        $cmdSyntax = $shared.xmlDoc.CreateElement('command', 'syntax', $shared.cmdUri)

            if (($null -ne $shared.fullHelp.syntax) -and ($null -ne $shared.fullHelp.syntax.syntaxItem) -and (0 -lt @($shared.fullHelp.syntax.syntaxItem).Count)) {
                foreach ($syntaxItem in $shared.fullHelp.syntax.syntaxItem) {
                    $cmdSyntaxItem = $shared.xmlDoc.CreateElement('command', 'syntaxItem', $shared.cmdUri)

                        [System.Void]$cmdSyntaxItem.AppendChild((_newMamlName $syntaxItem.name))

                        if (($null -ne $syntaxItem.parameter) -and (0 -lt @($syntaxItem.parameter).Count)) {
                            foreach ($syntaxItemParameter in $syntaxItem.parameter) {
                                [System.Void]$cmdSyntaxItem.AppendChild((_newCommandParameter $syntaxItemParameter))
                            }
                        }

                        #TODO: Add optional command:parameterGroup.

                    [System.Void]$cmdSyntax.AppendChild($cmdSyntaxItem)
                }
            } else {
                $cmdSyntaxItem = $shared.xmlDoc.CreateElement('command', 'syntaxItem', $shared.cmdUri)
                    [System.Void]$cmdSyntaxItem.AppendChild((_newMamlName $null))
                [System.Void]$cmdSyntax.AppendChild($cmdSyntaxItem)
            }

        [System.Void]$cmd.AppendChild($cmdSyntax)
        #endregion syntax

        #region parameters
        <#
        #====================
        #PSMaml Note
        #developerCommand.xsd
        #====================
        #<element name="parameters" type="command:parametersType"/>
        #<complexType name="parametersType">
        #  <sequence>
        #    <element ref="command:parameter" minOccurs="1" maxOccurs="unbounded"/>
        #  </sequence>
        #  <attributeGroup ref="maml:contentIdentificationSharingAndConditionGroup"/>
        #</complexType>
        #>

        if (($null -ne $shared.fullHelp.parameters) -and ($null -ne $shared.fullHelp.parameters.parameter) -and (0 -lt @($shared.fullHelp.parameters.parameter).Count)) {
            $cmdParameters = $shared.xmlDoc.CreateElement('command', 'parameters', $shared.cmdUri)

                foreach ($parameter in $shared.fullHelp.parameters.parameter) {
                    [System.Void]$cmdParameters.AppendChild((_newCommandParameter $parameter))
                }

            [System.Void]$cmd.AppendChild($cmdParameters)
        }
        #endregion parameters

        #region inputTypes
        <#
        #====================
        #PSMaml Note
        #developerCommand.xsd
        #====================
        #<element name="inputTypes" type="command:inputTypesType"/>
        #<complexType name="inputTypesType">
        #  <sequence>
        #    <element ref="command:inputType" maxOccurs="unbounded"/>
        #  </sequence>
        #  <attributeGroup ref="maml:contentIdentificationSharingAndConditionGroup"/>
        #</complexType>
        #
        #<element name="inputType" type="command:inputTypeType"/>
        #<complexType name="inputTypeType">
        #  <sequence>
        #    <element ref="dev:type"/>
        #    <element ref="maml:description"/>
        #  </sequence>
        #  <attribute ref="command:requiresTrustedData" use="optional"/>
        #</complexType>
        #>

        $cmdInputs = $shared.xmlDoc.CreateElement('command', 'inputTypes', $shared.cmdUri)

            if (($null -ne $shared.fullHelp.inputTypes) -and ($null -ne $shared.fullHelp.inputTypes.inputType) -and (0 -lt @($shared.fullHelp.inputTypes.inputType).Count)) {
                foreach ($inputType in $shared.fullHelp.inputTypes.inputType) {
                    $cmdInput = $shared.xmlDoc.CreateElement('command', 'inputType', $shared.cmdUri)

                        [System.Void]$cmdInput.AppendChild((_newDevType $inputType.type))
                        [System.Void]$cmdInput.AppendChild((_newMamlDescription $inputType.description))

                    [System.Void]$cmdInputs.AppendChild($cmdInput)
                }
            } else {
                $cmdInput = $shared.xmlDoc.CreateElement('command', 'inputType', $shared.cmdUri)

                    [System.Void]$cmdInput.AppendChild((_newDevType $null))
                    [System.Void]$cmdInput.AppendChild((_newMamlDescription $null))

                [System.Void]$cmdInputs.AppendChild($cmdInput)
            }

        [System.Void]$cmd.AppendChild($cmdInputs)
        #endregion inputTypes

        #region returnValues
        <#
        #====================
        #PSMaml Note
        #developerCommand.xsd
        #====================
        #<element name="returnValues" type="command:returnValuesType"/>
        #<complexType name="returnValuesType">
        #  <sequence>
        #    <element ref="command:returnValue" maxOccurs="unbounded"/>
        #  </sequence>
        #</complexType>
        #
        #<element name="returnValue" type="command:returnValueType"/>
        #<complexType name="returnValueType">
        #  <complexContent>
        #    <extension base="dev:returnValueType">
        #      <attribute ref="command:isTrustedData" use="optional"/>
        #    </extension>
        #  </complexContent>
        #</complexType>
        #>
        <#
        #=============
        #PSMaml Note
        #developer.xsd
        #=============
        #<complexType name="returnValueType">
        #  <sequence minOccurs="0">
        #    <group ref="dev:parameterRetvalBaseGroup"/>
        #  </sequence>
        #</complexType>
        #
        #<group name="parameterRetvalBaseGroup">
        #  <sequence>
        #    <element ref="dev:type"/>
        #    <element ref="maml:description"/>
        #    <element ref="dev:possibleValues" minOccurs="0"/>
        #  </sequence>
        #</group>
        #>

        $cmdOutputs = $shared.xmlDoc.CreateElement('command', 'returnValues', $shared.cmdUri)

            if (($null -ne $shared.fullHelp.returnValues) -and ($null -ne $shared.fullHelp.returnValues.returnValue) -and (0 -lt @($shared.fullHelp.returnValues.returnValue).Count)) {
                foreach ($outputType in $shared.fullHelp.returnValues.returnValue) {
                    $cmdOutput = $shared.xmlDoc.CreateElement('command', 'returnValue', $shared.cmdUri)

                        [System.Void]$cmdOutput.AppendChild((_newDevType $outputType.type))
                        [System.Void]$cmdOutput.AppendChild((_newMamlDescription $outputType.description))

                        #TODO: Add optional dev:possibleValues.

                    [System.Void]$cmdOutputs.AppendChild($cmdOutput)
                }
            } else {
                $cmdOutput = $shared.xmlDoc.CreateElement('command', 'returnValue', $shared.cmdUri)
                [System.Void]$cmdOutputs.AppendChild($cmdOutput)
            }

        [System.Void]$cmd.AppendChild($cmdOutputs)
        #endregion returnValues

        #region terminatingErrors
        $cmdTerminatingErrors = $shared.xmlDoc.CreateElement('command', 'terminatingErrors', $shared.cmdUri)

            #TODO: Add code to generate error types.

        [System.Void]$cmd.AppendChild($cmdTerminatingErrors)
        #endregion terminatingErrors

        #region nonTerminatingErrors
        $cmdNonTerminatingErrors = $shared.xmlDoc.CreateElement('command', 'nonTerminatingErrors', $shared.cmdUri)
        [System.Void]$cmd.AppendChild($cmdNonTerminatingErrors)

            #TODO: Add code to generate error types.

        #endregion nonTerminatingErrors

        #region alertSet
        <#
        #=================
        #PSMaml Note
        #structureList.xsd
        #=================
        #<element name="alertSet">
        #  <annotation>
        #    <documentation>Contains a collection of alert elements. An alertSet element can have one or more alert elements as children. Use the alertSet element for more than one alert item of the same type. For example, if a topic had three items for the notes section, an alertSet could be used to combine them.</documentation>
        #  </annotation>
        #  <complexType>
        #    <sequence>
        #      <element ref="maml:title" minOccurs="0"/>
        #      <element ref="maml:alert" maxOccurs="unbounded"/>
        #    </sequence>
        #    <attribute name="class" type="maml:alertTypesEnumType" default="note">
        #      <annotation>
        #        <documentation>Specifies the type of alert.</documentation>
        #      </annotation>
        #    </attribute>
        #    <attributeGroup ref="maml:expandCollapseGroup"/>
        #    <attributeGroup ref="maml:contentIdentificationSharingAndConditionGroup"/>
        #  </complexType>
        #</element>
        #>

        if (($null -ne $shared.fullHelp.alertSet) -and (0 -lt @($shared.fullHelp.alertSet).Count)) {
                foreach ($alertSet in $shared.fullHelp.alertSet) {
                    $cmdNotes = $shared.xmlDoc.CreateElement('maml', 'alertSet', $shared.mamlUri)

                        if ($null -ne $alertSet.title) {
                            [System.Void]$cmdNotes.AppendChild((_newMamlTitle $alertSet.title))
                        }

                        if (($null -ne $alertSet.alert) -and (0 -lt @($alertSet.alert).Count)) {
                            foreach ($alert in $alertSet.alert) {
                                [System.Void]$cmdNotes.AppendChild((_newMamlAlert $alert))
                            }
                        } else {
                            [System.Void]$cmdNotes.AppendChild((_newMamlAlert $null))
                        }

                    [System.Void]$cmd.AppendChild($cmdNotes)
                }
        }
        #endregion alertSet

        #region examples
        <#
        #====================
        #PSMaml Note
        #developerCommand.xsd
        #====================
        #<element name="examples" type="command:examplesType"/>
        #<complexType name="examplesType">
        #  <sequence>
        #    <element ref="command:example" maxOccurs="unbounded"/>
        #  </sequence>
        #  <attributeGroup ref="maml:contentIdentificationSharingAndConditionGroup"/>
        #</complexType>
        #
        #<element name="example" type="command:exampleType"/>
        #<complexType name="exampleType">
        #  <complexContent>
        #    <extension base="command:exampleTypeRestricted">
        #      <sequence>
        #        <element ref="command:commandLines" minOccurs="0"/>
        #      </sequence>
        #    </extension>
        #  </complexContent>
        #</complexType>
        #
        #<complexType name="exampleTypeRestricted">
        #  <complexContent>
        #    <restriction base="dev:exampleType">
        #      <sequence>
        #        <element ref="maml:title" minOccurs="0"/>
        #        <element ref="maml:introduction" minOccurs="0"/>
        #        <group ref="dev:codeGroup"/>
        #        <element ref="dev:buildInstructions" minOccurs="0" maxOccurs="0"/>
        #        <element ref="dev:robustProgramming" minOccurs="0" maxOccurs="0"/>
        #        <element ref="dev:security" minOccurs="0"/>
        #        <element ref="dev:results" minOccurs="0" maxOccurs="0"/>
        #        <element ref="dev:remarks" minOccurs="0"/>
        #      </sequence>
        #    </restriction>
        #  </complexContent>
        #</complexType>
        #>

        if (($null -ne $shared.fullHelp.examples) -and ($null -ne $shared.fullHelp.examples.example) -and (0 -lt @($shared.fullHelp.examples.example).Count)) {
            $cmdExamples = $shared.xmlDoc.CreateElement('command', 'examples', $shared.cmdUri)

                foreach ($example in $shared.fullHelp.examples.example) {
                    $cmdExample = $shared.xmlDoc.CreateElement('command', 'example', $shared.cmdUri)

                        if ($null -ne $example.title) {
                            [System.Void]$cmdExample.AppendChild((_newMamlTitle $example.title))
                        }

                        if ($null -ne $example.introduction) {
                            [System.Void]$cmdExample.AppendChild((_newMamlIntroduction $example.introduction))
                        }

                        [System.Void]$cmdExample.AppendChild((_newDevCodeGroup $example.code))

                        #TODO: Add optional dev:security.

                        if ($null -ne $example.remarks) {
                            [System.Void]$cmdExample.AppendChild((_newDevRemarks $example.remarks))
                        }

                        #TODO: Add optional command:commandLines.

                    [System.Void]$cmdExamples.AppendChild($cmdExample)
                }

            [System.Void]$cmd.AppendChild($cmdExamples)
        }
        #endregion examples

        #region relatedLinks
        <#
        #=============
        #PSMaml Note
        #hierarchy.xsd
        #=============
        #<element name="relatedLinks" type="maml:relatedLinksType">
        #  <annotation>
        #    <documentation>Describes a collection of links, typically used for the "Related Topics" section of a document. The purpose of this element is to provide links to topics that may be of further interest to the user.</documentation>
        #    <appinfo>
        #      <doc:localizable>n/a</doc:localizable>
        #    </appinfo>
        #  </annotation>
        #</element>
        #
        #<complexType name="relatedLinksType">
        #  <sequence>
        #    <element ref="maml:title" minOccurs="0"/>
        #    <element ref="maml:navigationLink" maxOccurs="unbounded"/>
        #  </sequence>
        #  <attributeGroup ref="maml:contentIdentificationSharingAndConditionGroup"/>
        #  <attribute name="type" use="optional" default="seeAlso" type="maml:relatedLinksTypeType"/>
        #</complexType>
        #>

        $cmdRelatedLinks = $shared.xmlDoc.CreateElement('maml', 'relatedLinks', $shared.mamlUri)

            if (($null -ne $shared.fullHelp.relatedLinks) -and ($null -ne $shared.fullHelp.relatedLinks.title)) {
                [System.Void]$cmdRelatedLinks.AppendChild((_newMamlTitle $shared.fullHelp.relatedLinks.title))
            }

            if (($null -ne $shared.fullHelp.relatedLinks) -and ($null -ne $shared.fullHelp.relatedLinks.navigationLink) -and (0 -lt @($shared.fullHelp.relatedLinks.navigationLink).Count)) {
                foreach ($navigationLink in $shared.fullHelp.relatedLinks.navigationLink) {
                    [System.Void]$cmdRelatedLinks.AppendChild((_newMamlNavigationLink $navigationLink))
                }
            } else {
                [System.Void]$cmdRelatedLinks.AppendChild((_newMamlNavigationLink $null))
            }

        [System.Void]$cmd.AppendChild($cmdRelatedLinks)
        #endregion relatedLinks

    [System.Void]$shared.xmlRoot.AppendChild($cmd)
    #endregion command

    $shared.fullCmd = $null
    $shared.fullHelp = $null
}


Clear-MamlHelp

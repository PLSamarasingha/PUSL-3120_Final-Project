param(
    [string]$InputPath = "Final_Research_Report.md",
    [string]$OutputPath = "Final_Research_Report.docx"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Escape-Xml {
    param([string]$Text)

    if ($null -eq $Text) {
        return ""
    }

    return [System.Security.SecurityElement]::Escape($Text)
}

function Convert-MarkdownLine {
    param([string]$Line)

    if ($Line -match '^\s*$') {
        return @{
            Type = "Blank"
            Text = ""
        }
    }

    if ($Line -match '^---+$') {
        return @{
            Type = "Blank"
            Text = ""
        }
    }

    if ($Line -match '^(#{1,6})\s+(.*)$') {
        return @{
            Type = "Heading"
            Level = $matches[1].Length
            Text = $matches[2]
        }
    }

    if ($Line -match '^\d+\.\s+(.*)$') {
        return @{
            Type = "Numbered"
            Text = $matches[1]
        }
    }

    if ($Line -match '^\-\s+(.*)$') {
        return @{
            Type = "Bullet"
            Text = $matches[1]
        }
    }

    return @{
        Type = "Paragraph"
        Text = $Line
    }
}

function New-ParagraphXml {
    param(
        [string]$Text,
        [string]$Style = "Normal",
        [int]$IndentTwips = 0
    )

    $escapedText = Escape-Xml $Text
    $indentXml = ""
    if ($IndentTwips -gt 0) {
        $indentXml = "<w:ind w:left=`"$IndentTwips`"/>"
    }

    return @"
<w:p>
  <w:pPr>
    <w:pStyle w:val="$Style"/>
    $indentXml
  </w:pPr>
  <w:r>
    <w:t xml:space="preserve">$escapedText</w:t>
  </w:r>
</w:p>
"@
}

$inputFullPath = Join-Path (Get-Location) $InputPath
$outputFullPath = Join-Path (Get-Location) $OutputPath
$tempRoot = Join-Path $env:TEMP ("reportdocx_" + [guid]::NewGuid().ToString("N"))
$wordDir = Join-Path $tempRoot "word"
$relsDir = Join-Path $tempRoot "_rels"
$wordRelsDir = Join-Path $wordDir "_rels"

New-Item -ItemType Directory -Force -Path $tempRoot, $wordDir, $relsDir, $wordRelsDir | Out-Null

$lines = Get-Content -LiteralPath $inputFullPath
$paragraphs = New-Object System.Collections.Generic.List[string]
$inCodeBlock = $false

foreach ($line in $lines) {
    if ($line -match '^```') {
        $inCodeBlock = -not $inCodeBlock
        if ($inCodeBlock) {
            $paragraphs.Add((New-ParagraphXml -Text "[Code/diagram block omitted in Word export]" -Style "Italic"))
        }
        continue
    }

    if ($inCodeBlock) {
        continue
    }

    $entry = Convert-MarkdownLine -Line $line
    switch ($entry.Type) {
        "Blank" {
            $paragraphs.Add("<w:p/>")
        }
        "Heading" {
            $style = switch ($entry.Level) {
                1 { "Heading1" }
                2 { "Heading2" }
                3 { "Heading3" }
                Default { "Heading4" }
            }
            $paragraphs.Add((New-ParagraphXml -Text $entry.Text -Style $style))
        }
        "Numbered" {
            $paragraphs.Add((New-ParagraphXml -Text ("1. " + $entry.Text) -Style "Normal" -IndentTwips 360))
        }
        "Bullet" {
            $paragraphs.Add((New-ParagraphXml -Text ([char]0x2022 + " " + $entry.Text) -Style "Normal" -IndentTwips 360))
        }
        Default {
            $paragraphs.Add((New-ParagraphXml -Text $entry.Text -Style "Normal"))
        }
    }
}

$documentXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
    xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
    xmlns:o="urn:schemas-microsoft-com:office:office"
    xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
    xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
    xmlns:v="urn:schemas-microsoft-com:vml"
    xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"
    xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
    xmlns:w10="urn:schemas-microsoft-com:office:word"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
    xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"
    xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk"
    xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
    xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"
    mc:Ignorable="w14 wp14">
  <w:body>
    $($paragraphs -join "`n")
    <w:sectPr>
      <w:pgSz w:w="12240" w:h="15840"/>
      <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="708" w:footer="708" w:gutter="0"/>
      <w:cols w:space="708"/>
      <w:docGrid w:linePitch="360"/>
    </w:sectPr>
  </w:body>
</w:document>
"@

$stylesXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal">
    <w:name w:val="Normal"/>
    <w:qFormat/>
    <w:rPr>
      <w:sz w:val="24"/>
      <w:szCs w:val="24"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading1">
    <w:name w:val="heading 1"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:uiPriority w:val="9"/>
    <w:qFormat/>
    <w:rPr>
      <w:b/>
      <w:sz w:val="32"/>
      <w:szCs w:val="32"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading2">
    <w:name w:val="heading 2"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:uiPriority w:val="9"/>
    <w:qFormat/>
    <w:rPr>
      <w:b/>
      <w:sz w:val="28"/>
      <w:szCs w:val="28"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading3">
    <w:name w:val="heading 3"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:uiPriority w:val="9"/>
    <w:qFormat/>
    <w:rPr>
      <w:b/>
      <w:sz w:val="26"/>
      <w:szCs w:val="26"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading4">
    <w:name w:val="heading 4"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:uiPriority w:val="9"/>
    <w:qFormat/>
    <w:rPr>
      <w:b/>
      <w:sz w:val="24"/>
      <w:szCs w:val="24"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Italic">
    <w:name w:val="Italic"/>
    <w:basedOn w:val="Normal"/>
    <w:rPr>
      <w:i/>
      <w:sz w:val="22"/>
      <w:szCs w:val="22"/>
    </w:rPr>
  </w:style>
</w:styles>
"@

$contentTypesXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
</Types>
"@

$rootRelsXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>
"@

$documentRelsXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>
"@

Set-Content -LiteralPath (Join-Path $tempRoot "[Content_Types].xml") -Value $contentTypesXml -Encoding UTF8
Set-Content -LiteralPath (Join-Path $relsDir ".rels") -Value $rootRelsXml -Encoding UTF8
Set-Content -LiteralPath (Join-Path $wordDir "document.xml") -Value $documentXml -Encoding UTF8
Set-Content -LiteralPath (Join-Path $wordDir "styles.xml") -Value $stylesXml -Encoding UTF8
Set-Content -LiteralPath (Join-Path $wordRelsDir "document.xml.rels") -Value $documentRelsXml -Encoding UTF8

$zipPath = [System.IO.Path]::ChangeExtension($outputFullPath, ".zip")

if (Test-Path -LiteralPath $outputFullPath) {
    Remove-Item -LiteralPath $outputFullPath -Force
}
if (Test-Path -LiteralPath $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
}

Compress-Archive -Path (Join-Path $tempRoot "*") -DestinationPath $zipPath
Rename-Item -LiteralPath $zipPath -NewName ([System.IO.Path]::GetFileName($outputFullPath))

Remove-Item -LiteralPath $tempRoot -Recurse -Force
Write-Output "Created $outputFullPath"

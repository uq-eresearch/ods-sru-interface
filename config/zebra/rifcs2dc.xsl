<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:rif="http://ands.org.au/standards/rif-cs/registryObjects"
  exclude-result-prefixes="rif"
  version="1.0">

  <xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>

  <!-- disable all default text node output -->
  <xsl:template match="text()"/>

  <!-- match on oai xml record -->
  <xsl:template match="/">
    <dc:metadata>
       <xsl:apply-templates/>
    </dc:metadata>
  </xsl:template>

  <!--
  <xsl:template match="oai:record/oai:metadata/oai_dc:dc/node()">
      <xsl:copy-of select="."/>
  </xsl:template>
  -->

  <xsl:template match="//rif:registryObject/*[last()]">
      <dc:type><xsl:value-of select="@type"/></dc:type>
      <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="@dateModified">
      <dc:date><xsl:value-of select="."/></dc:date>
  </xsl:template>

  <xsl:template match="rif:description">
      <dc:description><xsl:value-of select="."/></dc:description>
  </xsl:template>

  <xsl:template match="rif:identifier">
      <dc:identifier><xsl:value-of select="."/></dc:identifier>
  </xsl:template>

  <xsl:template match="rif:relatedObject/rif:key">
      <dc:relation><xsl:value-of select="."/></dc:relation>
  </xsl:template>

  <xsl:template match="rif:name/rif:namePart">
      <dc:title><xsl:value-of select="."/></dc:title>
  </xsl:template>

</xsl:stylesheet>

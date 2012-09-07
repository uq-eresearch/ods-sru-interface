<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:z="http://indexdata.com/zebra-2.0"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:rif="http://ands.org.au/standards/rif-cs/registryObjects"
                exclude-result-prefixes="rif dc"
                version="1.0">

  <!-- xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" -->


  <xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>

  <!-- disable all default text node output -->
  <xsl:template match="text()"/>

  <!-- match on rifcs xml record -->
  <xsl:template match="/">
    <z:record z:id="{normalize-space(//rif:registryObject/rif:key)}">
      <xsl:apply-templates/>
    </z:record>
  </xsl:template>

  <xsl:template match="rif:registryObject">
     <xsl:apply-templates/>
  </xsl:template>

  <!-- indexing templates -->
  <xsl:template match="//rif:identifier">
    <z:index name="identifier:0">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="@dateModified">
    <z:index name="datestamp:0">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="rif:name/rif:namePart">
    <z:index name="any:w title:w title:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <!--
  <xsl:template match="rif:name/rif:namePart">
    <z:index name="any:w author:w author:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="oai:record/oai:metadata/oai_dc:dc/dc:subject
                    | oai:record/oai:metadata/oai_dc:dc/oai_dc:subject">
    <z:index name="any:w subject-heading:w subject-heading:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="oai:record/oai:metadata/oai_dc:dc/dc:description
                    | oai:record/oai:metadata/oai_dc:dc/oai_dc:description">
    <z:index name="any:w description:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="oai:record/oai:metadata/oai_dc:dc/dc:contributor
                    | oai:record/oai:metadata/oai_dc:dc/oai_dc:contributor">
    <z:index name="any:w contributor:w contributor:p">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="oai:record/oai:metadata/oai_dc:dc/dc:publisher
                    | oai:record/oai:metadata/oai_dc:dc/oai_dc:publisher">
    <z:index name="publisher:p publisher:w">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  <xsl:template match="oai:record/oai:metadata/oai_dc:dc/dc:relation
                    | oai:record/oai:metadata/oai_dc:dc/oai_dc:relation">
    <z:index name="relation:0">
      <xsl:value-of select="."/>
    </z:index>
  </xsl:template>

  -->

</xsl:stylesheet>

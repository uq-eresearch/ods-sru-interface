<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:z="http://indexdata.com/zebra-2.0"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:rif="http://ands.org.au/standards/rif-cs/registryObjects"
                exclude-result-prefixes="rif"
                version="1.0">


  <xsl:param name="id" select="''"/>
  <xsl:param name="filename" select="''"/>
  <xsl:param name="rank" select="''"/>
  <xsl:param name="score" select="''"/>
  <xsl:param name="schema" select="''"/>
  <xsl:param name="size" select="''"/>

<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>

 <xsl:template match="/">
   <z:record
       z:id="{//rif:registryObject/rif:key/text()}"
       z:filename="{$filename}"
       z:rank="{$rank}"
       z:score="{$score}"
       z:schema="{$schema}"
       z:size="{$size}"
       >
     <!--
     <title>
       <xsl:value-of select="oai:record/oai:metadata/oai_dc:dc/dc:title"/>
     </title>
     -->
   </z:record>

 </xsl:template>

</xsl:stylesheet>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:rif="http://ands.org.au/standards/rif-cs/registryObjects"
  exclude-result-prefixes="rif"
  version="1.0">

  <xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>

  <!-- disable all default text node output -->
  <xsl:template match="text()"/>

  <!-- match on oai xml record -->
  <xsl:template match="/">
    <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects">
      <xsl:copy-of select="."/>
    </registryObjects>
  </xsl:template>

</xsl:stylesheet>

<?xml version="1.0" encoding='UTF-8'?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="text"/>

<xsl:template match="option">
  <xsl:value-of select="text()"/>
  <xsl:text>&#10;</xsl:text>
</xsl:template>

<xsl:template match="@*|node()">
  <xsl:apply-templates select="@*|node()"/>
  <!-- <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy> -->
</xsl:template>

</xsl:stylesheet>

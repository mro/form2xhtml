<?xml version="1.0" encoding="UTF-8"?>
<!--
 https://mro.name/form2xhtml

 http://www.w3.org/TR/xslt/
-->
<xsl:stylesheet
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:a="http://www.w3.org/2005/Atom"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

  <xsl:output method="xml" indent="yes" encoding="utf-8"/>

  <xsl:template match="/form">
    <a:entry>
      <xsl:apply-templates select="textarea|input"/>
    </a:entry>
  </xsl:template>

  <xsl:template match="textarea">
    <xsl:element name="{@name}">
      <xsl:copy-of select="./text()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="input[@type='file']">
    <a:link rel="{@name}" href="{@value}"/>
  </xsl:template>
</xsl:stylesheet>

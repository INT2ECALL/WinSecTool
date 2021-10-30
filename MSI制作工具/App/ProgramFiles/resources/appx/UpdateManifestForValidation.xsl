<?xml version="1.0" encoding="utf-8" ?>

<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- The caller of this transform must set this parameter to the list of
       namespaces (delimited by square brackets with no extra whitespace) that are valid. -->
  <xsl:param name="validNamespaces"/>

  <xsl:output method="xml" version="1.0" omit-xml-declaration="no" encoding="UTF-8" standalone="yes" indent="yes"/>
  
  <xsl:preserve-space elements="*"/>

  <!-- process each element -->

  <xsl:template match="*">

    <xsl:variable name="namespaceMatch" select="concat('[', namespace-uri(), ']')"/>
    <xsl:variable name="parentNodeNamespaceMatch" select="concat('[', namespace-uri(parent::node()), ']')"/>

    <xsl:choose>
      <xsl:when test="contains($validNamespaces, $namespaceMatch)">
        <xsl:copy>
          <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
      
        <xsl:text>&#xa;</xsl:text>
        
        <xsl:apply-templates select="node()"/>
        
        <xsl:if test="*[1]">
          <xsl:text>&#xa;</xsl:text>
        </xsl:if>
        
        <xsl:if test="contains($validNamespaces, $parentNodeNamespaceMatch)">
          <xsl:text>&#xa;</xsl:text>
        </xsl:if>
        
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template match="@*">

    <xsl:variable name="parentNodeNamespaceMatch" select="concat('[', namespace-uri(parent::node()), ']')"/>

    <xsl:if test="contains($validNamespaces, $parentNodeNamespaceMatch)">
      <xsl:copy/>
    </xsl:if>

  </xsl:template>

  <xsl:template match="text()">

    <xsl:variable name="parentNodeNamespaceMatch" select="concat('[', namespace-uri(parent::node()), ']')"/>

    <xsl:if test="contains($validNamespaces, $parentNodeNamespaceMatch)">
      <xsl:copy/>
    </xsl:if>

  </xsl:template>

  <xsl:template match="comment()">
  
    <xsl:variable name="parentNodeNamespaceMatch" select="concat('[', namespace-uri(parent::node()), ']')"/>

    <xsl:choose>
      <xsl:when test="contains($validNamespaces, $parentNodeNamespaceMatch)">
        <xsl:copy/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>&#xa;</xsl:text>
        <xsl:copy/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

</xsl:transform>

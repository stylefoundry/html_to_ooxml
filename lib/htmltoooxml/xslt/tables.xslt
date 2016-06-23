<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:a="http://schemas.openxmlformats.org/presentationml/2006/main"
                xmlns:o="urn:schemas-microsoft-com:office:office"
                xmlns:v="urn:schemas-microsoft-com:vml"
                xmlns:WX="http://schemas.microsoft.com/office/word/2003/auxHint"
                xmlns:aml="http://schemas.microsoft.com/aml/2001/core"
                xmlns:w10="urn:schemas-microsoft-com:office:word"
                xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:ext="http://www.xmllab.net/wordml2html/ext"
                xmlns:java="http://xml.apache.org/xalan/java"
                xmlns:str="http://exslt.org/strings"
                xmlns:func="http://exslt.org/functions"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                version="1.0"
                exclude-result-prefixes="java msxsl ext a o v WX aml w10"
                extension-element-prefixes="func">

  <!--XSLT support for tables -->

  <!-- Full width tables per default -->
  <xsl:template match="table">
    <a:tbl>
      <a:tblPr>
        <a:tblStyle a:val="TableGrid"/>
        <a:tblW a:w="5000" a:type="pct"/>
        <xsl:call-template name="tableborders"/>
        <a:tblLook a:val="0600" a:firstRow="0" a:lastRow="0" a:firstColumn="0" a:lastColumn="0" a:noHBand="1" a:noVBand="1"/>
      </a:tblPr>
      <xsl:apply-templates />
    </a:tbl>
  </xsl:template>

  <xsl:template match="tbody">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="thead">
    <xsl:choose>
      <xsl:when test="count(./tr) = 0">
        <a:tr><xsl:apply-templates /></a:tr>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tr">
    <xsl:if test="string-length(.) > 0">
      <a:tr>
        <xsl:apply-templates />
      </a:tr>
    </xsl:if>
  </xsl:template>

  <xsl:template match="th">
    <a:tc>
      <xsl:call-template name="table-cell-properties"/>
      <a:p>
        <a:r>
          <a:rPr>
            <a:b />
          </a:rPr>
          <a:t xml:space="preserve"><xsl:value-of select="."/></a:t>
        </a:r>
      </a:p>
    </a:tc>
  </xsl:template>

  <xsl:template match="td">
    <a:tc>
      <xsl:call-template name="table-cell-properties"/>
      <xsl:call-template name="block">
        <xsl:with-param name="current" select="." />
        <xsl:with-param name="class" select="@class" />
        <xsl:with-param name="style" select="@style" />
      </xsl:call-template>
    </a:tc>
  </xsl:template>

  <xsl:template name="block">
    <xsl:param name="current" />
    <xsl:param name="class" />
    <xsl:param name="style" />
    <xsl:if test="count($current/*|$current/text()) = 0">
      <a:p/>
    </xsl:if>
    <xsl:for-each select="$current/*|$current/text()">
      <xsl:choose>
        <xsl:when test="name(.) = 'table'">
          <xsl:apply-templates select="." />
          <a:p/>
        </xsl:when>
        <xsl:when test="contains('|p|h1|h2|h3|h4|h5|h6|ul|ol|', concat('|', name(.), '|'))">
          <xsl:apply-templates select="." />
        </xsl:when>
        <xsl:when test="descendant::table|descendant::p|descendant::h1|descendant::h2|descendant::h3|descendant::h4|descendant::h5|descendant::h6|descendant::li">
          <xsl:call-template name="block">
            <xsl:with-param name="current" select="."/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <a:p>
            <xsl:call-template name="text-alignment">
              <xsl:with-param name="class" select="$class" />
              <xsl:with-param name="style" select="$style" />
            </xsl:call-template>
            <xsl:apply-templates select="." />
          </a:p>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="tableborders">
    <xsl:variable name="border">
      <xsl:choose>
        <xsl:when test="contains(concat(' ', @class, ' '), ' table-bordered ')">6</xsl:when>
        <xsl:when test="not(@border)">0</xsl:when>
        <xsl:otherwise><xsl:value-of select="./@border * 6"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="bordertype">
      <xsl:choose>
        <xsl:when test="$border=0">none</xsl:when>
        <xsl:otherwise>single</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <a:tblBorders>
      <a:top a:val="{$bordertype}" a:sz="{$border}" a:space="0" a:color="auto"/>
      <a:left a:val="{$bordertype}" a:sz="{$border}" a:space="0" a:color="auto"/>
      <a:bottom a:val="{$bordertype}" a:sz="{$border}" a:space="0" a:color="auto"/>
      <a:right a:val="{$bordertype}" a:sz="{$border}" a:space="0" a:color="auto"/>
      <a:insideH a:val="{$bordertype}" a:sz="{$border}" a:space="0" a:color="auto"/>
      <a:insideV a:val="{$bordertype}" a:sz="{$border}" a:space="0" a:color="auto"/>
    </a:tblBorders>
  </xsl:template>

  <xsl:template name="table-cell-properties">
    <a:tcPr>
      <xsl:if test="contains(@class, 'ms-border-')">
        <a:tcBorders>
          <xsl:for-each select="str:tokenize(@class, ' ')">
            <xsl:call-template name="define-border">
              <xsl:with-param name="class" select="." />
            </xsl:call-template>
          </xsl:for-each>
        </a:tcBorders>
      </xsl:if>
      <xsl:if test="contains(@class, 'ms-fill-')">
        <xsl:variable name="cell-bg" select="str:tokenize(substring-after(@class, 'ms-fill-'), ' ')[1]"/>
        <a:shd a:val="clear" a:color="auto" a:fill="{$cell-bg}" />
      </xsl:if>
    </a:tcPr>
  </xsl:template>

  <xsl:template name="define-border">
    <xsl:param name="class" />
    <xsl:if test="contains($class, 'ms-border-')">
      <xsl:variable name="border" select="substring-after($class, 'ms-border-')"/>
      <xsl:variable name="border-properties" select="str:tokenize($border, '-')"/>
      <xsl:variable name="border-location" select="$border-properties[1]" />
      <xsl:variable name="border-value" select="$border-properties[2]" />
      <xsl:variable name="border-color">
        <xsl:choose>
          <xsl:when test="string-length($border-properties[3]) > 0"><xsl:value-of select="$border-properties[3]"/></xsl:when>
          <xsl:otherwise>000000</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="border-size">
        <xsl:choose>
          <xsl:when test="string-length($border-properties[4]) > 0"><xsl:value-of select="$border-properties[4] * 6"/></xsl:when>
          <xsl:otherwise>6</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:element name="a:{$border-location}">
        <xsl:attribute name="a:val"><xsl:value-of select="$border-value" /></xsl:attribute>
        <xsl:attribute name="a:sz"><xsl:value-of select="$border-size" /></xsl:attribute>
        <xsl:attribute name="a:space">0</xsl:attribute>
        <xsl:attribute name="a:color"><xsl:value-of select="$border-color" /></xsl:attribute>
      </xsl:element>
    </xsl:if>
  </xsl:template>


</xsl:stylesheet>
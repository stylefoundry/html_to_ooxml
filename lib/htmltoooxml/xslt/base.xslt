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
  <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="yes" indent="yes" />
  <xsl:include href="./functions.xslt"/>
  <xsl:include href="./tables.xslt"/>
  <xsl:include href="./links.xslt"/>

  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="head" />

  <xsl:template match="body">
    <xsl:comment>
      KNOWN BUGS:
      div
        h2
        div
          textnode (WONT BE WRAPPED IN A a:P)
          div
            table
            span
              text
    </xsl:comment>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="body/*[not(*)]">
    <a:p>
      <xsl:call-template name="text-alignment" />
      <a:r>
        <a:rPr/>
        <a:t><xsl:value-of select="."/></a:t>
      </a:r>
    </a:p>
  </xsl:template>

  <xsl:template match="br[not(ancestor::p) and not(ancestor::div) and not(ancestor::td|ancestor::li) or
                          (preceding-sibling::div or following-sibling::div or preceding-sibling::p or following-sibling::p)]">
    <a:p><a:endParaRPr/></a:p>
  </xsl:template>

  <xsl:template match="br[(ancestor::li or ancestor::td) and
                          (preceding-sibling::div or following-sibling::div or preceding-sibling::p or following-sibling::p)]">
    <xsl:apply-templates />
    <a:p><a:endParaRPr/></a:p>
  </xsl:template>

  <xsl:template match="br">
    <a:p><a:endParaRPr/></a:p>
  </xsl:template>

  <xsl:template match="pre">
    <a:p>
      <xsl:apply-templates />
    </a:p>
  </xsl:template>

  <xsl:template match="div[not(ancestor::li) and not(ancestor::td) and not(ancestor::th) and not(ancestor::p) and not(descendant::div) and not(descendant::p) and not(descendant::h1) and not(descendant::h2) and not(descendant::h3) and not(descendant::h4) and not(descendant::h5) and not(descendant::h6) and not(descendant::table) and not(descendant::li) and not (descendant::pre)]">
    <xsl:comment>Divs should create a p if nothing above them has and nothing below them will</xsl:comment>
    <a:p>
      <a:pPr>
        <a:spcBef>
          <a:spcPts val="200"/>
        </a:spcBef>
        <a:spcAft>
          <a:spcPts val="600"/>
        </a:spcAft>
      </a:pPr>
      <xsl:call-template name="text-alignment" />
      <xsl:apply-templates />
    </a:p>
  </xsl:template>

  <xsl:template match="div">
    <xsl:apply-templates />
  </xsl:template>

  <!-- TODO: make this prettier. Headings shouldn't enter in template from L51 -->
  <xsl:template match="body/h1|body/h2|body/h3|body/h4|body/h5|body/h6|h1|h2|h3|h4|h5|h6">
    <xsl:variable name="length" select="string-length(name(.))"/>
    <a:p>
      <a:pPr>
        <a:spcBef>
          <a:spcPts val="200"/>
        </a:spcBef>
        <a:spcAft>
          <a:spcPts val="600"/>
        </a:spcAft>
      </a:pPr>
      <a:r>
        <a:rPr b="1" dirty="0"/>
        <a:t><xsl:value-of select="."/></a:t>
      </a:r>
    </a:p>
  </xsl:template>

  <xsl:template match="p[not(ancestor::li)]">
    <a:p>
      <a:pPr>
        <a:spcBef>
          <a:spcPts val="200"/>
        </a:spcBef>
        <a:spcAft>
          <a:spcPts val="600"/>
        </a:spcAft>
      </a:pPr>
      <xsl:call-template name="text-alignment" />
      <xsl:apply-templates />
    </a:p>
  </xsl:template>

  <xsl:template match="ol|ul">
    <xsl:param name="global_level" select="count(preceding::ol[not(ancestor::ol or ancestor::ul)]) + count(preceding::ul[not(ancestor::ol or ancestor::ul)]) + 1"/>
    <xsl:apply-templates>
      <xsl:with-param name="global_level" select="$global_level" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template name="listItem" match="li">
    <xsl:param name="global_level" />
    <xsl:param name="preceding-siblings" select="0"/>
    <xsl:for-each select="node()">
      <xsl:choose>
        <xsl:when test="self::br">
            <a:p>
              <a:r>
                <a:rPr dirty="0"/>
                <a:t><xsl:value-of select="."/></a:t>
              </a:r>
            </a:p>
        </xsl:when>
        <xsl:when test="self::ol|self::ul">
          <xsl:apply-templates>
            <xsl:with-param name="global_level" select="$global_level" />
          </xsl:apply-templates>
        </xsl:when>
        <xsl:when test="not(descendant::li)"> <!-- simpler div, p, headings, etc... -->
          <xsl:variable name="ilvl" select="count(ancestor::ol) + count(ancestor::ul) - 1"></xsl:variable>
          <xsl:choose>
            <xsl:when test="$preceding-siblings + count(preceding-sibling::*) > 0">
              <a:p>
                <a:r>
                  <a:pPr marL="457200" indent="-457200"><a:buFont typeface="Arial" panose="020B0604020202020204" pitchFamily="34" charset="0"/>
                  <a:buChar char="•"/>
                  </a:pPr>
                  <a:rPr dirty="0"/>
                  <a:t><xsl:value-of select="."/></a:t>
                </a:r>
              </a:p>
            </xsl:when>
            <xsl:otherwise>
              <a:p>
                <a:pPr marL="457200" indent="-457200">
  								<a:buFont typeface="Arial" panose="020B0604020202020204" pitchFamily="34" charset="0"/>
                  <a:buChar char="•"/>
                </a:pPr>
                <a:r>
                  <a:rPr dirty="0"/>
                  <a:t><xsl:value-of select="."/></a:t>
                </a:r>
              </a:p>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise> <!-- mixed things div having list and stuff content... -->
          <xsl:call-template name="listItem">
            <xsl:with-param name="global_level" select="$global_level" />
            <xsl:with-param name="preceding-siblings" select="$preceding-siblings + count(preceding-sibling::*)" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="span[not(ancestor::td) and not(ancestor::li) and (preceding-sibling::h1 or preceding-sibling::h2 or preceding-sibling::h3 or preceding-sibling::h4 or preceding-sibling::h5 or preceding-sibling::h6 or preceding-sibling::table or preceding-sibling::p or preceding-sibling::ol or preceding-sibling::ul or preceding-sibling::div or following-sibling::h1 or following-sibling::h2 or following-sibling::h3 or following-sibling::h4 or following-sibling::h5 or following-sibling::h6 or following-sibling::table or following-sibling::p or following-sibling::ol or following-sibling::ul or following-sibling::div)]
    |a[not(ancestor::td) and not(ancestor::li) and (preceding-sibling::h1 or preceding-sibling::h2 or preceding-sibling::h3 or preceding-sibling::h4 or preceding-sibling::h5 or preceding-sibling::h6 or preceding-sibling::table or preceding-sibling::p or preceding-sibling::ol or preceding-sibling::ul or preceding-sibling::div or following-sibling::h1 or following-sibling::h2 or following-sibling::h3 or following-sibling::h4 or following-sibling::h5 or following-sibling::h6 or following-sibling::table or following-sibling::p or following-sibling::ol or following-sibling::ul or following-sibling::div)]
    |small[not(ancestor::td) and not(ancestor::li) and (preceding-sibling::h1 or preceding-sibling::h2 or preceding-sibling::h3 or preceding-sibling::h4 or preceding-sibling::h5 or preceding-sibling::h6 or preceding-sibling::table or preceding-sibling::p or preceding-sibling::ol or preceding-sibling::ul or preceding-sibling::div or following-sibling::h1 or following-sibling::h2 or following-sibling::h3 or following-sibling::h4 or following-sibling::h5 or following-sibling::h6 or following-sibling::table or following-sibling::p or following-sibling::ol or following-sibling::ul or following-sibling::div)]
    |strong[not(ancestor::td) and not(ancestor::li) and (preceding-sibling::h1 or preceding-sibling::h2 or preceding-sibling::h3 or preceding-sibling::h4 or preceding-sibling::h5 or preceding-sibling::h6 or preceding-sibling::table or preceding-sibling::p or preceding-sibling::ol or preceding-sibling::ul or preceding-sibling::div or following-sibling::h1 or following-sibling::h2 or following-sibling::h3 or following-sibling::h4 or following-sibling::h5 or following-sibling::h6 or following-sibling::table or following-sibling::p or following-sibling::ol or following-sibling::ul or following-sibling::div)]
    |em[not(ancestor::td) and not(ancestor::li) and (preceding-sibling::h1 or preceding-sibling::h2 or preceding-sibling::h3 or preceding-sibling::h4 or preceding-sibling::h5 or preceding-sibling::h6 or preceding-sibling::table or preceding-sibling::p or preceding-sibling::ol or preceding-sibling::ul or preceding-sibling::div or following-sibling::h1 or following-sibling::h2 or following-sibling::h3 or following-sibling::h4 or following-sibling::h5 or following-sibling::h6 or following-sibling::table or following-sibling::p or following-sibling::ol or following-sibling::ul or following-sibling::div)]
    |i[not(ancestor::td) and not(ancestor::li) and (preceding-sibling::h1 or preceding-sibling::h2 or preceding-sibling::h3 or preceding-sibling::h4 or preceding-sibling::h5 or preceding-sibling::h6 or preceding-sibling::table or preceding-sibling::p or preceding-sibling::ol or preceding-sibling::ul or preceding-sibling::div or following-sibling::h1 or following-sibling::h2 or following-sibling::h3 or following-sibling::h4 or following-sibling::h5 or following-sibling::h6 or following-sibling::table or following-sibling::p or following-sibling::ol or following-sibling::ul or following-sibling::div)]
    |b[not(ancestor::td) and not(ancestor::li) and (preceding-sibling::h1 or preceding-sibling::h2 or preceding-sibling::h3 or preceding-sibling::h4 or preceding-sibling::h5 or preceding-sibling::h6 or preceding-sibling::table or preceding-sibling::p or preceding-sibling::ol or preceding-sibling::ul or preceding-sibling::div or following-sibling::h1 or following-sibling::h2 or following-sibling::h3 or following-sibling::h4 or following-sibling::h5 or following-sibling::h6 or following-sibling::table or following-sibling::p or following-sibling::ol or following-sibling::ul or following-sibling::div)]
    |u[not(ancestor::td) and not(ancestor::li) and (preceding-sibling::h1 or preceding-sibling::h2 or preceding-sibling::h3 or preceding-sibling::h4 or preceding-sibling::h5 or preceding-sibling::h6 or preceding-sibling::table or preceding-sibling::p or preceding-sibling::ol or preceding-sibling::ul or preceding-sibling::div or following-sibling::h1 or following-sibling::h2 or following-sibling::h3 or following-sibling::h4 or following-sibling::h5 or following-sibling::h6 or following-sibling::table or following-sibling::p or following-sibling::ol or following-sibling::ul or following-sibling::div)]">
    <xsl:comment>
        In the following situation:

        div
          h2
          span
            textnode
            span
              textnode
          p

        The div template will not create a a:p because the div contains a h2. Therefore we need to wrap the inline elements span|a|small in a p here.
      </xsl:comment>
    <a:p>
      <xsl:choose>
        <xsl:when test="self::a[starts-with(@href, 'http://') or starts-with(@href, 'https://')]">
          <xsl:call-template name="link" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates />
        </xsl:otherwise>
      </xsl:choose>
    </a:p>
  </xsl:template>

  <xsl:template match="text()[not(parent::li) and not(parent::td) and not(parent::pre) and (preceding-sibling::h1 or preceding-sibling::h2 or preceding-sibling::h3 or preceding-sibling::h4 or preceding-sibling::h5 or preceding-sibling::h6 or preceding-sibling::table or preceding-sibling::p or preceding-sibling::ol or preceding-sibling::ul or preceding-sibling::div or following-sibling::h1 or following-sibling::h2 or following-sibling::h3 or following-sibling::h4 or following-sibling::h5 or following-sibling::h6 or following-sibling::table or following-sibling::p or following-sibling::ol or following-sibling::ul or following-sibling::div)]">
    <xsl:comment>
        In the following situation:

        div
          h2
          textnode
          p

        The div template will not create a a:p because the div contains a h2. Therefore we need to wrap the textnode in a p here.
      </xsl:comment>
    <a:p>
      <a:r>
        <a:rPr/>
        <a:t><xsl:value-of select="."/></a:t>
      </a:r>
    </a:p>
  </xsl:template>

  <xsl:template match="span[contains(concat(' ', @class, ' '), ' h ')]">
    <xsl:comment>
        This template adds MS Word highlighting ability.
      </xsl:comment>
    <xsl:variable name="color">
      <xsl:choose>
        <xsl:when test="./@data-style='pink'">magenta</xsl:when>
        <xsl:when test="./@data-style='blue'">cyan</xsl:when>
        <xsl:when test="./@data-style='orange'">darkYellow</xsl:when>
        <xsl:otherwise><xsl:value-of select="./@data-style"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="preceding-sibling::h1 or preceding-sibling::h2 or preceding-sibling::h3 or preceding-sibling::h4 or preceding-sibling::h5 or preceding-sibling::h6 or preceding-sibling::table or preceding-sibling::p or preceding-sibling::ol or preceding-sibling::ul or preceding-sibling::div or following-sibling::h1 or following-sibling::h2 or following-sibling::h3 or following-sibling::h4 or following-sibling::h5 or following-sibling::h6 or following-sibling::table or following-sibling::p or following-sibling::ol or following-sibling::ul or following-sibling::div">
        <a:p>
          <a:r>
            <a:rPr>
              <a:highlight a:val="{$color}"/>
            </a:rPr>
            <a:t><xsl:value-of select="."/></a:t>
          </a:r>
        </a:p>
      </xsl:when>
      <xsl:otherwise>
        <a:r>
          <a:rPr>
            <a:highlight a:val="{$color}"/>
          </a:rPr>
          <a:t><xsl:value-of select="."/></a:t>
        </a:r>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="div[contains(concat(' ', @class, ' '), ' -page-break ')]">
    <a:p>
      <a:endParaRPr/>
    </a:p>
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="details" />

  <xsl:template match="text()">
    <xsl:if test="string-length(.) > 0">
      <a:r>
        <xsl:if test="ancestor::i | ancestor::b | ancestor::u | ancestor::s | ancestor::sub | ancestor::sup">
          <xsl:element name="a:rPr">
            <xsl:attribute name="dirty">0</xsl:attribute>
            <xsl:if test="ancestor::i">
              <xsl:attribute name="i">1</xsl:attribute>
            </xsl:if>
            <xsl:if test="ancestor::b">
              <xsl:attribute name="b">1</xsl:attribute>
            </xsl:if>
            <xsl:if test="ancestor::u">
              <xsl:attribute name="u">sng</xsl:attribute>
            </xsl:if>
          </xsl:element>
        </xsl:if>
        <a:t><xsl:value-of select="."/></a:t>
      </a:r>
    </xsl:if>
  </xsl:template>
  <xsl:template match="*">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template name="text-alignment">
    <xsl:param name="class" select="@class" />
    <xsl:param name="style" select="@style" />
    <xsl:variable name="alignment">
      <xsl:choose>
        <xsl:when test="contains(concat(' ', $class, ' '), ' center ') or contains(translate(normalize-space($style),' ',''), 'text-align:center')">center</xsl:when>
        <xsl:when test="contains(concat(' ', $class, ' '), ' right ') or contains(translate(normalize-space($style),' ',''), 'text-align:right')">right</xsl:when>
        <xsl:when test="contains(concat(' ', $class, ' '), ' left ') or contains(translate(normalize-space($style),' ',''), 'text-align:left')">left</xsl:when>
        <xsl:when test="contains(concat(' ', $class, ' '), ' justify ') or contains(translate(normalize-space($style),' ',''), 'text-align:justify')">both</xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="string-length(normalize-space($alignment)) > 0">
      <a:pPr>
        <a:jc a:val="{$alignment}"/>
      </a:pPr>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>

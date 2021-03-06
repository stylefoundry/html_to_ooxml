<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:a="http://schemas.openxmlformats.org/presentationml/2006/main"
                xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
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

  <xsl:template match="a[starts-with(@href, 'http://') or starts-with(@href, 'https://')]" name="link">
    <!--
    <a:hyperlink>
      //-->
      <a:r>
        <a:rPr>
          <a:hlinkClick>
            <xsl:attribute name="r:id">rId<xsl:value-of select="count(preceding::a[starts-with(@href, 'http://') or starts-with(@href, 'https://')]) + 100" /></xsl:attribute>
          </a:hlinkClick>
        </a:rPr>
        <a:t>
          <xsl:value-of select="."/>
        </a:t>
      </a:r>
  </xsl:template>
</xsl:stylesheet>
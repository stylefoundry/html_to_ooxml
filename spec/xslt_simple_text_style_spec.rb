require 'spec_helper'

describe "XSLT" do


  it "transforms a div into a pptx block element." do
    html = '<html><head></head><body><div>Hello</div></body></html>'
    compare_resulting_ooxml_with_expected(html, "<a:p> <a:r> <a:t>Hello</a:t> </a:r> </a:p>")
  end

  context "transform a span" do

    it "into a pptx element if child of body." do
      html = '<html><head></head><body><span>Hello</span></body></html>'
      compare_resulting_ooxml_with_expected(html, "<a:p> <a:r> <a:rPr/> <a:t>Hello</a:t> </a:r> </a:p>")
    end

    it "into a docx inline element if not child of body." do
      html = '<html><head></head><body><div><span>Hello</span></div></body></html>'
      compare_resulting_ooxml_with_expected(html, "<a:p> <a:r> <a:t>Hello</a:t> </a:r> </a:p>")
    end

  end

  it "transforms a p into a pptx block element." do
    html = '<html><head></head><body><p>Hello</p></body></html>'
    compare_resulting_ooxml_with_expected(html, "<a:p> <a:r> <a:t>Hello</a:t> </a:r> </a:p>")
  end

  it "transforms a p with a br into a pptx block element with a break." do
    html = '<html><head></head><body><p>Hello <br> Bob</p></body></html>'
    compare_resulting_ooxml_with_expected(html, "<a:p> <a:r> <a:t>Hello </a:t> </a:r> </a:p><a:p><a:endParaRPr lang=\"en-US\" dirty=\"0\"/></a:p><a:p><a:r><a:t> Bob</a:t></a:r> </a:p>")
  end

  it "transforms a b into pptx b" do
    html = '<html><head></head><body><p><b>Hello</b></p></body></html>'
    compare_resulting_ooxml_with_expected(html, "<a:p> <a:r> <a:rPr dirty=\"0\" b=\"1\"/> <a:t>Hello</a:t> </a:r> </a:p>")
  end

  it "transforms a href into pptx link" do
    html = '<html><head></head><body><p><a href="http://www.somewhere.com">Hello</a></p></body></html>'
    compare_resulting_ooxml_with_expected(html, "<a:p> <a:r> <a:rPr> <a:hlinkClick r:id=\"rId100\"/></a:rPr> <a:t>Hello</a:t> </a:r> </a:p>")
  end

  it "transforms a bulleted list" do
    html = "<html><head></head><body><ul><li>Test 1</li></ul></body></html>"
    compare_resulting_ooxml_with_expected(html, "<a:p><a:pPr marL=\"457200\" indent=\"-457200\"><a:buFont typeface=\"Arial\" panose=\"020B0604020202020204\" pitchFamily=\"34\" charset=\"0\"/><a:buChar char=\"•\"/></a:pPr><a:r><a:rPr dirty=\"0\"/><a:t>Test 1</a:t></a:r></a:p>")
  end

  describe 'text formatting' do
    it 'bolds' do
      html = <<~HTML
        <html>
          <head></head>
          <body>
            <p>Hello, <b>World!</b></p>
          </body>
        </html>
      HTML

      ooxml = <<~XML
        <a:p>
          <a:r>
            <a:t>Hello, </a:t>
          </a:r>
          <a:r>
            <a:rPr dirty="0" b="1"/>
            <a:t>World!</a:t>
          </a:r>
        </a:p>
      XML

      compare_resulting_ooxml_with_expected(html, ooxml)
    end

    it 'italicizes' do
      html = <<~HTML
        <html>
          <head></head>
          <body>
            <p>Hello, <i>World!</i></p>
          </body>
        </html>
      HTML

      ooxml = <<~XML
        <a:p>
          <a:r>
            <a:t>Hello, </a:t>
          </a:r>
          <a:r>
            <a:rPr dirty="0" i="1"/>
            <a:t>World!</a:t>
          </a:r>
        </a:p>
      XML

      compare_resulting_ooxml_with_expected(html, ooxml)
    end

    it 'underlines' do
      html = <<~HTML
        <html>
          <head></head>
          <body>
            <p>Hello, <u>World!</u></p>
          </body>
        </html>
      HTML

      ooxml = <<~XML
        <a:p>
          <a:r>
            <a:t>Hello, </a:t>
          </a:r>
          <a:r>
            <a:rPr dirty="0" u="sng"/>
            <a:t>World!</a:t>
          </a:r>
        </a:p>
      XML

      compare_resulting_ooxml_with_expected(html, ooxml)
    end

    it 'combines multiple styles' do
      html = <<~HTML
        <html>
          <head></head>
          <body>
            <p>Hello, <b>World! <i>Are</i> you <u>well?</u></b></p>
          </body>
        </html>
      HTML

      ooxml = <<~XML
        <a:p>
          <a:r>
            <a:t>Hello, </a:t>
          </a:r>
          <a:r>
            <a:rPr dirty="0" b="1"/>
            <a:t>World! </a:t>
          </a:r>
          <a:r>
            <a:rPr dirty="0" i="1" b="1"/>
            <a:t>Are</a:t>
          </a:r>
          <a:r>
            <a:rPr dirty="0" b="1"/>
            <a:t> you </a:t>
          </a:r>
          <a:r>
            <a:rPr dirty="0" b="1" u="sng"/>
            <a:t>well?</a:t>
          </a:r>
        </a:p>
      XML

      compare_resulting_ooxml_with_expected(html, ooxml)
    end
  end
end

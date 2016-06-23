require 'spec_helper'

describe "XSLT" do


  it "transforms a div into a pptx block element." do
    html = '<html><head></head><body><div>Hello</div></body></html>'
    compare_resulting_ooxml_with_expected(html, "<a:p> <a:r> <a:t xml:space=\"preserve\">Hello</a:t> </a:r> </a:p>")
  end

  context "transform a span" do

    it "into a pptx element if child of body." do
      html = '<html><head></head><body><span>Hello</span></body></html>'
      compare_resulting_ooxml_with_expected(html, "<a:p> <a:r> <a:t xml:space=\"preserve\">Hello</a:t> </a:r> </a:p>")
    end

    it "into a docx inline element if not child of body." do
      html = '<html><head></head><body><div><span>Hello</span></div></body></html>'
      compare_resulting_ooxml_with_expected(html, "<a:p> <a:r> <a:t xml:space=\"preserve\">Hello</a:t> </a:r> </a:p>")
    end

  end

  it "transforms a p into a pptx block element." do
    html = '<html><head></head><body><p>Hello</p></body></html>'
    compare_resulting_ooxml_with_expected(html, "<a:p> <a:r> <a:t xml:space=\"preserve\">Hello</a:t> </a:r> </a:p>")
  end

end

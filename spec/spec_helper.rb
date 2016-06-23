require 'nokogiri'
require 'Htmltoooxml'

include Htmltoooxml::XSLTHelper

def html_to_ooxml(html)
 source = Nokogiri::HTML(html.gsub(/>\s+</, "><"))
 xslt = Nokogiri::XSLT(File.read('spec/html_to_ooxml.xslt'))
 result = xslt.apply_to(source)
 result
end

def compare_transformed_files(test, test_file_name, extras: false)
  source = File.read(fixture_path(test, test_file_name, :html))
  expected_content = File.read(fixture_path(test, test_file_name, :xml))
  compare_resulting_ooxml_with_expected(source, expected_content, extras: extras)
end

def compare_resulting_ooxml_with_expected(html, resulting_ooxml, extras: false)
  source = Nokogiri::HTML(html.gsub(/>\s+</, '><'))
  result = Htmltoooxml::Document.new().transform_doc_xml(source, extras)
  result.gsub!(/\s*<!--(.*?)-->\s*/m, '')
  result = remove_declaration(result)
  puts result
  expect(remove_whitespace(result)).to eq(remove_whitespace(resulting_ooxml))
end

private

def fixture_path(folder, file_name, extension)
  File.join(File.dirname(__FILE__), 'fixtures', folder, "#{file_name}.#{extension}")
end


def remove_whitespace(ooxml)
  ooxml.gsub(/\s+/, ' ').gsub(/>\s+</, '><').strip
end

def remove_declaration(ooxml)
  ooxml.sub(/<\?xml (.*?)>/, '').gsub(/\s*xmlns:(\w+)="(.*?)\s*"/, '')
end


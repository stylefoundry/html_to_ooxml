module Htmltoooxml
  class Configuration
    attr_accessor :default_xslt_path, :custom_xslt_path

    def initialize
      @default_xslt_path = File.join(File.expand_path('../', __FILE__), 'xslt')
      @custom_xslt_path = File.join(File.expand_path('../', __FILE__), 'xslt')
    end
  end
end
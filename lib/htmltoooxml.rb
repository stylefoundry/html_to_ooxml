require 'nokogiri'
require 'zip'
require_relative 'htmltoooxml/configuration'

module Htmltoooxml
  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    alias_method :config, :configuration
  end
end

require_relative 'htmltoooxml/version'
require_relative 'htmltoooxml/helpers/xslt_helper'
require_relative 'htmltoooxml/document'

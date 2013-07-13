require "uglifier"
require "yui/compressor"

module Linner
  class Compressor

    def self.compress(type, content)
      case type
      when "scripts"
        Uglifier.compile content, comments: "none"
      when "styles"
        YUI::CssCompressor.new.compress content
      end
    end
  end
end

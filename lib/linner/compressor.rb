require "uglifier"
require "yui/compressor"

module Linner
  class Compressor

    def self.compress(type, content)
      if type == "scripts"
        content = Uglifier.compile(content, comments: "none")
      elsif type == "styles"
        content = YUI::CssCompressor.new.compress(content)
      end
      content
    end
  end
end

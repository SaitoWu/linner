require "uglifier"
require "yui/compressor"

module Linner
  class Compressor

    def self.compress(asset)
      if Template.template_for_script? asset.path
        Uglifier.compile asset.content, comments: "none"
      elsif Template.template_for_style? asset.path
        YUI::CssCompressor.new.compress asset.content
      end
    end
  end
end

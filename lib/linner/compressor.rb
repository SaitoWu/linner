require "uglifier"
require "yui/compressor"

module Linner
  class Compressor

    def self.compress(asset)
      case asset.type
      when "script"
        Uglifier.compile asset.content, comments: "none"
      when "style"
        YUI::CssCompressor.new.compress asset.content
      end
    end
  end
end

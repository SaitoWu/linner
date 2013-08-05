require "uglifier"
require "cssminify"

module Linner
  class Compressor

    def self.compress(asset)
      if asset.javascript?
        Uglifier.compile asset.content, comments: "none"
      elsif asset.stylesheet?
        CSSminify.new.compress asset.content
      end
    end
  end
end

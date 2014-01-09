require "uglifier"
require "cssminify"

module Linner
  class Compressor

    def self.compress(asset)
      if asset.javascript? or asset.template?
        Uglifier.compile asset.content, comments: "none"
      elsif asset.stylesheet?
        CSSminify.new.compress asset.content
      else
        asset.content
      end
    end
  end
end

require "uglifier"

module Linner
  class Compressor

    def self.compress(content)
      Uglifier.compile(content, comments: "none")
    end
  end
end

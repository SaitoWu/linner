require 'tilt'
require 'sass'
require 'coffee_script'

module Linner
  class Template
    include Linner::Helper

    def initialize(path)
      @path = path
    end

    def render
      if plain_text? @path
        File.read @path
      else
        Tilt.new(@path).render
      end
    end
  end
end

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
      if supported_template? @path
        Tilt.new(@path).render
      else
        File.read @path
      end
    end
  end
end

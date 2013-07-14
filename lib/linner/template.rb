require 'tilt'
require 'sass'
require 'coffee_script'

module Linner
  class Template

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

    private
    def supported_template?(path)
      %w[.coffee .sass .scss].include? File.extname(path)
    end
  end
end

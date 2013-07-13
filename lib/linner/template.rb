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
      content = if plain_text? @path
        File.read @path
      else
        Tilt.new(@path).render
      end

      if !@path.include?(File.join(root, "vendor")) and is_scripts?(@path)
        content = Linner::Wrapper.wrap(File.basename(@path, File.extname(@path)), content)
      end
      content
    end
  end
end

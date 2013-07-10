require 'tilt'

module Linner
  class Template
    include Linner::Helper

    def initialize(path)
      @path = path
    end

    def render_to(file)
      if skip_extnames.include? File.extname(@path)
        content = File.read @path
      else
        content = Tilt.new(@path).render
      end

      if !@path.include?(File.join(root, "vendor")) and is_scripts?(@path)
        content = Linner::Wrapper.wrap(File.basename(@path, File.extname(@path)), content)
      end

      file.write(content)
    end
  end
end

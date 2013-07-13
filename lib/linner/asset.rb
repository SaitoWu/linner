module Linner
  class Asset
    include Linner::Helper

    attr_accessor :path
    attr_accessor :content

    def initialize(path)
      @path = path
      if path =~ /#{root}\/public/
        @content = ""
      else
        @content = Linner::Template.new(path).render
      end
    end

    def type
      @type ||= if @path =~ /\.(js|coffee)$/
        "script"
      elsif @path =~ /\.(css|sass|scss)/
        "style"
      end
    end

    def wrap
      Linner::Wrapper.wrap(logical_path.chomp(File.extname logical_path), @content)
    end

    def wrappable?
      !!(!@path.include?(File.join(root, "vendor")) and type == "script")
    end

    def write
      FileUtils.mkdir_p File.dirname(@path)
      File.open @path, "w+" do |file|
        file.write @content
      end
    end

    def compress
      @content = Linner::Compressor.compress(self)
    end

    def logical_path
      @logical_path ||= @path.gsub(/#{root}\/app\/\w*\//, "")
    end
  end
end

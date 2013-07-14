module Linner
  class Asset

    attr_accessor :path, :content

    def initialize(path)
      @path = path
      if path =~ /#{Linner.root.to_path}\/public/
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
      !!(!@path.include? Linner.root.join("vendor").to_path and type == "script")
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
      @logical_path ||= @path.gsub(/#{Linner.root}\/app\/\w*\//, "")
    end
  end
end

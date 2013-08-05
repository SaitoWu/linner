module Linner
  class Asset

    attr_accessor :path, :content

    def initialize(path)
      @path = path
      @content = begin
        File.exist?(path) ? Tilt.new(path, :default_encoding => "UTF-8").render : ""
      rescue RuntimeError
        File.read(path)
      end
    end

    def wrap
      Wrapper.wrap(logical_path.chomp(File.extname logical_path), @content)
    end

    def javascript?
      Tilt[path].default_mime_type == "application/javascript"
    end

    def stylesheet?
      Tilt[path].default_mime_type == "text/css"
    end

    def wrappable?
      !!(!Linner.environment.modules_ignored.include?(@path) and self.javascript?)
    end

    def write
      FileUtils.mkdir_p File.dirname(@path)
      File.open @path, "w" do |file|
        file.write @content
      end
    end

    def compress
      @content = Compressor.compress(self)
    end

    def logical_path
      @logical_path ||= @path.gsub(/#{Linner.environment.paths.join("\/|")}/, "")
    end
  end
end

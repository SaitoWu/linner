module Linner
  class Asset

    attr_accessor :path, :content, :mtime

    def initialize(path)
      @path = path
    end

    def mtime
      @mtime = File.mtime(path).to_i
    end

    def content
      return @content if @content
      source = begin
        File.exist?(path) ? Tilt.new(path, :default_encoding => "UTF-8").render : ""
      rescue RuntimeError
        File.read(path)
      end
      if wrappable?
        @content = wrap(source)
      else
        @content = source
      end
    end

    def wrap(source)
      Wrapper.wrap(logical_path.chomp(File.extname logical_path), source)
    end

    def javascript?
      Tilt[path].default_mime_type == "application/javascript"
    end

    def stylesheet?
      Tilt[path].default_mime_type == "text/css"
    end

    def wrappable?
      !!(self.javascript? and !Linner.env.modules_ignored.include?(@path))
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
      @logical_path ||= @path.gsub(/#{Linner.env.paths.join("\/|")}/, "")
    end
  end
end

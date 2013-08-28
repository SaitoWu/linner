require "digest"

module Linner
  class Asset
    class RenderError < StandardError; end

    attr_accessor :path, :content

    def initialize(path)
      @path = path
      @mtime = File.mtime(path).to_i if File.exist?(path)
    end

    def mtime
      @mtime
    end

    def extname
      @extname = File.extname path
    end

    def digest_path
      digest = Digest::MD5.hexdigest content
      path.chomp(extname) << "-#{digest}" << extname
    end

    def relative_digest_path
      digest_path.gsub /#{Linner.env.public_folder}/, ""
    end

    def revision!
      File.rename path, digest_path
    end

    def content
      return @content if @content
      source = begin
        File.exist?(path) ? Tilt.new(path, :default_encoding => "UTF-8").render : ""
      rescue RuntimeError
        File.read(path)
      rescue => e
        raise RenderError, "#{e.message} in (#{path})"
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
      Tilt[path] and Tilt[path].default_mime_type == "application/javascript"
    end

    def stylesheet?
      Tilt[path] and Tilt[path].default_mime_type == "text/css"
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
      @logical_path ||= @path.gsub(/^(#{Linner.env.paths.join("|")})\/?/, "")
    end
  end
end

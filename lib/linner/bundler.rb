require "uri"
require "digest"
require "fileutils"
require "open-uri"

module Linner
  class Bundler
    VENDOR = Pathname(".").join "vendor"
    REPOSITORY = File.expand_path "~/.linner/bundles"

    Bundle = Struct.new(:name, :version, :url) do
      def path
        File.join(REPOSITORY, name, version, File.basename(url))
      end
    end

    def initialize(bundles)
      @bundles = []
      bundles.each do |name, props|
        @bundles << Bundle.new(name, props["version"], props["url"])
      end
    end

    def check
      return [false, "Bundles didn't exsit!"] unless File.exist? REPOSITORY
      @bundles.each do |bundle|
        unless File.exist?(bundle.path) and File.exist?(File.join(VENDOR, bundle.name))
          return [false, "Bundle #{bundle.name} v#{bundle.version} didn't match!"]
        end
      end
      return [true, "Perfect bundled, ready to go!"]
    end

    def install
      unless File.exist? REPOSITORY
        FileUtils.mkdir_p(REPOSITORY)
      end
      @bundles.each do |bundle|
        if bundle.version != "master"
          next if File.exist?(bundle.path) and File.exist?(File.join(VENDOR, bundle.name))
        end
        puts "Installing #{bundle.name} #{bundle.version}..."
        install_to_repository bundle.url, bundle.path
        link_to_vendor bundle.path, File.join(VENDOR, bundle.name)
      end
    end

    def perform
      check and install
    end

    private
    def install_to_repository(url, path)
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, "w") do |dist|
        if url =~ URI::regexp
          open(url, "r:UTF-8") {|file| dist.write file.read}
        else
          dist.write(File.read Pathname(url).expand_path)
        end
      end
    end

    def link_to_vendor(path, dist)
      return if File.exist?(dist) and Digest::MD5.file(path).hexdigest == Digest::MD5.file(dist).hexdigest
      FileUtils.mkdir_p File.dirname(dist)
      FileUtils.cp path, dist
    end
  end
end

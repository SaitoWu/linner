require "digest"
require "fileutils"
require "open-uri"

module Linner
  class Bundler
    VENDOR = Pathname(".").expand_path.join "vendor"
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
      return [false, "Bundles didn't exsit!"] unless File.exists? REPOSITORY
      @bundles.each do |bundle|
        unless File.exists? bundle.path
          return [false, "Bundle #{bundle.name} v#{bundle.version} didn't match!"]
        end
      end
      return [true, "Perfect bundled, ready to go!"]
    end

    def install
      unless File.exists? REPOSITORY
        FileUtils.mkdir_p(REPOSITORY)
      end
      @bundles.each do |bundle|
        next if File.exists? bundle.path
        puts "Installing #{bundle.name} v#{bundle.version}..."
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
        open(url) {|file| dist.write file.read}
      end
    end

    def link_to_vendor(path, dist)
      if Digest::MD5.file(path).hexdigest != Digest::MD5.file(dist).hexdigest
        FileUtils.cp path, dist
      end
    end
  end
end

require "uri"
require "digest"
require "fileutils"
require "open-uri"

module Linner
  class Bundler
    REPOSITORY = File.expand_path "~/.linner/bundles"

    Bundle = Struct.new(:name, :version, :url) do
      def path
        File.join(REPOSITORY, name, version, File.basename(url))
      end
    end

    def initialize(env)
      @bundles = []
      env.bundles.each do |name, props|
        @bundles << Bundle.new(name, props["version"], props["url"])
      end
      @vendor = Pathname(".").join env.vendor_folder
    end

    def check
      return [false, "Bundles didn't exsit!"] unless File.exist? REPOSITORY
      @bundles.each do |bundle|
        unless File.exist?(bundle.path) and File.exist?(File.join(@vendor, bundle.name))
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
          next if File.exist?(bundle.path) and File.exist?(File.join(@vendor, bundle.name))
        end
        puts "Installing #{bundle.name} #{bundle.version}..."
        install_to_repository bundle
        if File.extname(bundle.path) == ".gz"
          link_and_extract_to_vendor bundle.path, File.join(@vendor, ".pkg", bundle.name, File.basename(bundle.path)), File.join(@vendor, bundle.name)
        else
          link_to_vendor bundle.path, File.join(@vendor, bundle.name)
        end
      end
    end

    def perform
      check and install
    end

    private
    def install_to_repository(bundle)
      FileUtils.mkdir_p File.dirname(bundle.path)
      begin
        File.open(bundle.path, "wb") do |dest|
          if bundle.url =~ URI::regexp
            open(bundle.url, "r:UTF-8") {|file| dest.write file.read}
          else
            dest.write(File.read Pathname(bundle.url).expand_path)
          end
        end
      rescue
        Notifier.error("Can't fetch bundle #{bundle.name} from #{bundle.url}")
        Kernel::exit
      end
    end

    def link_to_vendor(path, dest)
      return if File.exist?(dest) and Digest::MD5.file(path).hexdigest == Digest::MD5.file(dest).hexdigest
      FileUtils.mkdir_p File.dirname(dest)
      FileUtils.cp path, dest
    end

    def link_and_extract_to_vendor(path, linked_path, dest)
      link_to_vendor(path, linked_path)
      FileUtils.rm_rf Dir.glob("#{dest}/*")
      Archive.untar(path, dest)
    end
  end
end

require "thor"
require "listen"

module Linner
  class Command < Thor
    include Thor::Actions
    map "-v" => :version

    def self.source_root
      File.dirname(__FILE__)
    end

    desc "version", "show version"
    def version
      puts Linner::VERSION
    end

    desc "build", "build assets"
    def build
      Linner.compile = true

      clean

      Notifier.profile do
        Linner.perform
      end
    end

    desc "watch", "watch assets"
    def watch
      trap :INT do
        Notifier.exit
        Process.kill("QUIT", 0)
      end

      clean

      @proc = Proc.new do |modified, added, removed|
        begin
          Notifier.profile{ Linner.perform }
        rescue
          Notifier.error $!
        end
      end
      @proc.call

      Listen.to env.app_folder, env.vendor_folder, env.test_folder do |modified, added, removed|
        is_include_partial_styles = (modified + added + removed).any? do |path|
          Asset.new(path).stylesheet? and File.basename(path).start_with? "_"
        end
        Linner.cache.reject! {|k, v| v.stylesheet?} if is_include_partial_styles
        @proc.call
      end

      @reactor = Reactor.supervise_as(:reactor).actors.first
      Listen.to env.public_folder, relative_path: true do |modified, added, removed|
        @reactor.reload_browser(modified + added + removed)
      end

      sleep
    end

    desc "clean", "clean assets"
    def clean
      FileUtils.rm_rf Dir.glob("#{env.public_folder}/*")
    end

    desc "new", "create the skeleton of project"
    def new(name)
      directory('templates', name)
      chmod("#{name}/bin/server", 0755)
    end

  private
    def env
      Linner.env
    end
  end
end


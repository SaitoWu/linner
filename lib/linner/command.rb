require "thor"
require "listen"

module Linner
  class Command < Thor
    include Thor::Actions

    def self.source_root
      File.dirname(__FILE__)
    end

    desc "build", "build assets"
    def build
      Notifier.info do
        Linner.perform compile: true
      end
    end

    desc "watch", "watch assets"
    def watch
      Reactor::Server.supervise_as :reactor

      @proc = Proc.new do |modified, added, removed|
        begin
          Notifier.info{ Linner.perform }
        rescue
          Notifier.error $!
        end
      end
      @proc.call

      Listen.to env.app_folder, env.vendor_folder, env.test_folder do |modified, added, removed|
        @proc.call
      end

      Listen.to env.public_folder, :relative_paths => true do |modified, added, removed|
        paths = [].push(modified, added, removed).flatten.compact
        @reactor.reload_browser(paths)
      end

      trap :INT do
        Notifier.exit
        exit!
      end

      sleep
    end

    desc "clean", "clean assets"
    def clean
      FileUtils.rm_rf Dir.glob("#{Linner.environment.public_folder}/*")
    end

    desc "new", "create the skeleton of project"
    def new(name)
      directory('templates', name)
      chmod("#{name}/bin/server", 0755)
    end

    private
    def env
      Linner.environment
    end
  end
end


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
      proc = Proc.new do |modified, added, removed|
        begin
          Notifier.info{ Linner.perform }
        rescue
          Notifier.error $!
        end
      end
      proc.call
      listener = Listen.to "app/", "vendor/", "test/", filter: /\.(js|coffee|css|sass|scss)$/
      listener.change &proc
      trap :INT do
        Notifier.exit
        exit!
      end
      listener.start!
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
  end
end


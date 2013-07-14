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
      Linner::Notifier.info do
        Linner.perform compile: true
      end
    end

    desc "watch", "watch assets"
    def watch
      proc = Proc.new do |modified, added, removed|
        begin
          Linner::Notifier.info{ Linner.perform }
        rescue
          Linner::Notifier.error $!
        end
      end
      proc.call
      listener = Listen.to "app/", "vendor/", "test/", filter: /\.(js|coffee|css|sass|scss)$/
      listener.change &proc
      trap :INT do
        Linner::Notifier.exit
        exit!
      end
      listener.start!
    end

    desc "clean", "clean assets"
    def clean
      FileUtils.rm_rf File.join(Linner.environment.public_folder, "/.")
    end
  end
end


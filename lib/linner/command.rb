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

    desc "check", "check dependencies"
    def check
      message = Linner::Bundler.new(env.bundles).check
      puts (message.first ? "🍵 :" : "👻 :") + message.last
    end

    desc "install", "install dependencies"
    def install
      begin
        Linner::Bundler.new(env.bundles).perform
      rescue
        puts "👻 : Install failed!"
        puts $!
        return
      end
      puts "🍵 : Perfect installed all bundles!"
    end

    desc "build", "build assets"
    def build
      Linner.compile = true
      clean
      Linner::Bundler.new(env.bundles).perform
      perform
    end

    desc "watch", "watch assets"
    def watch
      trap(:INT) { exit! }
      clean
      Linner::Bundler.new(env.bundles).perform
      perform
      watch_for_perform
      watch_for_reload
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

    def perform
      begin
        Notifier.profile do
          Linner.perform
        end
      rescue
        Notifier.error $!
      end
    end

    def watch_for_perform
      Listen.to env.watched_paths do |modified, added, removed|
        Linner.cache.expire_by(modified + added + removed)
        perform
      end
    end

    def watch_for_reload
      reactor = Reactor.supervise_as(:reactor).actors.first
      Listen.to env.public_folder, relative_path: true do |modified, added, removed|
        reactor.reload_browser(modified + added + removed)
      end
    end

    def exit!
      Notifier.exit
      Kernel::exit
    end
  end
end


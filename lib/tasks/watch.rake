require "listen"
require_relative "../linner"

desc "watch assets"
task :watch do
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

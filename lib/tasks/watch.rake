require "listen"
require_relative "../linner"

desc "watch assets"
task :watch do
  proc = Proc.new do |modified, added, removed|
    begin
      Linner::Notifier.notify{ Linner.perform }
    rescue
      Linner::Notifier.error $!
    end
  end
  proc.call
  listener = Listen.to "app/", "vendor/", "test/", filter: /\.(js|coffee|css|sass|scss)$/
  listener.change &proc
  listener.start!
end

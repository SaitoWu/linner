require "listen"
require_relative "../linner"

desc "watch assets"
task :watch do
  Listen.to! "app/", "vendor/", "test/", filter: /\.(js|coffee|css|sass|scss)$/ do |modified, added, removed|
    begin
      Linner::Notifier.notify{ Linner.perform }
    rescue
      Linner::Notifier.error $!
    end
  end
end

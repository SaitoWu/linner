require_relative "../linner"

desc "watch assets"
task :watch do
  Linner::Notifier.notify do
    Linner.perform
  end
end

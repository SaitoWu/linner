require_relative "../linner"

desc "build assets"
task :build do
  Linner::Notifier.info do
    Linner.perform compile: true
  end
end

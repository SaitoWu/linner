desc "clean assets"
task :clean do
  FileUtils.rm_rf File.join(Linner.environment.public_folder, "/.")
end

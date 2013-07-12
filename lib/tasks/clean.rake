desc "clean assets"
task :clean do
  FileUtils.rm_rf File.join(Linner.config.public_folder, "/.")
end

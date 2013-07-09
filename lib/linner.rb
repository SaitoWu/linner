require "pp"
require "yaml"
require "tilt"
require "fileutils"

def root
  File.expand_path "..", File.dirname(__FILE__)
end

def config
  YAML::load File.read(File.join root, "config.yml")
end

def skip_extnames
  %w[.js .css .hbs]
end

def prepare_dir(path)
  file = File.dirname(path)
  unless File.directory? file
    FileUtils.mkdir_p file
  end
end

def render_to(file, join_path)
  if skip_extnames.include? File.extname(join_path)
    file.write File.read join_path
  else
    template = Tilt.new join_path
    file.write(template.render)
  end
end

release_folder = config["paths"]["public"] || "public"
scripts = config["files"]["scripts"]
# styles_folder = config["files"]["styles"]

scripts["join"].each do |path, regex|
  script = File.join(root, release_folder, path)

  prepare_dir script

  File.open script, "w+" do |f|
    Dir.glob(File.join root, regex) do |s|
      render_to f, s
    end
  end
end

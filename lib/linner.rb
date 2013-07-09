require "pp"
require "yaml"
require "tilt"
require "fileutils"

def wrapper
  '%s.define({%s:' +
    'function(exports, require, module){' +
    '%s' +
    ";}});\n"
end

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
  file = File.dirname path
  unless File.directory? file
    FileUtils.mkdir_p file
  end
end

def render_to(file, join_path)
  content = nil
  if skip_extnames.include? File.extname(join_path)
    content =  File.read join_path
  else
    template = Tilt.new join_path
    content =  template.render
  end
  if not join_path.include? File.join(root, "vendor")
    content = wrap_to_module(File.basename(join_path, File.extname(join_path)), content)
  end
  file.write content
end

def wrap_to_module(name, data)
  wrapper % ["this.require", name, data]
end

release_folder = config["paths"]["public"] || "public"
scripts = config["files"]["scripts"]
# styles_folder = config["files"]["styles"]

time = Time.now

scripts["join"].each do |path, regex|
  script_path = File.join(root, release_folder, path)

  prepare_dir script_path

  File.open script_path, "w+" do |f|
    Dir.glob(File.join root, regex) do |s|
      render_to f, s
    end
  end
end

pp ('%.3f' % (Time.now - time))

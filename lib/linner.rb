require "pp"
require "yaml"
require "tilt"
require "uglifier"
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

def is_scripts?(file_path)
  !!(file_path =~ /\.(coffee|js)/)
end

def render_to(file, join_path)
  content = nil
  if skip_extnames.include? File.extname(join_path)
    content =  File.read join_path
  else
    template = Tilt.new join_path
    content =  template.render
  end
  if !join_path.include?(File.join(root, "vendor")) and is_scripts?(join_path)
    content = wrap_to_module(File.basename(join_path, File.extname(join_path)), content)
  end
  # compile source
  # file.write = Uglifier.compile(content, comments: "none")
  file.write content
end

def wrap_to_module(name, data)
  wrapper % ["window.require", name, data]
end

release_folder = config["paths"]["public"] || "public"

time = Time.now

config["files"].each do |type|
  type["join"].each do |path, regex|
    file_path = File.join(root, release_folder, path)

    prepare_dir file_path

    File.open file_path, "w+" do |f|
      Dir.glob(File.join root, regex) do |s|
        render_to f, s
      end
    end
  end
end

pp ('%.3f' % (Time.now - time))

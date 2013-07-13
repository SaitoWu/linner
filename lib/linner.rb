require_relative "linner/helper"
require_relative "linner/config"
require_relative "linner/wrapper"
require_relative "linner/template"
require_relative "linner/notifier"
require_relative "linner/compressor"

include Linner::Helper

module Linner
  extend self
  include Linner::Helper

  def config
    @config ||= Linner::Config.new("config.yml")
  end

  def concat(type_config, options)
    concated_list = {}
    type = options[:type]
    compile = options[:compile] || false
    concat, before, after = config.extract_by(type_config)
    concat.each do |path, regex|
      content = ""
      file = File.join(root, config.public_folder, path)
      matches = Dir.glob(File.join root, regex)
      sort(matches, before: before, after: after).each do |s|
        content << Linner::Template.new(s).render
      end
      concated_list[file] = if compile
        Linner::Compressor.compress(type, content)
      else
        content
      end
    end
    concated_list
  end

  def write(file, content)
    FileUtils.mkdir_p File.dirname(file)
    File.open file, "w+" do |f|
      f.write content
    end
  end

  def perform(**options)
    config.files.each do |type, config|
      options[:type] = type
      Thread.new do
        concat(config, options).each {|path, content| write(path, content)}
      end.join
    end
  end
end


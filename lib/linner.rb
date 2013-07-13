require_relative "linner/helper"
require_relative "linner/asset"
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
      file = File.join(root, config.public_folder, path)
      concated_asset = Linner::Asset.new(file)
      matches = Dir.glob(File.join root, regex)
      sort(matches, before: before, after: after).each do |s|
        asset = Linner::Asset.new(s)
        content = asset.content
        if asset.wrappable?
          content = asset.wrap
        end
        concated_asset.content << content
      end
      # compile styles and scripts
      concated_list[file] = if compile
        concated_asset.compress
      else
        concated_asset.content
      end
    end
    concated_list
  end

  def copy(type_config)

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


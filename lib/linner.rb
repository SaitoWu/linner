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

  def concat_by(type_config)
    concated_list = {}
    concat, before, after = config.extract_by(type_config)
    concat.each do |path, regex|
      file = File.join(root, config.public_folder, path)
      content = ""
      matches = Dir.glob(File.join root, regex)
      sort(matches, before: before, after: after).each do |s|
        content << Linner::Template.new(s).render
      end
      concated_list[file] = content
    end
    concated_list
  end

  def perform compile: false
    config.files.each do |t, c|
      Thread.new do
        concat_by(c).each do |path, content|
          FileUtils.mkdir_p File.dirname(path)
          File.open path, "w+" do |f|
            content = Linner::Compressor.compress t, content if compile
            f.write content
          end
        end
      end.join
    end
  end

end


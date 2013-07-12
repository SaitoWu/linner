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

  def concat_by(type)
    concatenation, before, after = config.extract_by(type)
    concatenation.each do |path, regex|
      file = File.join(root, config.public_folder, path)
      FileUtils.mkdir_p File.dirname(file)
      File.open file, "w+" do |f|
        matches = Dir.glob(File.join root, regex)
        sort(matches, before: before, after: after).each do |s|
          Linner::Template.new(s).render_to(f)
        end
      end
    end
  end

  def perform compile: false
    config.files.each { |type| Thread.new { concat_by type }.join }
  end
end

Linner::Notifier.notify do
  Linner.perform
end


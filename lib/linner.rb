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

  def concat(config)
    assets = []
    concat, before, after = @config.extract_by(config)
    concat.each do |path, regex|
      concated_asset = Linner::Asset.new(File.join root, @config.public_folder, path)
      matches = Dir.glob(File.join root, regex)
      sort(matches, before: before, after: after).each do |s|
        asset = Linner::Asset.new(s)
        content = asset.content
        if asset.wrappable?
          content = asset.wrap
        end
        concated_asset.content << content
      end
      assets << concated_asset
    end
    assets
  end

  def copy(config)

  end

  def perform(**options)
    compile = options[:compile]
    config.files.values.each do |config|
      Thread.new do
        concat(config).each {|asset| asset.compress if compile; asset.write}
      end.join
    end
  end
end


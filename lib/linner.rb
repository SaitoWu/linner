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

  def concat(config)
    assets = []
    concat, before, after = @config.extract_by(config)
    concat.each do |dist, regex|
      Thread.new do
        concated_asset = Linner::Asset.new(File.join root, @config.public_folder, dist)
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
      end.join
    end
    assets
  end

  def copy(config)
    config["copy"].to_h.each do |dist, regex|
      Thread.new do
        matches = Dir.glob(File.join root, regex)
        matches.each do |path|
          asset = Linner::Asset.new(path)
          asset.path = File.join(root, @config.public_folder, dist, asset.logical_path)
          next if File.exist? asset.path and FileUtils.identical? path, asset.path
          asset.write
        end
      end.join
    end
  end

  def perform(**options)
    compile = options[:compile]
    config.files.values.each do |config|
      Thread.new {concat(config).each {|asset| asset.compress if compile; asset.write}}.join
      Thread.new {copy(config)}.join
    end
  end
end

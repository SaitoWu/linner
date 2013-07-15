require "linner/version"
require "linner/command"
require "linner/asset"
require "linner/sort"
require "linner/environment"
require "linner/wrapper"
require "linner/template"
require "linner/notifier"
require "linner/compressor"

module Linner
  extend self

  def root
    @root ||= Pathname('.').expand_path
  end

  def environment
    @env ||= Linner::Environment.new root.join("config.yml")
  end

  def perform(compile: false)
    environment.files.values.each do |config|
      Thread.new {concat(config).each {|asset| asset.compress if compile; asset.write}}.join
      Thread.new {copy(config)}.join
    end
  end

  private
  def concat(config)
    assets = []
    concat, before, after = environment.extract_by(config)
    concat.each do |dist, regex|
      Thread.new do
        dist = Linner::Asset.new(environment.public_folder.join(dist).to_path)
        matches = Dir.glob(File.join root, regex).uniq
        matches.extend(Linner::Sort)
        matches.sort(before: before, after: after).each do |m|
          asset = Linner::Asset.new(m)
          content = asset.content
          if asset.wrappable?
            content = asset.wrap
          end
          dist.content << content
        end
        assets << dist
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
          asset.path = File.join(environment.public_folder, dist, asset.logical_path)
          next if File.exist? asset.path and FileUtils.uptodate? path, [asset.path]
          asset.write
        end
      end.join
    end
  end
end

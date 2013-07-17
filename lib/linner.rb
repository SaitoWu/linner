require "linner/version"
require "linner/command"
require "linner/asset"
require "linner/helper"
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
    @env ||= Environment.new root.join("config.yml")
  end

  def perform(compile: false)
    environment.files.each do |config|
      Thread.new {concat(config).each {|asset| asset.compress if compile; asset.write}}.join
      Thread.new {copy(config)}.join
    end
  end

  private
  def concat(config)
    assets = []
    config["concat"].each do |dist, regex|
      Thread.new do
        dist = Asset.new(File.join environment.public_folder, dist)
        dist.content = ""
        matches = Dir.glob(File.join root, regex).uniq
        matches.sort_by_before_and_after(config["order"]["before"], config["order"]["after"]).each do |m|
          asset = Asset.new(m)
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
    config["copy"].each do |dist, regex|
      Thread.new do
        matches = Dir.glob(File.join root, regex)
        matches.each do |path|
          asset = Asset.new(path)
          asset.path = File.join(environment.public_folder, dist, asset.logical_path)
          next if File.exist?(asset.path) and File.identical?(path, asset.path)
          asset.write
        end
      end.join
    end
  end
end

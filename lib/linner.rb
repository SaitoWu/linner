require "linner/version"
require "linner/command"
require "linner/asset"
require "linner/helper"
require "linner/wrapper"
require "linner/template"
require "linner/notifier"
require "linner/compressor"
require "linner/environment"

module Linner
  extend self

  def root
    @root ||= Pathname('.').expand_path
  end

  def cache
    @cache ||= {}
  end

  def environment
    @env ||= Environment.new root.join("config.yml")
  end

  def perform(compile: false)
    environment.files.each do |config|
      concat(config, compile)
      copy(config)
    end
  end

  private
  def concat(config, compile)
    config["concat"].map do |dest, regex|
      matches = Dir.glob(regex).order_by(config["order"])
      dest = Asset.new(File.join environment.public_folder, dest)
      dest.content = ""
      cached = matches.select do |path|
        mtime = File.mtime(path).to_i
        mtime == cache[path] ? false : cache[path] = mtime
      end
      next if cached.empty?
      matches.each do |m|
        asset = Asset.new(m)
        content = asset.content
        if asset.wrappable?
          content = asset.wrap
        end
        dest.content << content
      end
      dest.compress if compile
      dest.write
    end
  end

  def copy(config)
    config["copy"].each do |dest, regex|
      Dir.glob(regex).each do |path|
        mtime = File.mtime(path).to_i
        next if cache[path] == mtime
        cache[path] = mtime
        logical_path = Asset.new(path).logical_path
        dest_path = File.join(environment.public_folder, dest, logical_path)
        FileUtils.mkdir_p File.dirname(dest_path)
        FileUtils.cp_r path, dest_path
      end
    end
  end
end

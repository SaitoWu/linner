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
      concat(config).each {|asset| asset.compress if compile; asset.write}
      copy(config)
    end
  end

  private
  def concat(config)
    config["concat"].map do |dest, regex|
      dest = Asset.new(File.join environment.public_folder, dest)
      dest.content = ""
      Dir.glob(regex).uniq.sort_by_before_and_after(config["order"]["before"], config["order"]["after"]).each do |m|
        asset = Asset.new(m)
        content = asset.content
        if asset.wrappable?
          content = asset.wrap
        end
        dest.content << content
      end
      dest
    end
  end

  def copy(config)
    config["copy"].each do |dest, regex|
      Dir.glob(regex).each do |path|
        mtime = File.mtime(path).to_i
        if cache[path]
          next if mtime == cache[path]
        else
          cache[path] = mtime
        end
        logical_path = Asset.new(path).logical_path
        dest_path = File.join(environment.public_folder, dest, logical_path)
        FileUtils.mkdir_p File.dirname(dest_path)
        FileUtils.cp_r path, dest_path
      end
    end
  end
end

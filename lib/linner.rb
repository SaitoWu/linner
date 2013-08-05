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

  def env
    @env ||= Environment.new root.join("config.yml")
  end

  def perform(compile: false)
    env.groups.each do |config|
      concat(config, compile) if config["concat"]
      copy(config) if config["copy"]
    end
  end

  private
  def concat(config, compile)
    config["concat"].each_with_index do |pair, index|
      dest, pattern, order = pair.first, pair.last, config["order"]||[]
      matches = Dir.glob(pattern).order_by(order)
      next if matches.select {|p| cache_miss? p}.empty?
      dest = Asset.new(File.join env.public_folder, dest)
      definition = Wrapper.definition if dest.path == env.definition
      dest.content = matches.inject(definition || "") {|s, m| s << Asset.new(m).content}
      dest.compress if compile
      dest.write
    end
  end

  def copy(config)
    config["copy"].each do |dest, pattern|
      Dir.glob(pattern).each do |path|
        next if not cache_miss?(path)
        logical_path = Asset.new(path).logical_path
        dest_path = File.join(env.public_folder, dest, logical_path)
        FileUtils.mkdir_p File.dirname(dest_path)
        FileUtils.cp_r path, dest_path
      end
    end
  end

  def cache_miss?(path)
    mtime = Asset.new(path).mtime
    cache[path] == mtime ? false : cache[path] = mtime
  end
end

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

  attr_accessor :compile

  def root
    @root ||= Pathname('.').expand_path
  end

  def cache
    @cache ||= {}
  end

  def env
    @env ||= Environment.new root.join("config.yml")
  end

  def compile?
    @compile
  end

  def sass_engine_options
    @options ||= Compass.configuration.to_sass_engine_options
    env.paths.each do |load_path|
      @options[:load_paths] << Sass::Importers::Filesystem.new(load_path)
    end
    @options
  end

  def perform(*asset)
    env.groups.each do |config|
      concat(config) if config["concat"]
      copy(config) if config["copy"]
    end
  end

private
  def concat(config)
    config["concat"].each_with_index do |pair, index|
      dest, pattern, order = pair.first, pair.last, config["order"]||[]
      matches = Dir.glob(pattern).order_by(order)
      next if matches.select {|p| cache_miss? p}.empty?
      dest = Asset.new(File.join env.public_folder, dest)
      definition = Wrapper.definition if dest.path == env.definition
      dest.content = matches.inject(definition || "") {|s, m| s << cache[m].content}
      dest.compress if compile?
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
    asset = Asset.new(path)
    if asset.stylesheet? and Tilt[path] != Tilt::CSSTemplate
      partials = Sass::Engine.for_file(path, sass_engine_options).dependencies.map{|m| m.options[:filename]}
      cache_missed = partials.select do |partial|
        partial_asset = Asset.new(partial)
        (cache[partial] and cache[partial].mtime == partial_asset.mtime) ? false : cache[partial] = partial_asset
      end
      unless cache_missed.empty?
        cache[path] = asset
        return true
      end
    end
    (cache[path] and cache[path].mtime == asset.mtime) ? false : cache[path] = asset
  end
end

require "nokogiri"

require "linner/version"
require "linner/command"
require "linner/asset"
require "linner/helper"
require "linner/reactor"
require "linner/wrapper"
require "linner/template"
require "linner/notifier"
require "linner/compressor"
require "linner/environment"

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

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
    @options ||= begin
      options = Compass.configuration.to_sass_engine_options
      env.paths.each do |load_path|
        options[:load_paths] << Sass::Importers::Filesystem.new(load_path)
      end
      options
    end
  end

  def perform(*asset)
    env.groups.each do |config|
      copy(config) if config["copy"]
      concat(config) if config["concat"]
    end
    revision if compile? and env.revision
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

  def revision
    revision = File.join env.public_folder, env.revision
    doc = Nokogiri::HTML.parse(File.read revision)
    doc.search("script").each do |x|
      next unless src = x.attributes["src"]
      asset = Asset.new(File.join env.public_folder, src)
      x.set_attribute "src", asset.revision!
    end
    doc.search("link").each do |x|
      next unless href = x.attributes["href"]
      asset = Asset.new(File.join env.public_folder, href)
      x.set_attribute "href", asset.revision!
    end
    File.open(revision, "w") do |f|
      f.write doc.to_html
    end
  end

  def cache_miss?(path)
    asset = Asset.new(path)
    if cache[path] and cache[path].mtime == asset.mtime
      false
    else
      cache[path] = asset
    end
  end
end

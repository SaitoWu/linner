require "linner/version"
require "linner/command"
require "linner/asset"
require "linner/cache"
require "linner/helper"
require "linner/sprite"
require "linner/bundler"
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

  attr_accessor :env, :compile

  def root
    @root ||= Pathname('.').realpath
  end

  def config_file
    linner_file = root.join("Linnerfile")
    config_file = root.join("config.yml")
    File.exist?(linner_file) ? linner_file : config_file
  end

  def env
    @env ||= Environment.new config_file
  end

  def cache
    @cache ||= Cache.new
  end

  def manifest
    @manifest ||= begin
      hash = {}
      copy_assets = []
      concat_assets = []
      template_assets = []
      sprite_assets = []
      env.groups.each do |config|
        concat_assets << config["concat"].keys if config["concat"]
        template_assets << config["template"].keys if config["template"]
        sprite_assets << config["sprite"].keys if config["sprite"]
        config["copy"].each do |dest, pattern|
          copy_assets << Dir.glob(pattern).map do |path|
            logical_path = Asset.new(path).logical_path
            dest_path = File.join(dest, logical_path)
          end
        end if config["copy"]
      end

      # revision sprite assets
      sprite_assets.flatten.each do |dest|
        name = File.basename(dest).sub /[^.]+\z/, "png"
        dest = File.join env.sprites["path"], name
        asset = Asset.new(File.join env.public_folder, dest)
        hash[dest] = asset.relative_digest_path
        asset.revision!

        (concat_assets + copy_assets).flatten.each do |file|
          path = File.join env.public_folder, file
          next unless Asset.new(path).stylesheet?
          puts = File.read(path).gsub(File.join(env.sprites["url"], File.basename(dest)), File.join(env.sprites["url"], File.basename(asset.relative_digest_path)))
          File.open(path, "w") { |file| file << puts }
        end
      end

      # revision concat template and copy assets
      (concat_assets + template_assets + copy_assets).flatten.each do |dest|
        asset = Asset.new(File.join env.public_folder, dest)
        next unless asset.revable?
        hash[dest] = asset.relative_digest_path
        asset.revision!
      end

      hash
    end
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
      precompile(config) if config["precompile"]
      sprite(config) if config["sprite"]
    end
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
      matches = Dir.glob(pattern).sort_by(&:downcase).order_by(order)
      next if matches.select {|path| cache.miss?(dest, path)}.empty?
      write_asset(dest, matches)
    end
  end

  def copy(config)
    config["copy"].each do |dest, pattern|
      Dir.glob(pattern).each do |path|
        next if not cache.miss?(dest, path)
        asset = Asset.new(path)
        dest_path = File.join(env.public_folder, dest, asset.logical_path)
        if asset.javascript? or asset.stylesheet?
          asset.content
          asset.compress if compile?
          dest_path = dest_path.sub(/[^.]+\z/,"js") if asset.javascript?
          dest_path = dest_path.sub(/[^.]+\z/,"css") if asset.stylesheet?
          asset.path = dest_path
          asset.write
        else
          FileUtils.mkdir_p File.dirname(dest_path)
          FileUtils.cp_r path, dest_path
        end
      end
    end
  end

  def precompile(config)
    config["precompile"].each do |dest, pattern|
      matches = Dir.glob(pattern).sort_by(&:downcase)
      next if matches.select { |path| cache.miss?(dest, path) }.empty?
      write_template(dest, matches)
    end
  end

  def sprite(config)
    config["sprite"].each do |dest, pattern|
      matches = Dir.glob(pattern).sort_by(&:downcase)
      next if matches.select { |path| cache.miss?(dest, path) }.empty?
      paint_sprite(dest, matches)
    end
  end

  def revision
    dump_manifest
    [env.revision].flatten.each do |rev|
      file = File.join env.public_folder, rev.to_s
      next if not File.exist?(file)
      replace_attributes file
    end
  end

  def paint_sprite(dest, images)
    images = images.map do |path|
      ImageProxy.new(path, ChunkyPNG::Image.from_file(path))
    end
    sprite = Sprite.new(images).pack!
    map = ChunkyPNG::Image.new(sprite.root[:w], sprite.root[:h], ChunkyPNG::Color::TRANSPARENT)

    sprite.images.each do |image|
      map.compose!(image.image, image.left, image.top)
    end

    name = File.basename(dest).sub(/[^.]+\z/, "png")
    path = File.join(env.public_folder, env.sprites["path"], name)
    FileUtils.mkdir_p File.dirname(path)
    map.save path

    asset = Asset.new(File.join env.public_folder, dest)
    asset.content = sprite.generate_style(env.sprites, name)
    asset.write
  end

  def write_template(dest, child_assets)
    asset = Asset.new(File.join env.public_folder, dest)
    content = child_assets.inject("") {|s, m| s << cache["#{dest}:#{m}"].content}
    asset.content = Wrapper::Template.definition(content)
    asset.compress if compile?
    asset.write
  end

  def write_asset(dest, child_assets)
    asset = Asset.new(File.join env.public_folder, dest)
    definition = (asset.path == env.definition ? Wrapper::Module.definition : "")
    asset.content = child_assets.inject(definition) {|s, m| s << cache["#{dest}:#{m}"].content}
    asset.compress if compile?
    asset.write
  end

  def replace_attributes file
    doc = File.read file
    doc.gsub!(/(<script.+src=['"])([^"']+)(["'])/) do |m|
      if p = manifest[$2] then $1 << p << $3 else m end
    end

    doc.gsub!(/(<link[^\>]+href=['"])([^"']+)(["'])/) do |m|
      if p = manifest[$2] then $1 << p << $3 else m end
    end

    File.open(file, "w") {|f| f.write doc}
  end

  def dump_manifest
    File.open(File.join(env.public_folder, env.manifest), "w") do |f|
      YAML.dump(manifest, f)
    end
  end
end

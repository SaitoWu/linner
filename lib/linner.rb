require "linner/version"
require "linner/command"
require "linner/asset"
require "linner/cache"
require "linner/helper"
require "linner/sprite"
require "linner/archive"
require "linner/bundler"
require "linner/reactor"
require "linner/wrapper"
require "linner/template"
require "linner/notifier"
require "linner/compressor"
require "linner/environment"

module Linner
  extend self

  attr_accessor :env, :compile, :strict

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
      cdn = env.revision["cdn"] || ""
      prefix = env.revision["prefix"] || ""

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
        hash[prefix + dest] = cdn + prefix + asset.relative_digest_path
        asset.revision!

        (concat_assets + copy_assets).flatten.each do |file|
          path = File.join env.public_folder, file
          next unless Asset.new(path).stylesheet?
          url = env.sprites["url"] || env.sprites["path"]
          puts = File.read(path).gsub(File.join(url, File.basename(dest)), File.join(cdn, url, File.basename(asset.relative_digest_path)))
          File.open(path, "w") { |file| file << puts }
        end
      end

      # revision concat template and copy assets
      (concat_assets + template_assets + copy_assets).flatten.each do |dest|
        asset = Asset.new(File.join env.public_folder, dest)
        next unless asset.revable?
        hash[prefix + dest] = cdn + prefix + asset.relative_digest_path
        asset.revision!
      end

      hash
    end
  end

  def compile?
    @compile
  end

  def strict?
    @strict
  end

  def perform(*asset)
    env.groups.each do |config|
      precompile(config) if config["precompile"]
      sprite(config) if config["sprite"]
    end
    env.groups.each do |config|
      copy(config) if config["copy"]
      compile(config) if config["compile"]
      concat(config) if config["concat"]
    end
    env.groups.each do |config|
      tar(config) if config["tar"]
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
        asset = Asset.new(path)
        dest_path = File.join(env.public_folder, dest, asset.logical_path)
        FileUtils.mkdir_p File.dirname(dest_path)
        FileUtils.cp_r path, dest_path
      end
    end
  end

  def compile(config)
    config["compile"].each do |dest, pattern|
      Dir.glob(pattern).each do |path|
        next if not cache.miss?(dest, path)
        asset = Asset.new(path)
        dest_path = File.join(env.public_folder, dest, asset.logical_path)
        if asset.javascript? or asset.stylesheet?
          asset.content
          asset.compress if compile?
          dest_path = dest_path.sub(/[^.]+\z/, "js") if asset.javascript?
          dest_path = dest_path.sub(/[^.]+\z/, "css") if asset.stylesheet?
          asset.path = dest_path
          asset.write
        elsif asset.eruby?
          base, ext = path.split(".")
          dest_path = if ext == "erb"
            dest_path.sub(/[.]+\z/, "html")
          else
            dest_path.gsub(File.basename(dest_path), File.basename(dest_path, File.extname(dest_path)))
          end
          asset.content(config["context"])
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

  def tar(config)
    config["tar"].each do |dest, pattern|
      path = File.join(env.public_folder, dest)
      FileUtils.mkdir_p File.dirname(path)
      Archive.tar(pattern, path)
    end
  end

  def revision
    dump_manifest
    files = env.revision["files"] || []
    files.flatten.each do |rev|
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
    if strict?
      doc.gsub!(/(<script.+src=['"])([^"']+)(["'])/) do |m|
        if p = manifest[$2] then $1 << p << $3 else m end
      end

      doc.gsub!(/(<link[^\>]+href=['"])([^"']+)(["'])/) do |m|
        if p = manifest[$2] then $1 << p << $3 else m end
      end
    else
      manifest.each do |k, v|
        doc.gsub!(k, v)
      end
    end
    File.open(file, "w") {|f| f.write doc}
  end

  def dump_manifest
    manifest_file = env.revision["manifest"] || "manifest.yml"
    File.open(File.join(env.public_folder, manifest_file), "w") do |f|
      YAML.dump(manifest, f)
    end
  end
end

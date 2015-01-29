require "chunky_png"

module Linner
  ImageProxy = Struct.new(:path, :image, :top, :left) do
    def width
      image.width
    end

    def height
      image.height
    end
  end

  class Sprite

    attr_accessor :root, :images

    def initialize(images)
      @images = images.sort do |a, b|
        diff = [b.width, b.height].max <=> [a.width, a.height].max
        diff = [b.width, b.height].min <=> [a.width, a.height].min if diff.zero?
        diff = b.height <=> a.height if diff.zero?
        diff = b.width <=> a.width if diff.zero?
        diff
      end

      @root = { :x => 0, :y => 0, :w => @images.first.width, :h => @images.first.height}
    end

    def pack!
      @images.each do |image|
        if block = find_block(@root, image)
          place_image(block, image)
          split_block(block, image)
        else
          @root = expand_root(@root, image)
          redo
        end
      end
      self
    end

    def generate_style(config, name)
      selector = config["selector"] || ".icon-"
      url = config['url'] || config['path']
      @images.inject("") do |style, image|
        logical_path = Asset.new(image.path).logical_path
        selector_with_pseudo_class = logical_path.chomp(File.extname(logical_path))
          .gsub("/", "-")
          .gsub("_active", ".active")
          .gsub("_hover", ":hover")
          .gsub("_", "-")
        style <<
"#{selector}#{selector_with_pseudo_class} {
  width: #{image.width}px;
  height: #{image.height}px;
  background: url(#{File.join url, name}) -#{image.left}px -#{image.top}px no-repeat;
}
"
      end
    end

    private
    def find_block(root, image)
      if root[:used]
        find_block(root[:right], image) || find_block(root[:down], image)
      elsif (image.width <= root[:w]) && (image.height <= root[:h])
        root
      end
    end

    def place_image(block, image)
      image.top = block[:y]
      image.left = block[:x]
    end

    def split_block(block, image)
      block[:used] = true
      block[:down] = {:x => block[:x], :y => block[:y] + image.height, :w => block[:w], :h => block[:h] - image.height}
      block[:right] = {:x => block[:x] + image.width, :y => block[:y], :w => block[:w] - image.width, :h => image.height}
    end

    def expand_root(root, image)
      can_expand_down  = (image.width <= root[:w])
      can_expand_right = (image.height <= root[:h])

      should_expand_down  = can_expand_down  && (root[:w] >= (root[:h] + image.height))
      should_expand_right = can_expand_right && (root[:h] >= (root[:w] + image.width))

      if should_expand_right
        expand_right(root, image.width)
      elsif should_expand_down
        expand_down(root, image.height)
      elsif can_expand_right
        expand_right(root, image.width)
      elsif can_expand_down
        expand_down(root, image.height)
      else
        raise RuntimeError, "Crashed!"
      end
    end

    def expand_right(root, width)
      Hash[
        :used  => true,
        :x     => 0,
        :y     => 0,
        :w     => root[:w] + width,
        :h     => root[:h],
        :down  => root,
        :right => { :x => root[:w], :y => 0, :w => width, :h => root[:h] }
      ]
    end

    def expand_down(root, height)
      Hash[
        :used  => true,
        :x     => 0,
        :y     => 0,
        :w     => root[:w],
        :h     => root[:h] + height,
        :down  => { :x => 0, :y => root[:h], :w => root[:w], :h => height },
        :right => root
      ]
    end
  end # Sprite
end # Linner

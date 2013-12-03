require "pry"

module Linner
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
      block[:down] = {:x => block[:x], :y => block[:y] + image.width, :w => block[:w], :h => block[:h] - image.height}
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

require "spec_helper"

describe Sprite do
  before(:all) do
    MockImage = Struct.new :width, :height, :top, :left
    @sprites = Environment.new(root.join "config.yml").sprites
    image0 = MockImage.new 2, 3
    image1 = MockImage.new 5, 3
    image2 = MockImage.new 6, 2
    image3 = MockImage.new 2, 24
    image4 = MockImage.new 1, 3
    @images = [image0, image1, image2, image3, image4]
  end

  it "should be an empty hash" do
    expect(@sprites).to eq(Hash.new)
  end

  it "should be fit in blocks" do
    sprites = Sprite.new(@images)
    sprites.pack!
  end
end

require "spec_helper"

describe Bundler do
  before(:each) do
    env = Environment.new(root.join "config.yml")
    @bundler = Linner::Bundler.new(env)
  end

  it "should check failure when REPOSITORY is not exist" do
    clear
    expect(@bundler.check).to eq [false, "Bundles didn't exsit!"]
  end

  it "should check failure when jquery is not exist" do
    FileUtils.mkdir_p File.expand_path("~/.linner/bundles")
    expect(@bundler.check).to eq [false, "Bundle jquery v1.10.2 didn't match!"]
  end

  after(:each) do
    clear
  end

  def clear
    FileUtils.rm_rf File.expand_path("~/.linner")
  end
end

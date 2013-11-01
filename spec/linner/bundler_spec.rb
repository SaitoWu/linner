require "spec_helper"

describe Bundler do
  before(:each) do
    bundles = Environment.new(root.join "config.yml").bundles
    @bundler = Bundler.new(bundles)
  end

  it "should check failure when REPOSITORY is not exist" do
    clear
    @bundler.check.should == [false, "Bundles didn't exsit!"]
  end

  it "should check failure when jquery is not exist" do
    FileUtils.mkdir_p File.expand_path("~/.linner/bundles")
    @bundler.check.should == [false, "Bundle jquery v1.10.2 didn't match!"]
  end

  after(:each) do
    clear
  end

  def clear
    FileUtils.rm_rf File.expand_path("~/.linner")
  end
end

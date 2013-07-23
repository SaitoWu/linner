require "spec_helper"

describe Asset do

  before(:each) do
    @asset = Asset.new("app/scripts/app.js")
  end

  describe :logical_path do
    it "should be return right logical_path" do
      @asset.logical_path.should == "app.js"
    end
  end

  describe :wrappable do
    it "should wrapperable" do
      @asset.wrappable?.should be_true
      Asset.new("app/styles/app.css").wrappable?.should be_false
    end
  end
end

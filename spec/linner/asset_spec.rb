require "spec_helper"

describe Asset do

  before(:each) do
    @script_asset = Asset.new("app/scripts/app.js")
    @style_asset = Asset.new("app/styles/app.css")
    @dest_asset = Asset.new("public/app.js")
  end

  it "should return right logical_path" do
    @script_asset.logical_path.should == "app.js"
    @style_asset.logical_path.should == "app.css"
  end

  it "should return right digest_path" do
    @dest_asset.digest_path.should == "public/app-cdd1c27fabeede75d12b8adf46e987fd.js"
    @dest_asset.relative_digest_path.should == "/app-cdd1c27fabeede75d12b8adf46e987fd.js"
  end

  it "should be javascript" do
    @script_asset.javascript?.should be_true
    @style_asset.stylesheet?.should be_true
  end

  it "should wrapperable" do
    @script_asset.wrappable?.should be_true
    @style_asset.wrappable?.should be_false
  end
end

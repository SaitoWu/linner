require "spec_helper"

describe Asset do
  def new_asset path
    Asset.new path
  end

  before(:each) do
    @script_asset = new_asset "app/scripts/app.js"
    @style_asset  = new_asset "app/styles/app.css"
    @dest_asset   = new_asset "public/app.js"
  end

  it "should return right logical_path" do
    expect(@script_asset.logical_path).to eq "app.js"
    expect(@style_asset.logical_path).to  eq "app.css"
  end

  it "should return right digest_path" do
    expect(@dest_asset.digest_path).to eq "public/app-7fa4c57f63cf67c15299ee2c79be22e0.js"
    expect(@dest_asset.relative_digest_path).to eq "/app-7fa4c57f63cf67c15299ee2c79be22e0.js"
  end

  it "should be javascript" do
    expect(@script_asset.javascript?).to be true
    expect(@style_asset.stylesheet?).to  be true
  end

  it "should wrapperable" do
    expect(@script_asset.wrappable?).to be true
    expect(@style_asset.wrappable?).to  be false
  end
end

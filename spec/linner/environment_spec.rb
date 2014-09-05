require "spec_helper"

describe Environment do
  before(:each) do
    @env = Environment.new(root.join "config.yml")
    @ary = ["app/scripts", "app/styles", "app/images", "app/views"]
  end

  it "should equals default path folder" do
    expect(@env.paths).to match @ary
    expect(@env.app_folder).to eq "app"
    expect(@env.test_folder).to eq "test"
    expect(@env.vendor_folder).to eq "vendor"
    expect(@env.public_folder).to eq "public"
  end

  it "should equals default config" do
    expect(@env.notification).to be true
    expect(@env.wrapper).to eq "cmd"
    expect(@env.groups).to respond_to(:each)
  end
end

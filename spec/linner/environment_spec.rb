require "spec_helper"

describe Environment do
  before(:each) do
    @env = Environment.new(root.join "config.yml")
    @ary = ["app/scripts", "app/styles", "app/images", "app/views"]
  end

  it "should equals default path folder" do
    @env.paths.should =~ @ary
    @env.app_folder.should == "app"
    @env.test_folder.should == "test"
    @env.vendor_folder.should == "vendor"
    @env.public_folder.should == "public"
  end

  it "should equals default config" do
    @env.notification.should be_true
    @env.wrapper.should == "cmd"
    @env.revision.should == "index.html"
    @env.groups.should respond_to(:each)
  end
end

require "spec_helper"

describe Environment do
  before(:each) do
    @env = Environment.new(root.join "config.yml")
  end

  describe "convension" do
    it "should equals default path folder" do
      @env.app_folder.should == root.join("app").to_path
      @env.test_folder.should == root.join("test").to_path
      @env.vendor_folder.should == root.join("vendor").to_path
      @env.public_folder.should == root.join("public").to_path
    end

    it "should equals default config" do
      @env.notification.should be_true
      @env.wrapper.should == "CMD"
      @env.files.should respond_to(:each)
    end

    it "should equals default before and after" do
      @env.files.each do |file|
        file["copy"].should respond_to(:each)
        file["concat"].should respond_to(:each)
        file["order"]["before"].should respond_to(:each)
        file["order"]["after"].should respond_to(:each)
      end
    end
  end
end

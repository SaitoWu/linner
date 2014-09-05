require "spec_helper"

describe Wrapper do
  before(:each) do
    @name = "app"
    @script = 'module.exports = function() {return console.log("log from app!");};'
    @expected_script = <<-DEFINITIONS
this.require.define({"app":function(exports, require, module){module.exports = function() {return console.log("log from app!");};;}});
DEFINITIONS
  end

  it "should wrapped by wrapper" do
    script = Wrapper::Module.wrap(@name, @script)
    expect(script).to eq @expected_script
  end

  it "should has definition" do
    expect(Wrapper::Module.definition).not_to be_nil
  end
end

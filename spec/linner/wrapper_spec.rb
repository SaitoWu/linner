require "spec_helper"

describe Wrapper do

  before(:each) do
    @name = "app"
    @script = 'module.exports = function() {return console.log("log from app!");};'
    @expected_script = 'this.require.define({"app":' +
      'function(exports, require, module){' +
      'module.exports = function() {' +
      'return console.log("log from app!");' +
      '};' +
      ";}});\n"
  end

  it "should wrapped by wrapper" do
    script = Wrapper.wrap(@name, @script)
    script.should eq @expected_script
  end

  it "should has definition" do
    Wrapper.definition.should_not be_nil
  end
end

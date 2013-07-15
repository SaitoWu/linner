require "spec_helper"

describe Linner::Wrapper do

  before(:each) do
    @name = "app"
    @script = 'module.exports = function() {return console.log("log from app!");};'
    @expected_script = 'window.require.define({"app":' +
      'function(exports, require, module){' +
      'module.exports = function() {' +
      'return console.log("log from app!");' +
      '};' +
      ";}});\n"
  end

  describe :wrap do
    it "should wrapped by wrapper" do
      script = Linner::Wrapper.wrap(@name, @script)
      script.should eq @expected_script
    end
  end
end

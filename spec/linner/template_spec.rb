require "spec_helper"

describe "Template" do

  it "should be javascript tempalate" do
    Tilt["app.js"].should == Tilt::JavascriptTemplate
  end

  it "should be css template" do
    Tilt["app.css"].should == Tilt::CSSTemplate
  end
end

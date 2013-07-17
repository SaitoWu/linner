require "spec_helper"

describe Template do

  describe :templates do

    it "should be javascript tempalate" do
      Tilt["app.js"].should == Tilt::JavascriptTemplate
    end

    it "should be css template" do
      Tilt["app.css"].should == Tilt::CSSTemplate
    end

    it "should tempalte for script" do
      Template.template_for_script? "app.js".should be_true
      Template.template_for_script? "app.coffee".should be_true
    end

    it "should tempalte for style" do
      Template.template_for_style? "app.css".should be_true
      Template.template_for_style? "app.sass".should be_true
      Template.template_for_style? "app.scss".should be_true
      Template.template_for_style? "app.styl".should be_true
    end
  end
end

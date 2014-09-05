require "spec_helper"

describe "Template" do
  it "should be javascript tempalate" do
    expect(Tilt["app.js"]).to eq Tilt::JavascriptTemplate
  end

  it "should be css template" do
    expect(Tilt["app.css"]).to eq Tilt::CSSTemplate
  end

  it "should be handlebars template" do
    expect(Tilt["app.hbs"]).to eq Tilt::HandlebarsTemplate
    expect(Tilt["app.handlebars"]).to eq Tilt::HandlebarsTemplate
  end
end

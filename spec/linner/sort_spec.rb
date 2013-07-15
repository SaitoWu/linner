require "spec_helper"

describe Linner::Sort do
  before(:each) do
    @array = %w[app.js jquery.js bootstrap.css reset.css vendor.js]
    @array.extend(Linner::Sort)
  end

  describe :sort do
    it "won't change when before and after are empty array" do
      @array.sort(before:[], after: []).should be_equal @array
    end

    it "will change by before items" do
      @array.sort(before: ["jquery.js", "vendor.js"])
      @array.should =~ %w[jquery.js vendor.js app.js bootstrap.css reset.css]
    end

    it "will change by after items" do
      @array.sort(after: ["reset.css", "bootstrap.css"])
      @array.should =~ %w[app.js jquery.js vendor.js reset.css bootstrap.css]
    end

    it "will change by before and after items" do
      @array.sort(before: ["jquery.js", "vendor.js"], after: ["reset.css", "bootstrap.css"])
      @array.should =~ %w[jquery.js vendor.js app.js reset.css bootstrap.css]
    end
  end
end

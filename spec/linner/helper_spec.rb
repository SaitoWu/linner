require "spec_helper"

describe Array do
  before(:each) do
    @array = %w[app.js jquery.js bootstrap.css reset.css vendor.js]
  end

  describe :sort do
    it "won't change when before and after are empty array" do
      @array.order_by(before:[], after:[]).should be_equal @array
    end

    it "will change by before items" do
      @array.order_by(before:["jquery.js", "vendor.js"], after:[])
      @array.should =~ %w[jquery.js vendor.js app.js bootstrap.css reset.css]
    end

    it "will change by after items" do
      @array.order_by(before:[], after:["reset.css", "bootstrap.css"])
      @array.should =~ %w[app.js jquery.js vendor.js reset.css bootstrap.css]
    end

    it "will change by before and after items" do
      @array.order_by(before:["jquery.js", "vendor.js"], after:["reset.css", "bootstrap.css"])
      @array.should =~ %w[jquery.js vendor.js app.js reset.css bootstrap.css]
    end
  end
end

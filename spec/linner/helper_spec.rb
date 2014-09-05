require "spec_helper"

describe Array do
  before(:each) do
    @array = %w[app.js jquery.js bootstrap.css reset.css vendor.js]
  end

  it "won't change when before and after are empty array" do
    expect(@array.order_by([])).to eq @array
  end

  it "will change by before items" do
    @array.order_by(["jquery.js", "vendor.js"])
    expect(@array).to eq %w[jquery.js vendor.js app.js bootstrap.css reset.css]
  end

  it "will change by after items" do
    @array.order_by(["...", "reset.css", "bootstrap.css"])
    expect(@array).to eq %w[app.js jquery.js vendor.js reset.css bootstrap.css]
  end

  it "will change by before and after items" do
    @array.order_by(["jquery.js", "vendor.js", "...", "reset.css", "bootstrap.css"])
    expect(@array).to eq %w[jquery.js vendor.js app.js reset.css bootstrap.css]
  end
end

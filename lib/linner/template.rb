require "tilt"
require "sass"
require "coffee_script"

module Tilt
  class JavascriptTemplate < PlainTemplate
    self.default_mime_type = 'application/javascript'
  end

  class CSSTemplate < PlainTemplate
    self.default_mime_type = 'text/css'
  end

  Tilt.register Tilt::CSSTemplate, "css"
  Tilt.register Tilt::JavascriptTemplate, "js"
end

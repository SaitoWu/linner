require "tilt"
require "sass"
require "compass"
require "coffee_script"

module Tilt
  class JavascriptTemplate < PlainTemplate
    self.default_mime_type = 'application/javascript'
  end

  class CSSTemplate < PlainTemplate
    self.default_mime_type = 'text/css'
  end

  class CompassSassTemplate < SassTemplate
    self.default_mime_type = 'text/css'

  private
    def sass_options
      super.merge(Linner.sass_engine_options)
    end
  end

  class CompassScssTemplate < CompassSassTemplate
    self.default_mime_type = 'text/css'

  private
    def sass_options
      super.merge(:syntax => :scss)
    end
  end

  register CSSTemplate, "css"
  register JavascriptTemplate, "js"

  register CompassSassTemplate, "sass"
  prefer CompassSassTemplate

  register CompassScssTemplate, "scss"
  prefer CompassScssTemplate
end

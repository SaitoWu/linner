require "tilt"
require "sass"
require "compass"
require "handlebars.rb"
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

  class HandlebarsTemplate < Template
    self.default_mime_type = 'application/javascript'

    def self.engine_initialized?
      true
    end

    def prepare
    end

    def evaluate(scope, locals, &block)
      @output ||= Handlebars.precompile(data)
    end
  end

  register CSSTemplate, "css"
  register JavascriptTemplate, "js"
  register HandlebarsTemplate, "hbs", "handlebars"

  register CompassSassTemplate, "sass"
  prefer CompassSassTemplate

  register CompassScssTemplate, "scss"
  prefer CompassScssTemplate
end

require "tilt"
require "sass"
require "compass/core"
require "handlebars.rb"
require "coffee_script"
require "babel/transpiler"

module Tilt
  class YAMLTemplate < PlainTemplate
    self.default_mime_type = "text/x-yaml"
  end

  class JavascriptTemplate < PlainTemplate
    self.default_mime_type = "application/javascript"
  end

  class BabelTemplate < PlainTemplate
    self.default_mime_type = "application/javascript"

    def prepare; end

    def evaluate(scope, locals, &block)
      @output ||= Babel::Transpiler.transform(data, compact: false)["code"]
    end
  end

  class CSSTemplate < PlainTemplate
    self.default_mime_type = "text/css"
  end

  class CompassSassTemplate < SassTemplate
    self.default_mime_type = "text/css"

  private
    def sass_options
      super.merge(
        style: :expanded,
        line_numbers: true,
        load_paths: Linner.env.paths << Compass::Core.base_directory("stylesheets")
      )
    end
  end

  class CompassScssTemplate < CompassSassTemplate
    self.default_mime_type = "text/css"

  private
    def sass_options
      super.merge(:syntax => :scss)
    end
  end

  class HandlebarsTemplate < Template
    self.default_mime_type = "text/template"

    def prepare; end

    def evaluate(scope, locals, &block)
      @output ||= Handlebars.precompile(data)
    end
  end

  ERBTemplate.default_mime_type = "application/x-eruby"

  register PlainTemplate, "txt"
  register CSSTemplate, "css"
  register JavascriptTemplate, "js"
  register YAMLTemplate, "yml", "yaml"
  register BabelTemplate, "es6", "es", "jsx"
  register HandlebarsTemplate, "hbs", "handlebars"

  register CompassSassTemplate, "sass"
  prefer CompassSassTemplate

  register CompassScssTemplate, "scss"
  prefer CompassScssTemplate
end

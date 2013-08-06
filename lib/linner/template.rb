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
  private
    def sass_options
      opts = Compass.configuration.to_sass_engine_options
      Linner.env.paths.each do |load_path|
        opts[:load_paths] << Sass::Importers::Filesystem.new(load_path)
      end
      super.merge(opts)
    end
  end

  class CompassScssTemplate < CompassSassTemplate
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

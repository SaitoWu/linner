require "tilt"
require "sass"
require "coffee_script"
require "compass"

module Tilt
  class JavascriptTemplate < PlainTemplate
    self.default_mime_type = 'application/javascript'
  end

  class CSSTemplate < PlainTemplate
    self.default_mime_type = 'text/css'
  end

  class SassWithCompassTemplate < SassTemplate
  private
    def sass_options
      compassSassOptions = Compass.configuration.to_sass_engine_options
      Linner.environment.sass_load_path.each do |load_path|
        compassSassOptions[:load_paths] << Sass::Importers::Filesystem.new(load_path)
      end
      super.merge(compassSassOptions)
    end
  end

  class ScssWithCompassTemplate < ScssTemplate
  private
    def sass_options
      compassSassOptions = Compass.configuration.to_sass_engine_options
      Linner.environment.sass_load_path.each do |load_path|
        compassSassOptions[:load_paths] << Sass::Importers::Filesystem.new(load_path)
      end
      super.merge(compassSassOptions)
    end
  end

  Tilt.register Tilt::CSSTemplate, "css"
  Tilt.register Tilt::JavascriptTemplate, "js"
  Tilt.register Tilt::SassWithCompassTemplate, "sass"
  Tilt.register Tilt::ScssWithCompassTemplate, "scss"
end

module Linner
  class Template

    class << self
      def template_for_script?(path)
        Tilt[path].default_mime_type == "application/javascript"
      end

      def template_for_style?(path)
        Tilt[path].default_mime_type == "text/css"
      end
    end
  end
end

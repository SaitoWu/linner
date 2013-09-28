module Linner
  class Wrapper
    WRAPPER =
      'this.require.define({"%s":' +
        'function(exports, require, module){' +
        '%s' +
        ";}});\n"

    def self.wrap(name, content)
      WRAPPER % [name, content]
    end

    def self.definition
      File.read(File.join File.dirname(__FILE__), "../../vendor", "require_definition.js")
    end
  end
end

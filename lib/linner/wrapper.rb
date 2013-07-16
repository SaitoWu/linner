module Linner
  class Wrapper
    WRAPPER =
      'window.require.define({"%s":' +
        'function(exports, require, module){' +
        '%s' +
        ";}});\n"

    def self.wrap(name, content)
      WRAPPER % [name, content]
    end
  end
end

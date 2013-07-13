module Linner
  class Wrapper

    class << self
      def wrapper
        'window.require.define({"%s":' +
          'function(exports, require, module){' +
          '%s' +
          ";}});\n"
      end

      def wrap(name, content)
        wrapper % [name, content]
      end
    end
  end
end

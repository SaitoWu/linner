module Linner
  class Wrapper

    class << self
      def wrap(name, content)
        wrapper % [name, content]
      end

      private
      def wrapper
        'window.require.define({"%s":' +
          'function(exports, require, module){' +
          '%s' +
          ";}});\n"
      end
    end
  end
end

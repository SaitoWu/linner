module Linner
  module Wrapper
    class Module
      def self.wrap(name, content)
<<-WRAPPER
this.require.define({"#{name}":function(exports, require, module){#{content};}});
WRAPPER
      end

      def self.definition
        File.read(File.join File.dirname(__FILE__), "../../vendor", "require_definition.js")
      end
    end

    class Template
      def self.wrap(name, content)
<<-WRAPPER
templates["#{name}"] = template(#{content});
WRAPPER
      end

      def self.partial_wrap(name, content)
<<-PARTIAL
Handlebars.registerPartial("#{name}", Handlebars.template(#{content}));
PARTIAL
      end


      def self.definition(content)
<<-DEFINITION
(function() {
  var template = Handlebars.template, templates = Handlebars.templates = Handlebars.templates || {};
  #{content}
})();
DEFINITION
      end
    end
  end
end

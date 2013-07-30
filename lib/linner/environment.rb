require "yaml"

module Linner
  class Environment

    def initialize(path)
      @env ||= (YAML::load(File.read path) || Hash.new)
      @convension = YAML::load File.read(File.join File.dirname(__FILE__), "../../vendor", "config.default.yml")
      @env = @convension.rmerge!(@env)
    end

    %w(app test vendor public).each do |method|
      define_method("#{method}_folder") do
        @env["paths"][method]
      end
    end

    def notification
      @env["notification"]
    end

    def wrapper
      @env["modules"]["wrapper"]
    end

    def files
      @env["files"].values
    end
  end
end

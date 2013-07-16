require "yaml"

module Linner
  class Environment

    def initialize(path)
      @env ||= (YAML::load(File.read path) || Hash.new)
      @convension = YAML::load File.read(File.join File.dirname(__FILE__), "../../vendor", "config.default.yml")
      @convension.extend(HashRecursiveMerge)
      @env = @convension.rmerge!(@env)
    end

    %w(app test vendor public).each do |method|
      define_method("#{method}_folder") do
        Linner.root.join(@env["paths"][method]).expand_path.to_path
      end
    end

    %w(notification wrapper).each do |method|
      define_method(method) do
        @env[method]
      end
    end

    def files
      @env["files"].values
    end
  end
end

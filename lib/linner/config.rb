require "yaml"

module Linner
  class Config

    def initialize(path)
      @path = path || "config.yml"
      @config ||= YAML::load(File.read File.join(Linner.root, @path))
    end

    def public_folder
      @config["paths"].to_h["public"] || "public"
    end

    def files
      @config["files"] || []
    end
  end
end

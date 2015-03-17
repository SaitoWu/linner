require "yaml"

module Linner
  class Environment

    def initialize(path)
      @env ||= (YAML::load(File.read path) || Hash.new)
      merge_with_convension
    end

    %w(app test vendor public).each do |method|
      define_method("#{method}_folder") do
        @env["paths"][method]
      end
    end

    def paths
      groups.map { |group| group["paths"] }.flatten.uniq
    end

    def watched_paths
      [app_folder, vendor_folder, test_folder].select do |path|
        File.exist? path
      end
    end

    %w(revision notification).each do |method|
      define_method("#{method}") do
        @env[method]
      end
    end

    def manifest
      revision["manifest"]
    end

    def bundles
      @env["bundles"] || []
    end

    def sprites
      @env["sprites"] || {}
    end

    def modules_ignored
      Dir.glob(@env["modules"]["ignored"])
    end

    def wrapper
      @env["modules"]["wrapper"]
    end

    def definition
      File.join public_folder, @env["modules"]["definition"]
    end

    def groups
      @env["groups"].values
    end

    def environments
      @env["environments"] || {}
    end

    def merge_with_environment(environment)
      return @env unless picked = environments[environment]
      @env = @env.rmerge!(picked)
    end

    private
    def merge_with_convension
      convension = YAML::load File.read(File.join File.dirname(__FILE__), "../../vendor", "config.default.yml")
      @env = convension.rmerge!(@env)
    end
  end
end

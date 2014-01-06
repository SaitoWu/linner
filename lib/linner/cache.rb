module Linner
  class Cache < Hash
    def miss? ns, path
      asset = Asset.new path
      if self["#{ns}:#{path}"] and self["#{ns}:#{path}"].mtime == asset.mtime
        false
      else
        self["#{ns}:#{path}"] = asset
      end
    end

    def expire_by paths
      is_include_partial_styles = paths.any? do |path|
        Asset.new(path).stylesheet? and File.basename(path).start_with? "_"
      end
      self.reject! {|k, v| v.stylesheet?} if is_include_partial_styles
    end
  end
end

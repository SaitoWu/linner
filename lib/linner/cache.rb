module Linner
  class Cache < Hash
    def miss? path
      asset = Asset.new path
      if self[path] and self[path].mtime == asset.mtime
        false
      else
        self[path] = asset
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

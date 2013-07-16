require "linner"

include Linner

module Linner
  extend self

  def root
    Pathname(".").join("spec/fixtures").expand_path
  end
end

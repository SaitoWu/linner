module Linner
  module Helper
    def root
      File.expand_path "../..", File.dirname(__FILE__)
    end

    def skip_extnames
      %w[.js .css .hbs]
    end

    def is_scripts?(path)
      !!(path =~ /\.(coffee|js)/)
    end

    def order(list, before, after)
      before.reverse.each do |f|
        if i = list.index {|x| x =~ /#{f}/i}
          list.unshift list.delete_at i
        end
      end
      after.reverse.each do |f|
        if i = list.index {|x| x =~ /#{f}/i}
          list.push list.delete_at i
        end
      end
    end
  end
end

module Linner
  module Helper
    def root
      File.expand_path "../..", File.dirname(__FILE__)
    end

    def plain_text?(path)
      %w[.js .css .hbs].include? File.extname(path)
    end

    def is_scripts?(path)
      !!(path =~ /\.(coffee|js)/)
    end

    def sort(list, before: [], after: [])
      sort_by_before(list, before)
      sort_by_after(list, after)
    end

    def sort_by_before(list, before)
      before.reverse.each do |f|
        if i = list.index {|x| x =~ /#{f}/i}
          list.unshift list.delete_at i
        end
      end
      list
    end

    def sort_by_after(list, after)
      after.reverse.each do |f|
        if i = list.index {|x| x =~ /#{f}/i}
          list.push list.delete_at i
        end
      end
      list
    end
  end
end

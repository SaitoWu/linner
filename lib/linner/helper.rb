module Linner
  module Helper
    def root
      File.expand_path "../..", File.dirname(__FILE__)
    end

    def config
      @config ||= Linner::Config.new("config.yml")
    end

    def supported_template?(path)
      %w[.coffee .sass .scss].include? File.extname(path)
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

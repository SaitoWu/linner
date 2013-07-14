module Linner
  module Sort

    def sort(before: [], after: [])
      sort_by_before(self, before)
      sort_by_after(self, after)
      self
    end

    private
    def sort_by_before(list, before)
      before.reverse.each do |f|
        if i = list.index {|x| x =~ /#{f}/i}
          list.unshift list.delete_at i
        end
      end
    end

    def sort_by_after(list, after)
      after.reverse.each do |f|
        if i = list.index {|x| x =~ /#{f}/i}
          list.push list.delete_at i
        end
      end
    end
  end
end

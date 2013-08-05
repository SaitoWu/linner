module Linner
  module HashRecursiveMerge
    def rmerge!(other_hash)
      merge!(other_hash) do |key, oldval, newval|
        oldval.class == self.class ? oldval.rmerge!(newval) : newval
      end
    end
  end

  module Order
    def order_by(ary)
      ary ||= []
      ary << "..." if not ary.include? "..."
      order_ary = ary.inject([[]]) do |a, x|
        x != "..." ? a.last << x : a<< []; a
      end
      order_by_before(self, order_ary.first)
      order_by_after(self, order_ary.last)
      self
    end

    private
    def order_by_before(list, before)
      before.reverse.each do |f|
        if i = list.index {|x| x =~ /#{f}/i}
          list.unshift list.delete_at i
        end
      end
    end

    def order_by_after(list, after)
      after.reverse.each do |f|
        if i = list.index {|x| x =~ /#{f}/i}
          list.push list.delete_at i
        end
      end
    end
  end
end

class Hash
  include Linner::HashRecursiveMerge
end

class Array
  include Linner::Order
end

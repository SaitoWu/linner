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
      ary << "..." if not ary.include? "..."
      order_ary = ary.inject([[]]) do |a, x|
        x != "..." ? a.last << x : a<< []; a
      end
      order_by_direction(order_ary.first, :before)
      order_by_direction(order_ary.last, :after)
      self
    end

  private
    def order_by_direction(ary, direction)
      ary = ary.reverse if direction == :before
      ary.each do |f|
        next unless i = self.index {|x| x =~ /#{f}/i}
        item = self.delete_at i
        direction == :before ? self.unshift(item) : self.push(item)
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

module Corn
  class ReservoirSampling
    attr_reader :items
    def initialize(limit)
      @limit = limit
      @items = []
      @size = -1
      @count = 0
    end

    def <<(item)
      @count += 1
      if @size < 0 && bytesize < @limit
        items << item
      else
        @size = items.size
        j = rand(@count).to_i
        if j < @size
          items[j] = item
        end
      end
    end

    private
    def bytesize
      items.map{|d|d[:data].bytesize}.reduce(:+) || 0
    end
  end
end

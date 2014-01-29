module Corn
  class Report
    attr_reader :records

    def initialize
      @records = []
    end

    def record(label, &block)
      record_start(label)
      yield
    ensure
      record_end
    end

    def record_start(label)
      @record = [label, Time.now]
    end

    def record_end
      @record << Time.now - @record[1]
      @records << @record
    end

    def record_time
      Time.now - @start_at
    end
  end
end

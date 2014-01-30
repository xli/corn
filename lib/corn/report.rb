require 'csv'

module Corn
  class Report

    def initialize(prefix=nil)
      @prefix = prefix
      @records = []
    end

    def record(label, &block)
      record_start(label)
      yield(sub_report)
    ensure
      record_end
    end

    # start record a benchmark time by label
    def record_start(label)
      @record = [record_label(label), Time.now]
    end

    # should only be called between record_start and record_end to generate
    # sub report for current report
    def sub_report
      @sub_report ||= Report.new(@record[0])
    end

    # should only be called after record_start
    def record_end
      @record << Time.now - @record[1]
      @records << @record
      if @sub_report
        @records.concat @sub_report.to_a
        @sub_report = nil
      end
    end

    def empty?
      @records.empty?
    end

    def to_a
      @records
    end

    def to_csv
      if RUBY_VERSION =~ /1.8/
        buf = ''
        @records.each do |r|
          CSV.generate_row(r, r.size, buf)
        end
        buf
      else
        CSV.generate do |csv|
          @records.each { |r| csv << r }
        end
      end
    end

    private
    def record_label(label)
      [@prefix, label].compact.join('.').to_sym
    end
  end
end

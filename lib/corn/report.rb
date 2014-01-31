require 'csv'

module Corn
  class Report

    class RecordNotStartError < StandardError
    end

    class Record
      attr_reader :data

      def initialize(label, parent=nil)
        @label = label
        @parent = parent
        @data = []
        @start = Time.now
      end

      def push(label)
        Record.new(label, self)
      end

      def pop
        return if @parent.nil?
        @parent.record(@label, @start, Time.now - @start)
        @data.each { |d| @parent.record(*d) }
        @parent
      end

      def record(label, start, time)
        @data << [record_label(label), start, time]
      end

      private
      def record_label(label)
        [@label, label].compact.join('.').to_sym
      end
    end

    def initialize(prefix=nil)
      @record = Record.new(prefix, nil)
    end

    def record(label, &block)
      record_start(label)
      yield
    ensure
      record_end
    end

    def record_start(label)
      @record = @record.push(label)
    end

    def record_end
      @record = @record.pop || raise(RecordNotStartError)
    end

    def empty?
      to_a.empty?
    end

    def to_a
      @record.data
    end

    def to_csv
      if RUBY_VERSION =~ /1.8/
        buf = ''
        self.to_a.each do |r|
          CSV.generate_row(r, r.size, buf)
        end
        buf
      else
        CSV.generate do |csv|
          self.to_a.each { |r| csv << r }
        end
      end
    end
  end
end

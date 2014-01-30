module Corn
  module MiniTest
    def self.included(base)
      base.send(:alias_method, :run_without_corn, :run)
      base.send(:alias_method, :run, :run_with_corn)
    end

    def run_with_corn(runner, &block)
      Corn.report("#{__name__}(#{self.class.name})") do |report|
        @__corn_report__ = report
        run_without_corn(runner, &block)
      end
    end

    def before_setup
      @__corn_report__.record_start(:setup)
    end

    def after_setup
      @__corn_report__.record_end
      @__corn_report__.record_start(:run_test)
    end

    def before_teardown
      @__corn_report__.record_end
      @__corn_report__.record_start(:teardown)
    end

    def after_teardown
      @__corn_report__.record_end
    end
  end
end

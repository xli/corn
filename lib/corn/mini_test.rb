module Corn
  module MiniTest
    def self.included(base)
      base.send(:alias_method, :run_without_corn, :run)
      base.send(:alias_method, :run, :run_with_corn)
    end

    def run_with_corn(runner, &block)
      label = "#{self.class.name}.#{__name__}"
      Corn.report(label) do |report|
        @corn_report = report
        run_without_corn(runner, &block)
      end
    end

    def before_setup
      @corn_report.record_start(:setup)
    end

    def after_setup
      @corn_report.record_end
      @corn_report.record_start(:run_test)
    end

    def before_teardown
      @corn_report.record_end
      @corn_report.record_start(:teardown)
    end

    def after_teardown
      @corn_report.record_end
    end
  end
end

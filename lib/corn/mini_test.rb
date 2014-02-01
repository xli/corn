module Corn
  module MiniTest
    def self.included(base)
      base.send(:alias_method, :run_without_corn, :run)
      base.send(:alias_method, :run, :run_with_corn)
    end

    def run_with_corn(runner, &block)
      label = "#{self.class.name}.#{__name__}"
      Corn.report(label) do
        run_without_corn(runner, &block)
      end
    end

    def before_setup
      Corn.report.record_start(:setup)
      super
    end

    def after_setup
      super
      Corn.report.record_end
      Corn.report.record_start(:run_test)
    end

    def before_teardown
      Corn.report.record_end
      Corn.report.record_start(:teardown)
      super
    end

    def after_teardown
      super
      Corn.report.record_end
    end
  end
end

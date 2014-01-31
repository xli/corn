require 'test/unit/testcase'

module Corn
  module TestUnit18
    def self.included(base)
      base.send(:alias_method, :run_without_corn, :run)
      base.send(:alias_method, :run, :run_with_corn)
    end

    def run_with_corn(result, &block)
      label = "#{self.class.name}.#{@method_name}"
      Corn.report(label) do |report|
        __run_with_corn__(report, result, &block)
      end
    end

    def __run_with_corn__(report, result, &block)
      yield(Test::Unit::TestCase::STARTED, name)
      @_result = result
      begin
        report.record(:setup) { setup }
        report.record(:run_test) { __send__(@method_name) }
      rescue AssertionFailedError => e
        add_failure(e.message, e.backtrace)
      rescue Exception
        raise if Test::Unit::TestCase::PASSTHROUGH_EXCEPTIONS.include? $!.class
        add_error($!)
      ensure
        begin
          report.record(:teardown) { teardown }
        rescue AssertionFailedError => e
          add_failure(e.message, e.backtrace)
        rescue Exception
          raise if Test::Unit::TestCase::PASSTHROUGH_EXCEPTIONS.include? $!.class
          add_error($!)
        end
      end
      result.add_run
      yield(Test::Unit::TestCase::FINISHED, name)
    end
  end

  module TestRunnerMediator
    def self.included(base)
      base.send(:alias_method, :run_suite_without_corn, :run_suite)
      base.send(:alias_method, :run_suite, :run_suite_with_corn)
    end

    def run_suite_with_corn
      run_suite_without_corn.tap do |r|
        Corn.submit
      end
    end
  end
end

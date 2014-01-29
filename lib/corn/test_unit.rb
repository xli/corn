require 'test/unit/testcase'

module Corn
  module TestUnit18
    def self.included(base)
      base.send(:alias_method, :run_without_corn, :run)
      base.send(:alias_method, :run, :run_with_corn)
    end

    def run_with_corn(result, &block)
      Corn.report(name) do |report|
        __run_with_corn__(report, result, &block)
      end
    end

    def __run_with_corn__(report, result, &block)
      yield(Test::Unit::TestCase::STARTED, name)
      @_result = result
      begin
        report.record(:setup) { setup }
        report.record(@method_name) { __send__(@method_name) }
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

  module TestUnit19
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
      @__corn_report__.record_start(__name__)
    end

    def before_teardown
      @__corn_report__.record_end
      @__corn_report__.record_start(:teardown)
    end

    def after_teardown
      @__corn_report__.record_end
    end
  end

  TestUnit = RUBY_VERSION =~ /^1.8/ ? TestUnit18 : TestUnit19
end

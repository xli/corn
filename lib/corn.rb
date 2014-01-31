require 'net/http'
require 'net/https'
require 'logger'
require 'csv'

require 'corn/report'
require 'corn/test_unit'
require 'corn/mini_test'

module Corn
  module_function

  def host
    ENV['CORN_HOST'] || raise('No environment vairable CORN_HOST defined')
  end

  def client_id
    ENV['CORN_CLIENT_ID'] || raise('No environment vairable CORN_CLIENT_ID defined')
  end

  def build_label
    ENV['CORN_BUILD_LABEL'] || raise('No environment vairable CORN_BUILD_LABEL defined')
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def setup
    if RUBY_VERSION =~ /^1.8/
      if defined?(Test::Unit::TestCase)
        Test::Unit::TestCase.send(:include, TestUnit18)
        Test::Unit::UI::TestRunnerMediator.send(:include, TestRunnerMediator)
      end
    end
    if defined?(::MiniTest::Unit::TestCase)
      ::MiniTest::Unit::TestCase.send(:include, Corn::MiniTest)
      ::MiniTest::Unit.after_tests { submit }
    end
  end

  def report(label=nil, &block)
    @report ||= Report.new
    if label
      @report.record(label, &block)
    else
      @report
    end
  end

  def submit
    return if @report.nil? || @report.empty?
    log_error do
      data = {
        :client_id => client_id,
        :build_label => build_label,
        :reports => @report.to_csv
      }
      http_post(File.join(host, 'benchmarks'), data)
      @report = nil
    end
  end

  def http_post(url, data)
    uri = URI(url)
    Net::HTTP.start(uri.host, uri.port) do |http|
      http.use_ssl = uri.scheme == 'https'
      req = Net::HTTP::Post.new(uri.path)
      req.set_form_data(data)
      res = http.request req
      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        # OK
      else
        res.error!
      end
    end
  end

  def log_error(&block)
    yield
  rescue Exception => e
    logger.debug do
      "Report error: #{e.message}:\n#{e.backtrace.join("\n")}"
    end
  end
end

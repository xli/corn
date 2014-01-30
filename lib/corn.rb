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

  def build_id
    ENV['CORN_BUILD_ID'] || raise('No environment vairable CORN_BUILD_ID defined')
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def setup
    if RUBY_VERSION =~ /^1.8/
      if defined?(Test::Unit::TestCase)
        Test::Unit::TestCase.send(:include, TestUnit18)
      end
    end
    if defined?(::MiniTest::Unit::TestCase)
      ::MiniTest::Unit::TestCase.send(:include, Corn::MiniTest)
    end
  end

  def report(test_name, &block)
    rep = report_start
    begin
      yield(rep)
    ensure
      report_end(test_name, rep)
    end
  end

  def report_start
    @reports ||= create_reports
    Report.new
  end

  def report_end(test_name, report)
    @reports << [test_name] + report.records.flatten
  end

  def create_reports
    at_exit { submit_reports }
    []
  end

  def submit_reports
    return if @reports.nil? || @reports.empty?
    log_error do
      reports_csv = CSV.generate do |csv|
        @reports.each do |rep|
          csv << rep
        end
      end
      data = { client_id: client_id,
        build_id: build_id,
        reports: reports_csv }
      @reports = []
      http_post(File.join(host, 'benchmarks'), data)
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

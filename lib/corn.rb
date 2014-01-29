require 'net/http'
require 'net/https'
require 'logger'

require 'corn/report'
require 'corn/test_unit'

module Corn
  module_function

  def host
    ENV['CORN_HOST']
  end

  def client_id
    ENV['CORN_CLIENT_ID'] || 'corn client id'
  end

  def build_id
    ENV['CORN_BUILD_ID'] || 'corn build id'
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def setup
    Test::Unit::TestCase.send(:include, Corn::TestUnit)
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
    Report.new
  end

  def report_end(test_name, report)
    log_error do
      head = [['client_id', client_id],
              ['build_id', build_id],
              ['test_name', test_name]]
      data = head.concat(report.records.map {|r| ['reports[]', r.join(",")]})
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

require 'net/http'
require 'net/https'
require 'logger'
require 'csv'

require 'corn/report'

module Corn
  module_function

  def host
    ENV['CORN_HOST'] || raise('No environment vairable CORN_HOST defined')
  end

  def client_id
    ENV['CORN_CLIENT_ID'] || raise('No environment vairable CORN_CLIENT_ID defined')
  end

  def configured?
    !!ENV['CORN_CLIENT_ID']
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def create_report(name)
    Thread.current[report_key] = Report.new(name)
  end

  def report(label=nil, &block)
    if label
      self.report.record(label, &block)
    else
      Thread.current[report_key]
    end
  end

  def submit
    return if self.report.nil? || self.report.empty?
    log_error do
      data = {
        'client_id' => client_id,
        'report[name]' => self.report.name,
        'report[records]' => self.report.to_csv
      }
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

  def report_key
    '__corn_report__'
  end

end

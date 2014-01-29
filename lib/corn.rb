require 'corn/test_unit'
require 'net/http'
require 'net/https'
require 'logger'

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

  def benchmark(*labels, &block)
    reports = []
    yield(reporter(reports))

    log_error { report(labels, reports) }
  end

  def reporter(reports)
    lambda do |label, &block|
      start_at = Time.now
      begin
        block.call
      ensure
        realtime = Time.now - start_at
        reports << [label, start_at.to_i, realtime]
      end
    end
  end

  def report(labels, reports)
    data = [['client_id', client_id],
            ['build_id', build_id]]
    data.concat(labels.map {|l| ['labels[]', l]})
    data.concat(reports.map {|r| ['reports[]', r.join(",")]})
    http_post(File.join(host, 'benchmarks'), data)
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
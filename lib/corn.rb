require 'rubygems'
require 'sampling_prof'
require 'net/http'
require 'net/https'
require 'corn/rack'

module Corn
  module_function

  def rack_slow_request_profiler
    Rack::SlowRequestProfiler
  end

  def host
    ENV['CORN_HOST']
  end

  def client_id
    ENV['CORN_CLIENT_ID']
  end

  def configured?
    !!(host && client_id)
  end

  def profiler(report_name, sampling_interval=0.1)
    if !configured?
      log("No CORN_CLIENT_ID or CORN_HOST configured, profiling data is not submitted")
      return
    end
    SamplingProf.new(sampling_interval) do |data|
      post(data, report_name)
    end
  end

  def submit_url
    File.join(host, 'profile_data')
  end

  def log(msg)
    $stderr.puts msg
  end

  def post(data, name)
    url = URI.parse(submit_url)
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data("data" => data, 'client_id' => client_id, 'name' => name)
    res = Net::HTTP.start(url.host, url.port) do |http|
      http.use_ssl = url.scheme == 'https'
      http.request(req)
    end
    log("Corn report submitted to #{submit_url}")
  rescue Exception => e
    log("post to #{submit_url} failed: #{e.message}")
    log(e.backtrace.join("\n"))
  end
end

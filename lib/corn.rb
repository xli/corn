require 'rubygems'
require 'sampling_prof'
require 'net/http'
require 'net/https'
require 'corn/rack'
require 'logger'

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

  def submit_url
    File.join(host, 'profile_data')
  end

  def logger=(l)
    @logger = l
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end
end

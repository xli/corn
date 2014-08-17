require 'rubygems'
require 'logger'
require 'corn/config'
require 'corn/rack'

module Corn
  include Config

  # Set configurations or get current configurations.
  #
  #   host: corn server host
  #   client_id: corn project client id
  #   logger: a Logger object, e.g. Rails.logger.
  #
  # Configurations for posting data back to Corn server
  #
  #   ssl_verify_peer:
  #     true: set verify_mode to OpenSSL::SSL::VERIFY_PEER
  #     false: set verify_mode to OpenSSL::SSL::VERIFY_NONE
  #     default to false
  #   ssl_ca_file: Net::HTTPSession#ca_file
  #   ssl_ca_path: Net::HTTPSession#ca_path
  #   see Ruby Net::HTTP document for details
  #
  config({
           :logger => Logger.new(STDOUT),
           :client_id => lambda { ENV['CORN_CLIENT_ID'] },
           :host => lambda { ENV['CORN_HOST'] },
           :ssl_verify_peer => false,
           :ssl_ca_file => nil,
           :ssl_ca_path => nil,
           # slow request profiler options
           :rack_middleware => Rack::SlowRequestProfiler,
           :rack_slow_request_profiler => Rack::SlowRequestProfiler,
           :slow_request_threshold => 5,
           :profiling => true,
           :sampling_interval => 0.1,
           :post_interval => 2
         })

  module_function
  def configured?
    if host.nil? || host.empty?
      Corn.logger.info("Corn host not found")
    end
    if client_id.nil? || client_id.empty?
      Corn.logger.info("Corn client id not found")
    end
    !!(host && client_id)
  end

  def submit_url
    File.join(host, 'profiling_data')
  end
end

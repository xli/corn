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
           :host => ENV['CORN_HOST'],
           :client_id => ENV['CORN_CLIENT_ID'],
           :ssl_verify_peer => false,
           :ssl_ca_file => nil,
           :ssl_ca_path => nil
         })

  module_function
  def configured?
    !!(host && client_id)
  end

  def submit_url
    File.join(host, 'profiling_data')
  end

  def rack_slow_request_profiler
    Rack::SlowRequestProfiler
  end
end

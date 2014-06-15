require 'rubygems'
require 'corn/config'
require 'corn/rack'

module Corn
  extend Config

  module_function
  def rack_slow_request_profiler
    Rack::SlowRequestProfiler
  end
end

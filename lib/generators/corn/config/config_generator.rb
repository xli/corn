require 'rails/generators'

module Corn
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      def do_config
        create_file "config/initializers/corn_config.rb", <<-RUBY
Corn.config({
              # setup Corn logger, default is output to STDOUT.
              :logger => Rails.logger,

              # Every Corn project has its own client id, you can find it in your
              # Corn project page. This is a unique identifier for reporting your
              # data, please keep it secret.
              # :client_id => ENV["CORN_CLIENT_ID"],

              # Corn only reprots requests that are exceeded this threshold;
              # default threshold is 5 seconds. Please use your 95 percentile response
              # time as slow_request_threshold value, so that you can focus on
              # improving slow requests. Doing nothing with generated reports
              # is a waste.
              # You can change this value to 0 for testing Corn configurations,
              # and learn how Corn works.
              # Set this threshold to smaller value may cause performance overhead.
              # :slow_request_threshold => 5,

              # Sampling interval controls how frequent profiler should take
              # sample of processing request threads' stacktrace. The default value
              # is 0.1 seconds. Change the value to larger number will reduce the
              # performance impact to your application. Change the value to smaller
              # number will increase performance impact.
              # The more samples we have for processing a request, the more accurate
              # of the profiling call-graph report we will have.
              # Hence it needs a balance.
              # For example, when a request processing time is 5 seconds, sampling_interval
              # value is 0.1 second, then we will get approximately 50 samples, which
              # is good enough for you to understand what's your code doing in most
              # of cases.
              # :sampling_interval => 0.1,

              # Corn launchs a standalone thread to post profiling data back to Corn server.
              # post_interval controls how frequent we will post one report back to
              # Corn server. Default value is 2 seconds. It means the posting thread will
              # sleep 2 seconds after Corn posted one processed slow request profiling
              # data to Corn server. If you had too many reports need to be posted to Corn
              # server, we recommend you increase slow_request_threshold instead of reduce
              # post_interval value.
              # :post_interval => 2,

              # Why we need this configuration? The anwser is runtime toggle.
              # You may like to turn off the Corn profiler in most of time,
              # and only turn on profiling when you need it in production.
              # The value can be "true", "false" or a lambda (or Proc).
              # For example: Corn.config(:profiling => lambda {|env| YourAppConfig.corn_profiling? })
              # The "env" argument is the Rack env argument when a Rack middleware is
              # called. So you can also use it to turn on profiling by a request parameter.
              # For example: Corn.config(:profiling => lambda {|env| env["QUERY_STRING"] =~ /corn_profiling=true/ })
              # This configuration will be checked for every request, so don't do anything
              # expensive here.
              # :profiling => true,
            })
# Install corn rack middleware for profiling slow requests
Rails.configuration.middleware.use(Corn.rack_middleware)
RUBY
      end
    end
  end
end

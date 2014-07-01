require 'corn/config'
require 'corn/profiler'
require 'corn/rack/request_env'

module Corn
  module Rack
    class SlowRequestProfiler
      include Config
      config(:profiling => true,
             :slow_request_threshold => 5,
             :sampling_interval => 0.1,
             :post_interval => 2)

      class ProfilingApp
        def initialize(app, config)
          @@prof ||= Profiler.new(config.post_interval,
                                  config.sampling_interval)
          @app = app
          @config = config
        end

        def call(env)
          if @config.profiling?
            @@prof.profile(output_handler(env)) { @app.call(env) }
          else
            @app.call(env)
          end
        end

        def terminate
          @@prof.terminate
          @@prof = nil
        end

        def output_handler(env)
          request_env = RequestEnv.new(env)
          lambda do |data|
            if request_env.time > @config.slow_request_threshold
              request_env.to_report.merge("data" => data)
            end
          end
        end
      end

      def initialize(app)
        @app = Corn.configured? ? ProfilingApp.new(app, self.class) : app
      end

      def call(env)
        @app.call(env)
      end

      def terminate
        @app.terminate if @app.respond_to?(:terminate)
      end
    end
  end
end

require 'corn/profiler'
require 'corn/rack/request_env'

module Corn
  module Rack
    class SlowRequestProfiler
      class ProfilingApp
        def initialize(app)
          @@prof ||= Profiler.new(Corn.post_interval,
                                  Corn.sampling_interval)
          @app = app
        end

        def call(env)
          if Corn.profiling?
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
            if request_env.time > Corn.slow_request_threshold
              request_env.to_report.merge("data" => data)
            end
          end
        end
      end

      def initialize(app)
        @app = Corn.configured? ? ProfilingApp.new(app) : app
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

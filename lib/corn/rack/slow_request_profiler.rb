require 'thread'
require 'corn/profiler'
require 'corn/reservoir_sampling'
require 'corn/rack/request_env'

module Corn
  module Rack
    class SlowRequestProfiler
      class ProfilingApp
        def initialize(app)
          @@prof ||= Profiler.new(Corn.post_interval,
                                  Corn.fast_request_sampling_limit,
                                  Corn.post_fast_request_interval,
                                  Corn.sampling_interval)
          @app = app

          Corn.logger.info("Corn sampling interval: #{Corn.sampling_interval}")
          Corn.logger.info("Corn slow request threshold: #{Corn.slow_request_threshold}")
        end

        def call(env)
          if Corn.profiling?(env)
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
            t = request_env.time
            if t < fast_request_threshold || t > slow_request_threshold
              action = t > Corn.slow_request_threshold ? :post : :sampling
              request_env.to_report.merge(:data => data, :action => action)
            end
          end
        end

        def fast_request_threshold
          @frt ||= Corn.fast_request_threshold
        end
        def slow_request_threshold
          @srt ||= Corn.slow_request_threshold
        end
      end

      def initialize(app)
        @app = Corn.configured? ? ProfilingApp.new(app) : app
      end

      def call(env)
        @app.call(env)
      end

      # for test
      def terminate
        @app.terminate if @app.respond_to?(:terminate)
      end
    end
  end
end

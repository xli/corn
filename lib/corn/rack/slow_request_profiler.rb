require 'corn/config'
require 'corn/post'
require 'corn/rack/request_env'
require 'sampling_prof'

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
          @app = app
          @config = config
          @post = Post.new(config.post_interval)
          @prof = SamplingProf.new(config.sampling_interval)
          at_exit { terminate }
        end

        def call(env)
          if @config.profiling?
            @prof.profile(output_handler(env)) { @app.call(env) }
          else
            @app.call(env)
          end
        end

        def terminate
          @prof.terminate rescue nil
          @post.terminate rescue nil
        end

        def output_handler(env)
          request_env = RequestEnv.new(env)
          lambda do |data|
            if request_env.time > @config.slow_request_threshold
              @post.enqueue(request_env.to_report.merge("data" => data))
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

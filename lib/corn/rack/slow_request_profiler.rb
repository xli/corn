require 'corn/post'
require 'corn/rack/request_env'
require 'sampling_prof'

module Corn
  module Rack
    class SlowRequestProfiler
      class ProfilingApp
        def initialize(app, slow_request_threshold=5, sampling_interval=0.1)
          @app = app
          @slow_request_threshold = slow_request_threshold
          @sampling_interval = sampling_interval
          @post = Post.new
          @prof = SamplingProf.new(@sampling_interval)
          at_exit { terminate }
        end

        def call(env)
          @prof.profile(output_handler(env)) { @app.call(env) }
        end

        def terminate
          @prof.terminate rescue nil
          @post.terminate rescue nil
        end

        def output_handler(env)
          request_env = RequestEnv.new(env)
          lambda do |data|
            if request_env.time > @slow_request_threshold
              @post.enqueue(request_env.to_report.merge("data" => data))
            end
          end
        end
      end

      def initialize(app, *args)
        @app = Corn.configured? ? ProfilingApp.new(app, *args) : app
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

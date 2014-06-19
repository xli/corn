require 'corn/post'
require 'corn/rack/request_env'
require 'sampling_prof'

module Corn
  module Rack
    class SlowRequestProfiler
      def initialize(app,
                     slow_request_threshold=5,
                     sampling_interval=0.1)
        @app = app
        @slow_request_threshold = slow_request_threshold
        @post = Post.new
        @prof = SamplingProf.new(sampling_interval)
        at_exit { terminate }
      end

      def call(env)
        @prof.profile(output_handler(env)) { @app.call(env) }
      end

      def terminate
        @prof.terminate rescue nil
        @post.terminate
      end

      def output_handler(env)
        request_env = RequestEnv.new(env, @slow_request_threshold)
        lambda do |data|
          if request_env.slow_request?
            @post.enqueue(data,
                          request_env.report_name,
                          request_env.start_time)
          end
        end
      end
    end
  end
end

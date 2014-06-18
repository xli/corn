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
        @post = Post.new
        @request_env = RequestEnv.new(slow_request_threshold)
        @prof = SamplingProf.new(sampling_interval) do |data|
          if @request_env.slow_request?
            @post.enqueue(data,
                          @request_env.report_name,
                          @request_env.start_time)
          end
        end
        at_exit { terminate }
      end

      def call(env)
        @request_env.record(env) do
          @prof.profile { @app.call(env) }
        end
      end

      def terminate
        @prof.terminate rescue nil
        @post.terminate
      end
    end
  end
end

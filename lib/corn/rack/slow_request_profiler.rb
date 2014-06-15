require 'corn/post'
require 'sampling_prof'

module Corn
  module Rack
    class SlowRequestProfiler
      def initialize(app,
                     slow_request=5,
                     sampling_interval=0.1)
        @app = app
        @post = Post.new
        @prof = SamplingProf.new(sampling_interval) do |data|
          t = Thread.current
          if (Time.now - t['corn_start_time']) > slow_request
            name = [t['corn_start_time'], t['corn_path_info']].join(',')
            @post.enqueue(data, name)
          end
        end
        at_exit { terminate }
      end

      def call(env)
        Thread.current['corn_path_info'] = env['PATH_INFO']
        Thread.current['corn_start_time'] = Time.now
        @prof.profile { @app.call(env) }
      end

      def terminate
        @prof.terminate rescue nil
        @post.terminate
      end
    end
  end
end

require 'sampling_prof'
require 'thread'

module Corn
  module Rack
    class SlowRequestProfiler
      def initialize(app, profiling_threadshold=5, sampling_interval=0.1)
        @app = app
        @queue = Queue.new
        @post_thread = Thread.start do
          loop do
            Corn.post(*@queue.pop)
            sleep 1
          end
        end
        @prof = SamplingProf.new(sampling_interval) do |data|
          t = Thread.current
          if (Time.now - t['corn_start_time']) > profiling_threadshold
            name = "#{t['corn_start_time']}-#{t['corn_path_info']}"
            @queue << [data, name]
          end
        end
        at_exit {
          @prof.terminate rescue nil
          @post_thread.terminate rescue nil
        }
      end

      def call(env)
        Thread.current['corn_path_info'] = env['PATH_INFO']
        Thread.current['corn_start_time'] = Time.now
        Corn.profile { @app.call(env) }
      end
    end
  end
end

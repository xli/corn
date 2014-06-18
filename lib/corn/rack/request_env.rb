module Corn
  module Rack
    class RequestEnv
      def initialize(threshold)
        @threshold = threshold
      end

      def record(env, &block)
        Thread.current['corn_path_info'] = env['PATH_INFO']
        Thread.current['corn_http_host'] = env['HTTP_HOST']
        Thread.current['corn_start_time'] = Time.now
        yield
      ensure
        Thread.current['corn_path_info'] = nil
        Thread.current['corn_http_host'] = nil
        Thread.current['corn_start_time'] = nil
      end

      def start_time
        Thread.current['corn_start_time']
      end

      def time
        Time.now - start_time
      end

      def slow_request?
        time > @threshold
      end

      def report_name
        File.join(*[Thread.current['corn_http_host'],
                    Thread.current['corn_path_info']].compact)
      end
    end
  end
end

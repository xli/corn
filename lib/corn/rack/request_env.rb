module Corn
  module Rack
    class RequestEnv
      attr_reader :start_time
      def initialize(env, threshold)
        @path_info = env['PATH_INFO']
        @http_host = env['HTTP_HOST']
        @threshold = threshold
        @start_time = Time.now
      end

      def time
        Time.now - start_time
      end

      def slow_request?
        time > @threshold
      end

      def report_name
        File.join(*[@http_host,
                    @path_info].compact)
      end
    end
  end
end

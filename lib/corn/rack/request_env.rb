module Corn
  module Rack
    class RequestEnv
      attr_reader :start_time
      def initialize(env, threshold)
        @path_info = env['PATH_INFO']
        @http_host = env['HTTP_HOST']
        @query_string = env['QUERY_STRING']
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
        name = File.join(*[@http_host,
                           @path_info].compact)
        if @query_string && @query_string.length > 0
          "#{name}?#{@query_string}"
        else
          name
        end
      end
    end
  end
end

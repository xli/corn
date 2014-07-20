module Corn
  module Rack
    class RequestEnv
      KEYS = [:request_method, :path_info, :http_host, :query_string]
      def initialize(env, start_time=Time.now)
        @env = KEYS.inject({}) do |memo, k|
          v = env[k.to_s.upcase]
          if v.nil? || v.empty?
            memo
          else
            memo.merge(k => v)
          end
        end
        @env.merge!(:start_time => start_time)
      end

      def time
        end_at - @env[:start_time]
      end

      def end_at
        Time.now
      end

      def to_report
        name = File.join(@env[:http_host].to_s, @env[:path_info].to_s)
        if @env[:request_method]
          name = "#{@env[:request_method]} #{name}"
        end
        if @env[:query_string]
          name = "#{name}?#{@env[:query_string]}"
        end
        {
          :name => name,
          :start_at => @env[:start_time].iso8601,
          :end_at => end_at.iso8601
        }
      end
    end
  end
end

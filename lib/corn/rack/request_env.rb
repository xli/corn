module Corn
  module Rack
    class RequestEnv
      def initialize(env, start_time=Time.now)
        @env = [:path_info, :http_host, :query_string].inject({}) do |memo, k|
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
        if @env[:query_string]
          name = "#{name}?#{@env[:query_string]}"
        end
        {
          'report[name]' => name,
          'report[start_at]' => @env[:start_time].iso8601,
          'report[end_at]' => end_at.iso8601
        }
      end
    end
  end
end

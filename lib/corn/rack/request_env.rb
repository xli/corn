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
        Time.now - @env[:start_time]
      end

      def to_h
        @env.dup
      end
    end
  end
end

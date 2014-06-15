require 'thread'

module Corn
  class Post
    def initialize
      @queue = Queue.new
      @thread = start_post_thread
    end

    def terminate
      @thread.terminate rescue nil
    end

    def start_post_thread
      Thread.start do
        begin
          loop do
            http_post(*@queue.pop)
            sleep 1
          end
        rescue => e
          log("Corn post thread stopped by error #{e.message}\n#{e.backtrace.join("\n")}")
        end
      end
    end

    def enqueue(data, name)
      @queue << [data, name]
    end

    def http_post(data, name)
      url = URI.parse(submit_url)
      req = Net::HTTP::Post.new(url.path)
      req.set_form_data("data" => data, 'client_id' => Corn.client_id, 'name' => name)
      res = Net::HTTP.start(url.host, url.port) do |http|
        http.use_ssl = url.scheme == 'https'
        http.request(req)
      end
      log("Corn report submitted to #{submit_url}")
    rescue Exception => e
      log("post to #{submit_url} failed: #{e.message}")
      log(e.backtrace.join("\n"))
    end

    def submit_url
      Corn.submit_url
    end

    def log(msg)
      Corn.logger.info msg
    end
  end
end

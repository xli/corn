require 'net/http'
require 'net/https'
require 'thread'
require 'time'

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
          Corn.logger.error("Corn post thread stopped by error #{e.message}\n#{e.backtrace.join("\n")}")
        end
      end
    end

    def enqueue(*args)
      @queue << args
    end

    def http_post(data, name, start_time)
      uri = URI.parse(submit_url)
      req = Net::HTTP::Post.new(uri.path)
      req.set_form_data("data" => data,
                        'client_id' => Corn.client_id,
                        'name' => name,
                        'start_time' => start_time.iso8601)

      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == 'https'
        http.use_ssl = true
        if Corn.ssl_verify_peer?
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          http.ca_file = Corn.ssl_ca_file if Corn.ssl_ca_file
          http.ca_path = Corn.ssl_ca_path if Corn.ssl_ca_path
        else
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
      end
      res = http.request(req)
      Corn.logger.info("Corn report submitted to #{submit_url}")
      unless res.is_a?(Net::HTTPSuccess)
        Corn.logger.error("Post failed: #{res.message}(#{res.code}), response body: \n#{res.body}")
      end
    rescue Exception => e
      Corn.logger.error("post to #{submit_url} failed: #{e.message}\n#{e.backtrace.join("\n")}")
    end

    def submit_url
      Corn.submit_url
    end
  end
end

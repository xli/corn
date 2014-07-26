require 'net/http'
require 'net/https'
require 'thread'
require 'time'

module Corn
  class Post
    def initialize(interval)
      @queue = Queue.new
      @thread = start_post_thread(interval)
    end

    def terminate
      @thread.terminate
    end

    def start_post_thread(interval)
      if interval <= 0
        Corn.logger.info("Corn post interval <= 0 sec, change it to 1 sec")
        interval = 1
      else
        Corn.logger.info("Corn post interval #{interval} sec(s)")
      end
      Thread.start do
        begin
          loop do
            http_post([@queue.pop])
            sleep interval
          end
        rescue => e
          Corn.logger.error("Corn post thread stopped by error #{e.message}\n#{e.backtrace.join("\n")}")
        end
      end
    end

    def enqueue(data)
      return if data.nil? || data.empty?
      @queue << data
    end

    def http_post(reports, type=nil)
      uri = URI.parse(submit_url)
      req = Net::HTTP::Post.new(uri.path)
      form_data = [['client_id', Corn.client_id]]
      if type
        form_data << ['type', type]
      end
      reports.each_with_index do |rep, i|
        [:name, :start_at, :end_at, :data].each do |k|
          if v = rep[k]
            form_data << ["reports[][#{k}]", v]
          end
        end
      end
      req.set_form_data(form_data)

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
      Corn.logger.info("Corn reports(#{reports.size}) submitted to #{submit_url}")
      unless res.is_a?(Net::HTTPSuccess)
        Corn.logger.error("Post failed: #{res.message}(#{res.code}), response body: \n#{res.body}")
      end
    rescue => e
      Corn.logger.error("post to #{submit_url} failed: #{e.message}\n#{e.backtrace.join("\n")}")
    end

    def submit_url
      Corn.submit_url
    end
  end
end

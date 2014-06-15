require 'logger'

module Corn
  module Config
    # config:
    # => host
    # => client_id
    # => logger
    def config(hash={})
      @config ||= {
        :logger => Logger.new(STDOUT),
        :host => ENV['CORN_HOST'],
        :client_id => ENV['CORN_CLIENT_ID']
      }
      hash.empty? ? @config : @config.merge!(hash)
    end

    def host
      @config[:host]
    end

    def client_id
      @config[:client_id]
    end

    def logger
      @config[:logger]
    end

    def configured?
      !!(host && client_id)
    end

    def submit_url
      File.join(host, 'profile_data')
    end
  end
end

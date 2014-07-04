require 'rails/generators'

module Corn
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      def do_config
        create_file "config/initializers/corn_config.rb", <<-RUBY
Corn.config({
              :logger => Rails.logger,
              # :client_id => ENV["CORN_CLIENT_ID"],
              # :slow_request_threshold => 5,
              # :sampling_interval => 0.1,
              # :post_interval => 2,
              # :profiling => true,
            })

Rails.configuration.middleware.use(Corn.rack_middleware)
RUBY
      end
    end
  end
end

require 'test_helper'

class IntegrationTest < Test::Unit::TestCase
  def setup
    Corn.config(:host => "http://localhost:3000",
                :client_id => '27786890f1c10131bb0e28cfe91ef737',
                :slow_request_threshold => 1,
                :fast_request_threshold => lambda { Corn.slow_request_threshold.to_f / 5 },
                :profiling => true,
                :sampling_interval => 0.01,
                :post_interval => 0.1,
                :post_fast_request_interval => 5, #seconds
                :fast_request_sampling_limit => 1024 * 1024 * 2 #2MB
                )
    @app = Corn.rack_middleware.new(TestApp.new)
    @index = 0
  end

  def test_profiling
    @app.call(env.merge('sleep' => 6))
    10.times do
      @app.call(env.merge('sleep' => 0.1))
    end
    sleep 10
    @app.call(env.merge('sleep' => 0.1))
    sleep 10
    # assert no error
  end

  def env
    {
      'REQUEST_METHOD' => 'POST',
      'PATH_INFO' => "/hello/#{@index += 1}",
      'HTTP_HOST' => 'http://cornapp.com',
      'QUERY_STRING' => 'world=index'
    }
  end
end

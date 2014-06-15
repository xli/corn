require 'test_helper'

class CornTest < Test::Unit::TestCase
  def setup
    @server = WEBrick::HTTPServer.new(:Port => '1234', :Logger => WEBrick::Log.new("/dev/null"), :AccessLog => [])
    @benchmarks = []
    @server.mount_proc '/profile_data' do |req, res|
      @benchmarks << req.query
    end
    Thread.start do
      @server.start
    end
    Corn.config(:host => "http://localhost:1234", :client_id => 'cci')
  end

  def teardown
    @server.shutdown
  end

  def test_rack_slow_request_profiler_should_ignore_fast_request
    @app = lambda do |env|
      sleep env['sleep']
    end
    @corn_rack = Corn::Rack::SlowRequestProfiler.new(@app)
    thread1 = Thread.start do
      @corn_rack.call({'PATH_INFO' => '/hello', 'sleep' => 0.1})
    end

    thread2 = Thread.start do
      @corn_rack.call({'PATH_INFO' => '/world', 'sleep' => 0.2})
    end
    thread1.join
    thread2.join
    sleep 3
    assert_equal 0, @benchmarks.size
  ensure
    @corn_rack.terminate
  end

  def test_rack_slow_request_profiler
    @app = lambda do |env|
      sleep env['sleep']
    end
    @corn_rack = Corn::Rack::SlowRequestProfiler.new(@app, 1)
    thread1 = Thread.start do
      @corn_rack.call({'PATH_INFO' => '/hello', 'sleep' => 1.5})
    end

    thread2 = Thread.start do
      @corn_rack.call({'PATH_INFO' => '/world', 'sleep' => 1.6})
    end
    thread1.join
    thread2.join
    sleep 3
    assert_equal 2, @benchmarks.size
    assert_equal 'cci', @benchmarks[0]['client_id']
    assert_match /\/hello/, @benchmarks[0]['name']

    assert @benchmarks[0]['data'].length > 4
    assert_match /#{File.basename(__FILE__)}:42/, @benchmarks[0]['data']
    assert_match /#{File.basename(__FILE__)}:46/, @benchmarks[0]['data']
  ensure
    @corn_rack.terminate
  end
end

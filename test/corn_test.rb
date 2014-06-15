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
    ENV['CORN_HOST'] = "http://localhost:1234"
    ENV['CORN_CLIENT_ID'] = 'cci'
  end

  def teardown
    @server.shutdown
  end

  def test_rack_slow_request_profiler_should_ignore_fast_request
    @app = lambda do |env|
      sleep 0.2
    end
    @corn_rack = Corn::Rack::SlowRequestProfiler.new(@app)
    thread1 = Thread.start do
      @corn_rack.call({'PATH_INFO' => '/hello'})
    end

    thread2 = Thread.start do
      @corn_rack.call({'PATH_INFO' => '/world'})
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
      sleep 2
    end
    @corn_rack = Corn.rack_slow_request_profiler.new(@app, 1)
    thread1 = Thread.start do
      @corn_rack.call({'PATH_INFO' => '/hello'})
    end

    thread2 = Thread.start do
      @corn_rack.call({'PATH_INFO' => '/world'})
    end
    thread1.join
    thread2.join
    sleep 2
    assert_equal 2, @benchmarks.size
    assert_equal 'cci', @benchmarks[0]['client_id']
    assert_match /\/hello/, @benchmarks[0]['name']

    assert @benchmarks[0]['data'].length > 10
    assert @benchmarks[0]['data'] =~ /#{File.basename(__FILE__)}:43/
    assert @benchmarks[0]['data'] =~ /#{File.basename(__FILE__)}:47/
  ensure
    @corn_rack.terminate
  end
end

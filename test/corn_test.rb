require 'test_helper'

class CornTest < Test::Unit::TestCase
  def setup
    @server = WEBrick::HTTPServer.new(:Port => '1234', :Logger => WEBrick::Log.new("/dev/null"), :AccessLog => [])
    @benchmarks = []
    @server.mount_proc '/profiling_data' do |req, res|
      @benchmarks << req.query
    end
    Thread.start do
      @server.start
    end
    Corn.config(:host => "http://localhost:1234", :client_id => 'cci')
  end

  def teardown
    @server.shutdown
    Corn.config(:host => nil, :client_id => nil)
  end

  def test_rack_slow_request_profiler_should_ignore_fast_request
    @app = TestApp.new
    @corn_rack = Corn.rack_slow_request_profiler.new(@app)
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
    @app = TestApp.new
    before_start_time = Time.parse(Time.now.iso8601)
    Corn.config(:slow_request_threshold => 1,
                :sampling_interval => 0.1,
                :post_interval => 1)
    @corn_rack = Corn.rack_slow_request_profiler.new(@app)
    begin
      thread1 = Thread.start do
        @corn_rack.call({'PATH_INFO' => '/hello', 'sleep' => 1.5})
      end

      thread2 = Thread.start do
        @corn_rack.call({'PATH_INFO' => '/world', 'sleep' => 1.6})
      end
      thread1.join
      thread2.join
      after_start_time = Time.now
      sleep 3
      assert_equal 2, @benchmarks.size
      assert_equal 'cci', @benchmarks[0]['client_id']
      assert_match /\/hello/, @benchmarks[0]['report[name]']
      assert @benchmarks[0]['report[end_at]']
      start_time = Time.parse(@benchmarks[0]['report[start_at]'])
      assert start_time >= before_start_time, "#{start_time} >= #{before_start_time}"
      assert start_time <= after_start_time, "#{start_time} <= #{after_start_time}"

      assert @benchmarks[0]['data'].length > 4
      assert_match /test_app.rb:3/, @benchmarks[0]['data']
      assert_match /test_app.rb:7/, @benchmarks[0]['data']
    ensure
      @corn_rack.terminate
    end
  end
end

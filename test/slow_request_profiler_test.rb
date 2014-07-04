require 'test_helper'

class SlowRequestProfilerTest < Test::Unit::TestCase
  def setup
    @port = '1235'
    @host = "http://localhost:#{@port}"
    @server = WEBrick::HTTPServer.new(:Port => @port, :Logger => WEBrick::Log.new("/dev/null"), :AccessLog => [])
    @benchmarks = []
    @server.mount_proc '/profiling_data' do |req, res|
      @benchmarks << req.query
    end
    Thread.start do
      @server.start
    end
  end

  def teardown
    @server.shutdown
    Corn.config(:host => nil, :client_id => nil)
  end

  def test_should_do_nothing_when_not_configured
    before_tc = Thread.list.size
    profiler = Corn.rack_slow_request_profiler.new(TestApp.new)
    profiler.call({'sleep' => 0.1})
    assert_equal before_tc, Thread.list.size
  end

  def test_profiling_should_be_togglable
    Corn.config(:host => @host, :client_id => 'cci')
    @profiling = true
    Corn.config(:profiling => lambda { @profiling },
                :slow_request_threshold => 0.1,
                :sampling_interval => 0.01,
                :post_interval => 0.01)
    profiler = Corn.rack_slow_request_profiler.new(TestApp.new)
    begin
      profiler.call({'sleep' => 0.15})
      sleep 0.1 # wait for posting data
      assert_equal 1, @benchmarks.size

      @profiling = false
      profiler.call({'sleep' => 0.15})
      sleep 0.1 # wait for posting data
      assert_equal 1, @benchmarks.size
    ensure
      profiler.terminate
    end
  end
end

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

  def test_profiling_and_stop
    prof = Corn.profiler('uniq report name')
    prof.profile do
      sleep 0.2
    end
    prof.terminate

    assert_equal 1, @benchmarks.size
    assert_equal 'cci', @benchmarks[0]['client_id']
    assert_equal 'uniq report name', @benchmarks[0]['name']
    assert @benchmarks[0]['data'].length > 100
    assert @benchmarks[0]['data'] =~ /#{File.basename(__FILE__)}/
  end

  def test_corn_rack_middleware
    @app = lambda do |env|
      sleep 0.2
    end
    @corn_rack = Corn::Rack.new(@app, 'rack report name',
                                sampling_interval=0.1,
                                output_interval=0.1)
    thread1 = Thread.start do
      @corn_rack.call({})
    end

    thread2 = Thread.start do
      @corn_rack.call({})
    end
    thread1.join
    thread2.join

    assert_equal 1, @benchmarks.size
    assert_equal 'cci', @benchmarks[0]['client_id']
    assert_equal 'rack report name', @benchmarks[0]['name']

    assert @benchmarks[0]['data'].length > 10
    assert @benchmarks[0]['data'] =~ /#{File.basename(__FILE__)}:43/
    assert @benchmarks[0]['data'] =~ /#{File.basename(__FILE__)}:47/
  ensure
    @corn_rack.terminate
  end
end

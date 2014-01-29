require 'test_helper'
require 'cgi'

class TestUnitTest < Test::Unit::TestCase
  class MiniRunner
    def info_signal
      false
    end

    def record(*args)
    end

    def puke(*args)
    end
    def options
      {}
    end
  end

  def setup
    @server = WEBrick::HTTPServer.new(:Port => '1234', :Logger => WEBrick::Log.new("/dev/null"), :AccessLog => [])
    @benchmarks = []
    @server.mount_proc '/benchmarks' do |req, res|
      @benchmarks << CGI::parse(req.body)
    end
    Thread.start do
      @server.start
    end
    ENV['CORN_HOST'] = "http://localhost:1234"
    ENV['CORN_CLIENT_ID'] = 'cci'
    ENV['CORN_BUILD_ID'] = 'cbi'
  end

  def teardown
    @server.shutdown
  end

  def test_benchmark_setup_test_method_and_teardown
    runner = MiniRunner.new
    test_case = Class.new(MiniTest::Unit::TestCase) do
      include Corn::MiniTest
      def test_x
      end
    end
    assert_equal '.', test_case.new('test_x').run(runner)

    assert_equal 1, @benchmarks.size
    assert_equal ['cci'], @benchmarks[0]['client_id']
    assert_equal ['cbi'], @benchmarks[0]['build_id']
    assert_equal ['test_x()'], @benchmarks[0]['test_name']
    assert_equal 3, @benchmarks[0]['reports[]'].size
  end
end

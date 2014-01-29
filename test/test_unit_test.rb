require 'test_helper'
require 'test/unit/testresult'
require 'cgi'

class TestUnitTest < Test::Unit::TestCase
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
    result = Test::Unit::TestResult.new
    test_case = Class.new(Test::Unit::TestCase) do
      include Corn::TestUnit
      def test_x
      end
    end
    test_case.suite.run(result) {|channel, value|}
    assert result.passed?
    assert_equal 1, result.run_count
    assert_equal 1, @benchmarks.size
    assert_equal ['cci'], @benchmarks[0]['client_id']
    assert_equal ['cbi'], @benchmarks[0]['build_id']
    assert_equal ['test_x()'], @benchmarks[0]['labels[]']
    assert_equal 3, @benchmarks[0]['reports[]'].size
  end
end
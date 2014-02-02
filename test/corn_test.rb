require 'test_helper'
require 'cgi'

class CornTest < Test::Unit::TestCase
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
  end

  def teardown
    @server.shutdown
  end

  def test_create_record_and_submit_report
    Corn.create_report('hello world')
    Corn.report(:action1) do
      Corn.report(:sub1) do
        sleep 0.01
      end
    end
    Corn.report.record_start(:action2) do
      sleep 0.01
    end
    Corn.report.record_end
    Corn.submit

    assert_equal 1, @benchmarks.size
    assert_equal ['cci'], @benchmarks[0]['client_id']
    assert_equal ['hello world'], @benchmarks[0]['report[name]']

    reports = CSV.parse(@benchmarks[0]['report[records]'].first)
    assert_equal 3, reports.size

    assert_equal 'action1', reports[0][0]
    assert_equal 'action1.sub1', reports[1][0]
    assert_equal 'action2', reports[2][0]
  end
end

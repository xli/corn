require 'test_helper'
require 'cgi'
require 'fileutils'

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

  def test_create_record_and_submit_report
    Corn.start('/tmp/profile.txt')
    sleep 0.2
    Corn.submit("uniq report name")

    assert_equal 1, @benchmarks.size
    assert_equal 'cci', @benchmarks[0]['client_id']
    assert_equal 'uniq report name', @benchmarks[0]['name']
    assert @benchmarks[0]['data'].length > 100
    assert @benchmarks[0]['data'] =~ /#{File.basename(__FILE__)}/
  ensure
    FileUtils.rm_rf('/tmp/profile.txt')
  end

  def test_should_submit_with_report_runtime
    Corn.start('/tmp/profile.txt')
    sleep 0.2
    Corn.submit("uniq report name")

    assert_equal 1, @benchmarks.size
    assert_equal 'cci', @benchmarks[0]['client_id']
    assert_equal 'uniq report name', @benchmarks[0]['name']

    runtime = @benchmarks[0]['runtime'].to_f
    assert runtime > 0
    assert runtime < 0.3
  end
end

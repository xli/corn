require 'test_helper'

class RackRequestEnvTest < Test::Unit::TestCase
  include Corn::Rack

  def test_record_start_time
    re = RequestEnv.new({})
    assert re.to_report['report[start_at]']
  end

  def test_report_name_should_include_path_info
    start_time = Time.now
    re = RequestEnv.new({'PATH_INFO' => '/path'}, start_time)
    assert_equal('/path', re.to_report['report[name]'])
  end

  def test_report_name_should_include_http_host
    start_time = Time.now
    re = RequestEnv.new({'PATH_INFO' => '/path2',
                          'HTTP_HOST' => 'localhost'},
                        start_time)
    assert_equal('localhost/path2', re.to_report['report[name]'])
  end

  def test_report_name_should_include_request_method
    start_time = Time.now
    re = RequestEnv.new({'REQUEST_METHOD' => 'GET',
                          'PATH_INFO' => '/path2',
                          'HTTP_HOST' => 'localhost'},
                        start_time)
    assert_equal('GET localhost/path2', re.to_report['report[name]'])
  end

  def test_report_name_with_empty_query_string
    start_time = Time.now
    re = RequestEnv.new({'PATH_INFO' => '/path2',
                          'HTTP_HOST' => 'localhost',
                          'QUERY_STRING' => ''},
                        start_time)
    assert_equal 'localhost/path2', re.to_report['report[name]']
  end

  def test_to_report
    start_time = Time.now
    re = RequestEnv.new({'PATH_INFO' => '/path2',
                          'HTTP_HOST' => 'localhost',
                          'QUERY_STRING' => 'hello=world'},
                        start_time)
    rep = re.to_report
    assert_equal 'localhost/path2?hello=world', rep['report[name]']
    assert_equal start_time.iso8601, rep['report[start_at]']
    assert rep['report[end_at]']
  end

end

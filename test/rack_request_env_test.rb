require 'test_helper'

class RackRequestEnvTest < Test::Unit::TestCase
  include Corn::Rack

  def test_record_start_time
    re = RequestEnv.new({}, 1)
    assert re.start_time
  end

  def test_slow_request
    re = RequestEnv.new({}, 0.1)
    assert !re.slow_request?
    sleep 0.11
    assert re.slow_request?
  end

  def test_report_name_should_include_path_info
    re = RequestEnv.new({'PATH_INFO' => '/path'}, 0.1)
    assert_equal '/path', re.report_name
  end

  def test_report_name_should_include_http_host
    re = RequestEnv.new({'PATH_INFO' => '/path2',
                          'HTTP_HOST' => 'localhost'},
                        0.1)
    assert_equal 'localhost/path2', re.report_name
  end

  def test_report_name_should_include_query_string
    re = RequestEnv.new({'PATH_INFO' => '/path2',
                          'HTTP_HOST' => 'localhost',
                          'QUERY_STRING' => 'hello=world'},
                        0.1)
    assert_equal 'localhost/path2?hello=world', re.report_name
  end

  def test_report_name_with_empty_query_string
    re = RequestEnv.new({'PATH_INFO' => '/path2',
                          'HTTP_HOST' => 'localhost',
                          'QUERY_STRING' => ''},
                        0.1)
    assert_equal 'localhost/path2', re.report_name
  end
end

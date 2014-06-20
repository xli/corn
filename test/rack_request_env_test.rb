require 'test_helper'

class RackRequestEnvTest < Test::Unit::TestCase
  include Corn::Rack

  def test_record_start_time
    re = RequestEnv.new({})
    assert re.to_h[:start_time]
  end

  def test_to_h_should_include_path_info
    start_time = Time.now
    re = RequestEnv.new({'PATH_INFO' => '/path'}, start_time)
    expected = {
      :path_info => '/path',
      :start_time => start_time
    }
    assert_equal(expected, re.to_h)
  end

  def test_to_h_should_include_http_host
    start_time = Time.now
    re = RequestEnv.new({'PATH_INFO' => '/path2',
                          'HTTP_HOST' => 'localhost'},
                        start_time)
    expected = {
      :http_host => 'localhost',
      :path_info => '/path2',
      :start_time => start_time
    }
    assert_equal(expected, re.to_h)
  end

  def test_report_name_should_include_query_string
    start_time = Time.now
    re = RequestEnv.new({'PATH_INFO' => '/path2',
                          'HTTP_HOST' => 'localhost',
                          'QUERY_STRING' => 'hello=world'},
                        start_time)
    expected = {
      :http_host => 'localhost',
      :path_info => '/path2',
      :query_string => 'hello=world',
      :start_time => start_time
    }
    assert_equal expected, re.to_h
  end

  def test_report_name_with_empty_query_string
    start_time = Time.now
    re = RequestEnv.new({'PATH_INFO' => '/path2',
                          'HTTP_HOST' => 'localhost',
                          'QUERY_STRING' => ''},
                        start_time)
    expected = {
      :http_host => 'localhost',
      :path_info => '/path2',
      :start_time => start_time
    }
    assert_equal expected, re.to_h
  end
end

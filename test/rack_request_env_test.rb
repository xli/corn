require 'test_helper'

class RackRequestEnvTest < Test::Unit::TestCase
  include Corn::Rack

  def test_record_start_time
    re = RequestEnv.new(1)
    assert_nil re.start_time
    re.record({}) do
      assert re.start_time
    end
    assert_nil re.start_time
  end

  def test_slow_request
    re = RequestEnv.new(0.1)
    re.record({}) do
      assert !re.slow_request?
      sleep 0.11
      assert re.slow_request?
    end
  end

  def test_report_name
    re = RequestEnv.new(0.1)
    assert_equal '', re.report_name
    re.record({'PATH_INFO' => '/path'}) do
      assert_equal '/path', re.report_name
    end
    re.record({'PATH_INFO' => '/path2', 'HTTP_HOST' => 'localhost'}) do
      assert_equal 'localhost/path2', re.report_name
    end
    assert_equal '', re.report_name
  end
end

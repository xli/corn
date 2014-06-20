require 'test_helper'

class SlowRequestProfilerTest < Test::Unit::TestCase
  def test_should_do_nothing_when_not_configured
    before_tc = Thread.list.size
    profiler = Corn.rack_slow_request_profiler.new(app)
    profiler.call({'sleep' => 0.1})
    assert_equal before_tc, Thread.list.size
  end

  def app
    lambda do |env|
      sleep env['sleep']
    end
  end
end

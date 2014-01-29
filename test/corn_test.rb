require 'test_helper'

class CornTest < Test::Unit::TestCase
  def test_reporter
    reports = []
    r = Corn.reporter(reports)
    r.call('label1') { sleep 0.01 }
    r.call('label2') { sleep 0.01 }
    assert_equal 2, reports.size
    assert_equal 'label1', reports[0][0]
    assert_equal 'label2', reports[1][0]
  end
end

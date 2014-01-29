require 'test_helper'

class CornTest < Test::Unit::TestCase
  def test_report_record
    report = Corn.report_start
    report.record('label1') {sleep 0.01}
    report.record('label2') {sleep 0.01}
    assert_equal 2, report.records.size
    assert_equal 'label1', report.records[0][0]
    assert report.records[0][2] > 0
    assert_equal 'label2', report.records[1][0]
  end
end

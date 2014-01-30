require 'test_helper'

class ReportTest < Test::Unit::TestCase
  def test_empty_report
    rep = Corn::Report.new
    assert_equal [], rep.to_a
  end

  def test_record
    rep = Corn::Report.new
    start_at = Time.now
    rep.record(:action) do
      sleep 0.01
    end
    end_at = Time.now

    data = rep.to_a
    assert_equal 1, data.size
    action, action_start, time = data[0]
    assert_equal :action, action
    assert action_start >= start_at && action_start <= end_at
    assert time >= 0.01 && time <= (end_at - start_at)
  end

  def test_records
    rep = Corn::Report.new
    rep.record(:action1) do
      sleep 0.01
    end
    rep.record(:action2) do
      sleep 0.01
    end

    action1, action2 = rep.to_a
    assert_equal 3, action1.size
    assert_equal 3, action2.size
    assert_equal :action1, action1[0]
    assert_equal :action2, action2[0]
  end

  def test_record_with_sub_report
    rep = Corn::Report.new
    rep.record(:action1) do |sub_rep|
      sub_rep.record(:sub1) do
        sleep 0.01
      end
    end
    rep.record(:action2) do |sub_rep|
      sub_rep.record(:sub2) do
        sleep 0.01
      end
      sub_rep.record(:sub3) do
        sleep 0.01
      end
    end
    data = rep.to_a
    assert_equal 5, data.size
    assert_equal :action1, data[0][0]
    assert_equal :'action1.sub1', data[1][0]
    assert_equal :action2, data[2][0]
    assert_equal :'action2.sub2', data[3][0]
    assert_equal :'action2.sub3', data[4][0]
  end

  def test_to_csv
    rep = Corn::Report.new
    rep.record(:action1) do
      sleep 0.01
    end
    rep.record(:action2) do
      sleep 0.01
    end
    records = rep.to_csv.split("\n")
    assert_equal 2, records.size
    assert_equal 'action1', records[0].split(',')[0]
    assert_equal 'action2', records[1].split(',')[0]
  end

  def test_empty?
    rep = Corn::Report.new
    assert rep.empty?
    rep.record(:action1) do
      sleep 0.01
    end
    assert !rep.empty?
  end
end

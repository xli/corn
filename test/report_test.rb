require 'test_helper'

class ReportTest < Test::Unit::TestCase
  def test_empty_report
    rep = Corn::Report.new('name')
    assert_equal [], rep.to_a
  end

  def test_report_name
    rep = Corn::Report.new('name')
    assert_equal 'name', rep.name
  end

  def test_record
    rep = Corn::Report.new('name')
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
    rep = Corn::Report.new('name')
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
    rep = Corn::Report.new('name')
    rep.record(:action1) do
      rep.record(:sub1) do
        sleep 0.01
      end
    end
    rep.record(:action2) do
      rep.record(:sub2) do
        sleep 0.01
      end
      rep.record(:sub3) do
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

  def test_record_start_and_stop
    rep = Corn::Report.new('name')
    rep.record_start(:action1)
    assert rep.empty?
    rep.record_start(:action2)
    assert rep.empty?
    rep.record_end

    assert_equal 1, rep.to_a.size
    assert_equal :'action1.action2', rep.to_a[0][0]

    rep.record_end
    assert_equal 2, rep.to_a.size
    assert_equal :'action1', rep.to_a[0][0]
    assert_equal :'action1.action2', rep.to_a[1][0]

    rep.record_start(:action3)
    rep.record_end
    assert_equal 3, rep.to_a.size
    assert_equal :'action3', rep.to_a[2][0]

    assert_raise Corn::Report::RecordNotStartError do
      rep.record_end
    end
  end

  def test_to_csv
    rep = Corn::Report.new('name')
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
    rep = Corn::Report.new('name')
    assert rep.empty?
    rep.record(:action1) do
      sleep 0.01
    end
    assert !rep.empty?
  end
end

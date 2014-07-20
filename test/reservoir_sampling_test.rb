require 'test_helper'

class ReservoirSamplingTest < Test::Unit::TestCase
  def test_sampling_by_limit
    limit = 10 #byte size
    sampling = Corn::ReservoirSampling.new(limit)
    15.times do |index|
      sampling << {:data => index.to_s, :id => index}
    end
    assert_equal 10, sampling.items.size
    ids = sampling.items.map{|d|d[:id]}
    assert_not_equal [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], ids

    5.times do |index|
      index = index + 15
      sampling << {:data => index.to_s, :id => index}
    end
    assert_equal 10, sampling.items.size
    ids = sampling.items.map{|d|d[:id]}
    assert_not_equal [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], ids
  end
end

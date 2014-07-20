require 'test_helper'

class PostTest < Test::Unit::TestCase
  def setup
    @server = WEBrick::HTTPServer.new(:Port => '1236', :Logger => WEBrick::Log.new("/dev/null"), :AccessLog => [])
    @data = []
    @server.mount_proc '/profiling_data' do |req, res|
      d = parse_form_data(req.body)
      @data << d
    end
    @t = Thread.start do
      @server.start
    end
    Corn.config(:host => "http://localhost:1236")
    @post = Corn::Post.new(0.01, 10, 0.5)
  end

  def teardown
    @post.terminate
    @server.shutdown
    @t.join
  end

  def test_post
    @post.enqueue(:action => :post, :data => 'hello')
    @post.enqueue(nil)
    @post.enqueue(:action => :post, :data => 'world')
    @post.enqueue(:action => :post, :data => '!')
    sleep 0.15
    assert_equal 3, @data.size
    assert_equal(["hello", "world", "!"], @data.map{|d| d["reports[][data]"]})
  end

  def test_sampling_data_and_post
    @post.enqueue(:action => :post, :data => 'hello')
    20.times do |i|
      @post.enqueue(:action => :sampling, :data => i.to_s)
    end
    sleep 0.5
    @post.enqueue(:action => :sampling, :data => '!')
    sleep 0.1
    assert_equal 2, @data.size

    assert_equal 'hello', @data[0]['reports[][data]']
    assert_equal 10, @data[1]['reports[][data]'].size
  end

  def test_sampling_data_should_be_reset_after_posted
    20.times do |i|
      @post.enqueue(:action => :sampling, :data => i.to_s)
    end
    sleep 0.5
    @post.enqueue(:action => :sampling, :data => '!')
    sleep 0.1

    @data.clear
    @post.enqueue(:action => :sampling, :data => 'new data')
    sleep 0.5
    @post.enqueue(:action => :sampling, :data => 'new data 2')
    sleep 0.1
    assert_equal 1, @data.size
    assert_equal 2, @data[0]['reports[][data]'].size
    assert_equal 'new+data', @data[0]['reports[][data]'][0]
    assert_equal 'new+data+2', @data[0]['reports[][data]'][1]
  end
end

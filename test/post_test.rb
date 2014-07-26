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
    @post = Corn::Post.new(0.01)
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
    assert_equal nil, @data[0]['type']
    assert_equal nil, @data[1]['type']
    assert_equal nil, @data[2]['type']
    assert_equal(["hello", "world", "!"], @data.map{|d| d["reports[][data]"]})
  end
end

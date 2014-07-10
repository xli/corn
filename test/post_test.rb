require 'test_helper'

class PostTest < Test::Unit::TestCase
  def setup
    @server = WEBrick::HTTPServer.new(:Port => '1236', :Logger => WEBrick::Log.new("/dev/null"), :AccessLog => [])
    @data = []
    @server.mount_proc '/profiling_data' do |req, res|
      @data << req.query
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
    @post.enqueue(:data => 'hello')
    @post.enqueue(nil)
    @post.enqueue(:data => 'world')
    @post.enqueue(:data => '!')
    sleep 0.2
    assert_equal 3, @data.size
    assert_equal(["hello", "world", "!"], @data.map{|d| d["data"]})
  end
end

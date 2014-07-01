require 'test_helper'

class ConfigTest < Test::Unit::TestCase
  class App1
    include Corn::Config
    config({
             :a => 'hello',
             :b => false,
             :c => nil
           })
  end
  class App2; end
  class App3; end
  class App4; end
  class App5; end
  class App6; end

  def test_default_config
    assert_equal 'hello', App1.a
    assert_equal false, App1.b?
    assert_equal nil, App1.c
  end

  def test_override_config
    config_class(App2)
    App2.config(:a => 'world')
    assert_equal 'world', App2.a
    App2.config(:a => nil)
    assert_nil App2.a
    App2.config(:c => 'hi')
    assert_equal 'hi', App2.c
    App2.config(:b => true, :c => 'foo')
    assert_equal true, App2.b?
    assert_equal 'foo', App2.c
  end

  def test_config
    config_class(App3)
    assert_equal({:a => 'hello', :b => false, :c => nil}, App3.config)
    App3.config(:a => 'world')
    assert_equal({:a => 'world', :b => false, :c => nil}, App3.config)
  end

  def test_isolate
    config_class(App4)
    config_class(App5)
    App4.config(:a => 'foo')
    assert_equal 'foo', App4.a
    assert_equal 'hello', App5.a
  end

  def test_configure_by_lambda
    App6.send(:include, Corn::Config)
    App6.config({ :a => lambda { 'hello' }})
    assert_equal 'hello', App6.a
  end

  def config_class(klass)
    klass.send(:include, Corn::Config)
    klass.config({
                   :a => 'hello',
                   :b => false,
                   :c => nil
                 })
  end
end

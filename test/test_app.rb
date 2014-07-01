class TestApp
  def call(env)
    do_sleep env['sleep']
  end

  def do_sleep(time)
    sleep(time)
  end
end

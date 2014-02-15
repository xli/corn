module Corn
  class Rack
    def initialize(app, report_name='Corn::Rack')
      @app = app
      @report_name = report_name
    end

    def call(env)
      if Corn.configured? && env["QUERY_STRING"] =~ /corn_profiling=true/
        profile do
          @app.call(env)
        end
      else
        @app.call(env)
      end
    end

    def profile(&block)
      Corn.start(Rails.root.join('tmp', "corn_rack.tmp.#{Thread.current.object_id}"))
      yield
    ensure
      Corn.submit(@report_name)
    end

  end
end

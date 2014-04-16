module Corn
  class Rack
    def initialize(app,
                   report_name="Corn::Rack created at #{Time.now}",
                   sampling_interval=0.1,
                   output_interval=nil)
      @app = app
      @prof = Corn.profiler(report_name, sampling_interval, output_interval)
      at_exit { terminate }
    end

    def call(env)
      if Corn.configured?
        @prof.profile do
          @app.call(env)
        end
      else
        @app.call(env)
      end
    end

    def terminate
      @prof.terminate
    end
  end
end

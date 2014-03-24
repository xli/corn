module Corn
  class Rack
    def initialize(app,
                   report_name="Corn::Rack created at #{Time.now}",
                   output_interval=nil)
      @app = app
      @prof = SamplingProf.new(0.1, true) do |data|
        Corn.post(StringIO.new(data), report_name)
      end
      if output_interval
        @prof.output_interval = output_interval
      end
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

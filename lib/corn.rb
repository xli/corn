require 'sampling_prof'

module Corn
  module_function

  def host
    ENV['CORN_HOST']
  end

  def client_id
    ENV['CORN_CLIENT_ID']
  end

  def configured?
    !!(host && client_id)
  end

  def create_prof(period, output)
    SamplingProf.new(period).tap do |prof|
      prof.output_file = output if output
    end
  end

  def start(output=nil, period=0.1)
    @prof ||= create_prof(period, output)
    @prof.start
  end

  def submit(name)
    @prof.stop
    if configured?
      o = `curl -s -F data=@#{@prof.output_file.inspect} -F client_id=#{client_id.inspect} -F name=#{name.inspect} #{submit_url}`
      if $?.exitstatus != 0
        log("Submit report error: \n#{o}")
      end
    else
      log("No CORN_CLIENT_ID configured, profiling data is not submitted")
    end
  end

  def submit_url
    File.join(host, 'profile_data')
  end

  def log(msg)
    $stderr.puts msg
  end
end

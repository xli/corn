require 'sampling_prof'
require 'net/http'
require 'net/https'
require 'net/http/post/multipart'
require 'corn/rack'

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
    @prof_start_at = Time.now
  end

  def submit(name)
    runtime, @prof_start_at = (Time.now - @prof_start_at), nil
    @prof.stop
    if configured?
      upload(@prof.output_file, name, runtime)
    else
      log("No CORN_CLIENT_ID or CORN_HOST configured, profiling data is not submitted")
    end
  end

  def submit_url
    File.join(host, 'profile_data')
  end

  def log(msg)
    $stderr.puts msg
  end

  def upload(file, name, runtime)
    url = URI.parse(submit_url)
    File.open(file) do |f|
      req = Net::HTTP::Post::Multipart.new(url.path,
                                           "data" => UploadIO.new(f, "text/plain"),
                                           'client_id' => client_id,
                                           'name' => name,
                                           'runtime' => runtime)
      res = Net::HTTP.start(url.host, url.port) do |http|
        http.use_ssl = url.scheme == 'https'
        http.request(req)
      end
    end
    log("Corn report submitted to #{submit_url}")
  rescue Exception => e
    log("upload #{file} to #{submit_url} failed: #{e.message}")
    log(e.backtrace.join("\n"))
  end
end

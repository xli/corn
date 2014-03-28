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

  def create_prof(sampling_interval, output)
    SamplingProf.new(sampling_interval).tap do |prof|
      prof.output_file = output if output
    end
  end

  def start(output=nil, sampling_interval=0.1)
    @prof ||= create_prof(sampling_interval, output)
    @prof.start
  end

  def submit(name)
    @prof.stop
    if configured?
      upload(@prof.output_file, name)
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

  def upload(file, name)
    File.open(file) do |f|
      post(UploadIO.new(f, 'text/plain', File.basename(f.path)), name)
    end
  end

  def post(data, name)
    url = URI.parse(submit_url)
    req = Net::HTTP::Post::Multipart.new(url.path,
                                         "data" => data,
                                         'client_id' => client_id,
                                         'name' => name)
    res = Net::HTTP.start(url.host, url.port) do |http|
      http.use_ssl = url.scheme == 'https'
      http.request(req)
    end
    log("Corn report submitted to #{submit_url}")
  rescue Exception => e
    log("upload #{file} to #{submit_url} failed: #{e.message}")
    log(e.backtrace.join("\n"))
  end
end

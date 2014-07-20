require 'corn/post'
require 'sampling_prof'

module Corn
  class Profiler
    def initialize(post_interval, post_sampling_limit, post_sampling_time,
                   sampling_interval)
      @post = Post.new(post_interval, post_sampling_limit, post_sampling_time)
      @prof = SamplingProf.new(sampling_interval)
      at_exit { terminate }
    end

    def profile(handler, &block)
      @prof.profile(lambda {|data| @post.enqueue(handler.call(data))}, &block)
    end

    def terminate
      @prof.terminate rescue nil
      @post.terminate rescue nil
    end
  end
end

$LOAD_PATH << File.dirname(__FILE__) + '/../lib'
require 'test/unit'
require 'webrick'
require 'corn'
require 'cgi'
require 'fileutils'
require 'test_app'

def parse_form_data(body)
  URI.unescape(body).split("&").map do |f|
    f.split("=")
  end.inject({}) do |memo, kv|
    k, v = kv
    if memo.has_key?(k)
      if memo[k].is_a?(Array)
        memo[k] << v
      else
        memo[k] = [memo[k], v]
      end
    else
      memo[k] = v
    end
    memo
  end
end

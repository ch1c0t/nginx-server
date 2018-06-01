require 'securerandom'
require 'pathname'
require 'erb'
require 'suppress_output'

# Backport ERB#result_with_hash for Rubies older than 2.5.
unless ERB.method_defined? :result_with_hash
  class ERB
    def result_with_hash hash
      b = Object.new.send :binding
      hash.each do |key, value|
        b.local_variable_set key, value
      end
      result b
    end
  end
end

module Nginx
  class Server
    def initialize template,
      dir: "/tmp/nginx.#{Process.pid}.#{SecureRandom.uuid}", **vars
      @dir = Pathname dir; @dir.mkpath
      create_config template, vars
    end

    def start
      @nginx_pid = suppress_output do
        spawn "nginx -c nginx.conf -p #{@dir} -g 'daemon off;'"
      end; at_exit { stop }
      @nginx_pid
    end

    def stop
      `kill #{@nginx_pid}`
    end

    private
      def create_config template, vars
        string = ERB.new(IO.read template).result_with_hash(vars)
        IO.write "#{@dir}/nginx.conf", string
      end
  end
end

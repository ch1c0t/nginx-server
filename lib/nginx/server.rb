require 'securerandom'
require 'pathname'
require 'erb'
require 'suppress_output'

module Nginx
  class Server
    def initialize template,
      dir: "/tmp/nginx.#{Process.pid}.#{SecureRandom.uuid}"
      @dir = Pathname dir; @dir.mkpath
      create_config template
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

    def error_log
      'error.log'
    end

    def access_log
      'access.log'
    end

    def pid
      'nginx.pid'
    end

    def first_upstream
      "#{@dir}/first.sock"
    end

    private
      def create_config template
        string = ERB.new(IO.read template).result(binding)
        IO.write "#{@dir}/nginx.conf", string
      end
  end
end

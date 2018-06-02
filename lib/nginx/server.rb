require 'securerandom'
require 'pathname'
require 'erb'
require 'suppress_output'
require 'puma'

module Nginx
  def self.proxy &block
    config = Config.new block
    Proxy.from_file "#{__dir__}/proxy.conf.erb", **config
  end

  class Config
    def initialize dsl
      @maps = {}
      instance_exec &dsl
    end

    def to_hash
      {
        host: @host,
        port: @port,
        maps: @maps,
      }
    end

    def host host
      @host = host
    end

    def port port
      @port = port
    end

    def map matcher, app
      @maps[matcher] = app
    end
  end

  class Server
    def self.from_file file, **all
      new (IO.read file), **all
    end

    def initialize string,
      dir: "/tmp/nginx.#{Process.pid}.#{SecureRandom.uuid}", **params
      @dir = Pathname dir; @dir.mkpath
      set_params params
      create_config string
    end

    attr_reader :dir

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
      IO.read(pidfile).to_i
    end

    def pidfile
      'nginx.pid'
    end


    private
      def set_params params
        params.each do |key, value|
          define_singleton_method(key) { value }
        end
      end

      def create_config input
        output = ERB.new(input).result(binding)
        IO.write "#{@dir}/nginx.conf", output
      end
  end

  class Proxy < Server
    def start
      maps.each do |key, app|
        fork do
          server = Puma::Server.new app
          server.add_unix_listener socket_of key
          server.run
          sleep
        end
      end

      super
    end


    def socket_of key
      "#{@dir}/#{key}.sock"
    end

    def upstreams
      maps.keys.map do |key|
        <<-S
          upstream #{key} {
            server unix:#{socket_of key};
          }
        S
      end.join "\n\n"
    end

    def address
      if host
        "#{host}:#{port}"
      else
        port
      end
    end

    def locations
      maps.keys.map do |key|
        <<-S
          location /#{key}/ {
            proxy_pass http://#{key}/;
          }
        S
      end.join "\n\n"
    end
  end
end

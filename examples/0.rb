require 'nginx/server'

class Proxy < Nginx::Server
  def first_upstream
    "#{@dir}/first.sock"
  end
end

server = Proxy.new 'examples/nginx.conf.erb'
server.start
sleep

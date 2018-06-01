require 'nginx/server'

server = Nginx::Server.new 'examples/nginx.conf.erb'
server.start
sleep

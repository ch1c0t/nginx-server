require 'nginx/server'

server = Nginx::Server.new 'examples/nginx.conf.erb',
  error_log: 'error.log',
  access_log: 'access.log',
  pid: 'nginx.pid',
  first_upstream: 'first.sock'

server.start
sleep

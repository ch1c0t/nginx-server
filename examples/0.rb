require 'nginx/server'

Nginx::Server.new 'examples/0.erb', first: 'A', second: 'B'

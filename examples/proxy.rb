require 'nginx/server'
require 'hobby'

class First
  include Hobby
  get { 'Some first.' }
end

class Second
  include Hobby
  get { 'Some second.' }
end

server = Nginx.proxy do
  host '127.0.0.1'
  port 8080

  map :first, First.new
  map :second, Second.new
end

server.start
sleep

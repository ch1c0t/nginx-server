require 'suppress_output'
require 'erb'

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
    def initialize template, **vars
      template = ERB.new IO.read template
      puts template.result_with_hash vars
    end
  end
end

Gem::Specification.new do |g|
  g.name    = 'nginx-server'
  g.files   = `git ls-files`.split($/)
  g.version = '0.0.1'
  g.summary = 'Manage Nginx servers from Ruby.'
  g.authors = ['Anatoly Chernow']

  g.add_dependency 'suppress_output'
  g.add_dependency 'puma'
end

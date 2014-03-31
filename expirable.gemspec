Gem::Specification.new do |s|
  s.name        = 'expirable'
  s.version     = '1.0.1'
  s.date        = '2014-03-31'
  s.summary     = "Expirable"
  s.description = "Easily handle deadline-based workflow transitions in Rails"
  s.authors     = ["Brendan MacDonell"]
  s.email       = 'brendan@macdonell.net'
  s.files       = Dir.glob("lib/**/*") + %w(README.md)
  s.homepage    = 'http://rubygems.org/gems/expirable'
  s.license     = 'MIT'

  s.add_runtime_dependency 'rails', ['~> 4.0']
  s.add_runtime_dependency 'clockwork', ['~> 0.7']
  s.add_runtime_dependency 'delayed_job', ['~> 4.0']
end

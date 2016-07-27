require 'date'

Gem::Specification.new do |s|
  s.name = "orvibo-ruby"
  s.version = "0.0.0"
  s.date = Date.today
  s.summary = 'Ruby library to interface with Orvibo sockets'
  s.description = "A simple library to interface with Orvibo sockets"
  s.authors = ["Robert Saenz"]
  s.email = "robertsaenz@gmail.com"
  s.files = Dir['Rakefile', '{bin,lib,man,test,spec}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")
end

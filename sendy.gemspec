  # frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))

require "sendy/version"

Gem::Specification.new do |s|
  s.name = "sendy"
  s.version = Sendy::VERSION
  s.date = "2018-06-29"
  s.summary = "Ruby bindings for the Sendy API"
  s.author = "Sendy"


  s.add_development_dependency "rspec"
  s.files = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end

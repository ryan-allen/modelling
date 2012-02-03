# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'modelling/version'

Gem::Specification.new do |s|
  s.name        = 'modelling'
  s.version     = Modelling::VERSION
  s.authors     = ['Ryan Allen', 'Steve Hodgkiss', 'Mark Turnley', 'John Barton']
  s.email       = ['ryan@eden.cc', 'steve@hodgkiss.me', 'ravagedcarrot@gmail.com', 'jrbarton@gmail.com']
  s.homepage    = 'http://github.com/ryan-allen/modelling'
  s.summary     = %q{Wraps some common-ish plain-ruby object modelling junk.}
  s.description = %q{We were doing PORO dev on Rails before it was hip.}

  s.rubyforge_project = 'modelling'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  # specify any dependencies here; for example:
  # s.add_development_dependency 'rspec'
  s.add_runtime_dependency 'rspec'
end

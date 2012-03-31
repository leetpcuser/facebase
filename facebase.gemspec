$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "facebase/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "facebase"
  s.version = Facebase::VERSION
  s.authors = ["Timothy Cardenas"]
  s.email = ["trcarden@gmail.com"]
  s.homepage = "http://timcardenas.com"
  s.summary = "Comprehensive scalable user management gem for facebook enabled applications"
  s.description = "Events, emails, profiles, schedules, huge databases = facebase"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.2"
  s.add_dependency "mysql2"
  s.add_dependency "chronic"
  s.add_dependency "sass"
  s.add_dependency "actionmailer", "~> 3.2"
  s.add_dependency "aws-sdk", "~> 1.3.6"
  s.add_dependency "work_queue"
  s.add_dependency "will_paginate", '~> 3.0'
  s.add_dependency "jquery-rails", "~> 2.0.1"
  s.add_dependency "eventmachine", "~> 0.12.10"
  s.add_dependency "em-http-request", "~> 0.3.0"
  s.add_dependency "koala", "~> 1.4.0"
  s.add_dependency "resque", "~> 1.20.0"
  s.add_dependency "resque-scheduler", "~> 1.9.9"
  s.add_dependency "redis", "~> 2.2.2"

  s.add_development_dependency "sqlite3"
end

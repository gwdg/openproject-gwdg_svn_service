# encoding: UTF-8
$:.push File.expand_path("../lib", __FILE__)

require 'open_project/gwdg_svn_service/version'
# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "openproject-gwdg_svn_service"
  s.version     = OpenProject::GwdgSvnService::VERSION
  s.authors     = "GWDG"
  s.email       = "escience@gwdg.de"
  s.homepage    = "https://www.gwdg.de"  
  s.summary     = 'OpenProject GWDG Subversion Service'
  s.description = 'OpenProject GWDG Subversion Service plugin allows automatic creation of the repository for a project.'
  s.license     = "Apache License, Version 2.0"

  s.files = Dir["{app,config,db,lib}/**/*"] + %w(CHANGELOG.md README.md)

  s.add_dependency "rails", "~> 3.2.14"
end

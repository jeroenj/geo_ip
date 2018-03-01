# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name = 'geo_ip'
  s.version = '0.6.2'
  s.required_ruby_version = '>= 1.9.3'
  s.platform = Gem::Platform::RUBY
  s.authors = ['Jeroen Jacobs']
  s.email = 'gems@jeroenj.be'
  s.homepage = 'http://jeroenj.be'
  s.summary = 'Retreive the geolocation of an IP address based on the ipinfodb.com webservice'
  s.description = 'A call to the ipinfodb.com will be done to retreive the geolocation based on the IP address. No need to include a database file in the application.'

  s.files = Dir['README.md', 'CHANGES.md', 'LICENSE', 'lib/**/*']
  s.test_files = Dir.glob('spec/**/*')
  s.require_paths = ['lib']

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'webmock', '~> 2.3.2'
end

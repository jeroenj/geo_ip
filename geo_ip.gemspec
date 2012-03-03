# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'geo_ip'
  s.version     = '0.5.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Jeroen Jacobs']
  s.email       = 'gems@jeroenj.be'
  s.homepage    = 'http://jeroenj.be'
  s.summary     = 'Retreive the geolocation of an IP address based on the ipinfodb.com webservice'
  s.description = 'A call to the ipinfodb.com will be done to retreive the geolocation based on the IP address. No need to include a database file in the application.'

  s.files         = Dir['README.md', 'CHANGES.md', 'LICENSE', 'lib/**/*']
  s.test_files    = Dir.glob('spec/**/*')
  s.require_paths = ['lib']

  s.add_dependency 'json', '~> 1.4'
  s.add_dependency 'rest-client', '~> 1.6.1'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.5'
  s.add_development_dependency 'webmock', '~> 1.7.10'
end

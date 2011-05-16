# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'geo_ip_curb'
  s.version     = '0.3.2'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Ryan Conway', 'Jeroen Jacobs']
  s.email       = 'gems@jeroenj.be'
  s.homepage    = 'http://jeroenj.be'
  s.summary     = 'Retreive the geolocation of an IP address based on the ipinfodb.com webservice.
                  It is the same as Jeroen Jacobs\' gem, but uses the Curb gem, rather than Net::HTTP.'
  s.description = 'A call to the ipinfodb.com will be done to retreive the geolocation based on the IP address. No need to include a database file in the application.'

  s.files         = Dir['README.rdoc', 'CHANGES', 'LICENSE', 'lib/**/*']
  s.test_files    = Dir.glob('spec/**/*')
  s.require_paths = ['lib']

  s.add_dependency 'json', '~> 1.4.6'
  s.add_dependency 'curb', '~> 0.7.15'
  s.add_development_dependency 'rspec', '~> 2.5'
  s.add_development_dependency 'mocha', '~> 0.9.12'  
end

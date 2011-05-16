## 0.3.2

* Replaced Net::HTTP with Curb which handles DNS failure timeouts better.
* Added a timeout option to be passed when calling geolocation.
* Handle service failures gracefully.
* Added a test to ensure error handling of service failures works.

## 0.3.1 (in development)

* Switches to bundler for gem deployment
* Uses Rspec 2.x from now on

## 0.3.0

* Added support for API key requirement (Thanks to seanconaty and luigi)
* Explicit gem dependency for json and removed rubygems requirement (idris) (http://tomayko.com/writings/require-rubygems-antipattern)
* Removed deprecated GeoIp#remote_geolocation method

## 0.2.0

* Added support for timezone information. Use the optional {:timezone => true|false} option
* Added support for country lookup. This will result in a faster reply since less queries need
  to be done at ipinfodb's side. Use the optional {:precision => :city|:country} option
* API change: GeoIp.remote_geolocation(ip) is deprecated in favor of GeoIp.geolocation(ip)

## 0.1.1

* Removed time zone information since this has been deprecated with the service

## 0.1.0

* Initial commit

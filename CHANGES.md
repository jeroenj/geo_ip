## 0.6.0 (2015-09-21)

* Adds ruby 2.0, 2.1 and 2.2 to the Travis build matrix
* Drops support for ruby 1.8.7 and 1.9.2
* Improves formatting and fixes various rubocop (0.34.1) offencs
* Adds support for IPv6 addresses. By [dnswus](https://github.com/dnswus)

## 0.5.0 (2012-03-03)

* Wrap Ruby's Timeout module around the RestClient call to enforce timeout if caused by bad internet connection or slow or invalid DNS lookup. Added WebMock to tests to have reliable tests. By [harleyttd](https://github.com/harleyttd)

## 0.4.0 (2011-05-29)

* Uses API v3

## 0.3.2 (2011-05-20)

* Switches to [rest-client](https://github.com/adamwiggins/rest-client) for requests
* Sets default timeout to 1 second and adds option to override it
* More relaxed json dependency scoping
* Some internal code refactoring

## 0.3.1 (2011-03-26)

* Switches to bundler for gem deployment
* Uses Rspec 2.x from now on

## 0.3.0 (2010-11-16)

* Added support for API key requirement (Thanks to seanconaty and luigi)
* Explicit gem dependency for json and removed rubygems requirement (idris) (http://tomayko.com/writings/require-rubygems-antipattern)
* Removed deprecated GeoIp#remote_geolocation method

## 0.2.0 (2010-03-25)

* Added support for timezone information. Use the optional {:timezone => true|false} option
* Added support for country lookup. This will result in a faster reply since less queries need
  to be done at ipinfodb's side. Use the optional {:precision => :city|:country} option
* API change: GeoIp.remote_geolocation(ip) is deprecated in favor of GeoIp.geolocation(ip)

## 0.1.1 (2010-02-15)

* Removed time zone information since this has been deprecated with the service

## 0.1.0 (2010-01-09)

* Initial commit

# GeoIp

Retreive the geolocation of an IP address based on the [ipinfodb.com](http://ipinfodb.com/) webservice.

As of 8th November 2010, the service is asking that all users [register](http://ipinfodb.com/register.php) for an API key.

Consider making a donation to [ipinfodb.com](http://ipinfodb.com/) at [http://ipinfodb.com/donate.php](http://ipinfodb.com/donate.php).

## Usage

### Set API key
    GeoIp.api_key = 'YOUR_API_KEY'

This must be done before making the geolocation call.

### Retrieve geolocation
    GeoIp.geolocation(ip_address)

### Example

    # 209.85.227.104 = google.be (US)
    GeoIp.geolocation('209.85.227.104')

returns:

    {
      :status_code    => "OK",
      :status_message => "",
      :ip             => "209.85.227.104"
      :country_code   => "US",
      :country_name   => "UNITED STATES",
      :region_name    => "CALIFORNIA",
      :city           => "MONTEREY PARK",
      :zip_code       => "91754",
      :latitude       => "34.0505",
      :longitude      => "-118.13"
    }

### Country only

There is an option to only retreive the country information and thus excluding the city details. This results in a faster response from the service since less queries need to be done.

    GeoIp.geolocation('209.85.227.104', :precision => :country)

returns:

    {
      :status_code    => "OK",
      :status_message => "",
      :ip             => "209.85.227.104"
      :country_code   => "US",
      :country_name   => "UNITED STATES"
    }

### Timezone information

There is an option now to retrieve optional timezone information too:

    GeoIp.geolocation('209.85.227.104', :timezone => true)

returns:

    {
      :status_code    => "OK",
      :status_message => "",
      :ip             => "209.85.227.104"
      :country_code   => "US",
      :country_name   => "UNITED STATES",
      :region_name    => "CALIFORNIA",
      :city           => "MONTEREY PARK",
      :zip_code       => "91754",
      :latitude       => "34.0505",
      :longitude      => "-118.13"
      :timezone       => "-08:00"
    }

Obviously it is not possible to have the country precision enabled while retrieving the timezone information.

### Reserved / Private / Local IPs

Passing reserved, private or local IPs, such as `127.0.0.1` will return `-` for all location data, for example:

    GeoIp.geolocation('127.0.0.1')

returns:

    {
      :status_code    => "OK",
      :status_message => "",
      :ip             => "127.0.0.1",
      :country_code   => "-",
      :country_name   => "-",
      :region_name    => "-",
      :city           => "-",
      :zip_code       => "-",
      :latitude       => "0",
      :longitude      => "0"
    }

### Timeout

It is possible to set a timeout for all requests. By default it is one second, but you can easily set a different value. Just like you would set the api_key you can set the timeout:

    GeoIp.timeout = 5 # In order to set it to five seconds

## Getting it

GeoIp can be installed as a Ruby Gem:

    gem install geo_ip

*note:* As of v0.6.0 GeoIp is only compatible with ruby 1.9.3 or higher. You can still use v0.5.0 if you need ruby 1.8.7 or 1.9.2 compatiblity.

### Rails

#### Bundler enabled (Rails 3.x and 2.3.x)

In your Gemfile:

    gem 'geo_ip'

Then create an initializer `config/initializers/geo_ip` (or name it whatever you want):

    GeoIp.api_key = 'YOUR_API_KEY'

#### Pre-bundler (Rails 2.3.x or older)

In your `config/environment.rb`:

    config.gem 'geo_ip'

Then create an initializer `config/initializers/geo_ip` (or name it whatever you want):

    GeoIp.api_key = 'YOUR_API_KEY'

## Testing

Set up your API key first for the test suite by creating a spec/api.yml file. Follow the example in spec/api.yml.example. Then run the tests with:

    ruby spec/geo_ip_spec.rb

If you get a LoadError, you should run the tests with:

    ruby -rubygems spec/geo_ip_spec.rb

## Contributors

* [seanconaty](https://github.com/seanconaty)
* [luigi](https://github.com/luigi)
* [idris](https://github.com/idris)
* [Rylon](https://github.com/Rylon)
* [harleyttd](https://github.com/harleyttd)
* [dnswus](https://github.com/dnswus)

## Bugs

Please report them on the [Github issue tracker](https://github.com/jeroenj/geo_ip/issues)
for this project.

If you have a bug to report, please include the following information:

* Version information for geo_ip, ruby and/or rails.
* Stack trace and error message.

You may also fork this project on Github and create a pull request.
Do not forget to include tests.

## Copyright

Copyright (c) 2010-2018 Jeroen Jacobs. See LICENSE for details.

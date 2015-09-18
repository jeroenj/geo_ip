require 'json'
require 'rest-client'

class GeoIp
  class InvalidPrecissionError < ArgumentError; end
  class InvalidTimezoneError < ArgumentError; end
  class InvalidIpError < ArgumentError; end
  class ApiKeyError < ArgumentError; end

  SERVICE_URL = 'http://api.ipinfodb.com/v3/ip-'
  CITY_API    = 'city'
  COUNTRY_API = 'country'
  IPV4_REGEXP = /\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/

  @@api_key = nil
  @@timeout = 1
  @@fallback_timeout = 3

  class << self
    def api_key
      @@api_key
    end

    def api_key=(api_key)
      @@api_key = api_key
    end

    def timeout
      @@timeout
    end

    def timeout=(timeout)
      @@timeout = timeout
    end

    def fallback_timeout
      @@fallback_timeout
    end

    def fallback_timeout=(fallback_timeout)
      @@fallback_timeout = fallback_timeout
    end

    def set_defaults_if_necessary(options)
      options[:precision] ||= :city
      options[:timezone]  ||= false
      fail InvalidPrecisionError unless [:country, :city].include?(options[:precision])
      fail InvalidTimezoneError unless [true, false].include?(options[:timezone])
    end

    def lookup_url(ip, options = {})
      set_defaults_if_necessary options
      fail ApiKeyError.new('API key must be set first: GeoIp.api_key = \'YOURKEY\'') if api_key.nil?
      fail InvalidIpError.new(ip) unless ip.to_s =~ IPV4_REGEXP

      "#{SERVICE_URL}#{options[:precision] == :city || options[:timezone] ? CITY_API : COUNTRY_API}?key=#{api_key}&ip=#{ip}&format=json&timezone=#{options[:timezone]}"
    end

    # Retreive the remote location of a given ip address.
    #
    # It takes two optional arguments:
    # * +preceision+: can either be +:city+ (default) or +:country+
    # * +timezone+: can either be +false+ (default) or +true+
    #
    # ==== Example:
    #   GeoIp.geolocation('209.85.227.104', {:precision => :city, :timezone => true})
    def geolocation(ip, options = {})
      location = nil
      Timeout.timeout(fallback_timeout) do
        parsed_response = JSON.parse RestClient::Request.execute(method: :get, url: lookup_url(ip, options), timeout: timeout)
        location = convert_keys(parsed_response, options)
      end

      location
    end

    private

    def convert_keys(hash, options)
      set_defaults_if_necessary options
      location = {}
      location[:ip]             = hash['ipAddress']
      location[:status_code]    = hash['statusCode']
      location[:status_message] = hash['statusMessage']
      location[:country_code]   = hash['countryCode']
      location[:country_name]   = hash['countryName']
      if options[:precision] == :city
        location[:region_name]  = hash['regionName']
        location[:city]         = hash['cityName']
        location[:zip_code]     = hash['zipCode']
        location[:latitude]     = hash['latitude']
        location[:longitude]    = hash['longitude']
        location[:timezone]     = hash['timeZone'] if options[:timezone]
      end
      location
    end
  end
end

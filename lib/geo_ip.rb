require 'json'
require 'rest-client'

class GeoIp
  SERVICE_URL = 'http://api.ipinfodb.com/v3/ip-'
  CITY_API    = 'city'
  COUNTRY_API = 'country'
  IPV4_REGEXP = /\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/

  @@api_key = nil
  @@timeout = 1

  class << self
    def api_key
      @@api_key
    end

    def api_key= api_key
      @@api_key = api_key
    end

    def timeout
      @@timeout
    end

    def timeout= timeout
      @@timeout = timeout
    end

    # Retreive the remote location of a given ip address.
    #
    # It takes two optional arguments:
    # * +preceision+: can either be +:city+ (default) or +:country+
    # * +timezone+: can either be +false+ (default) or +true+
    #
    # ==== Example:
    #   GeoIp.geolocation('209.85.227.104', {:precision => :city, :timezone => true})
    def geolocation ip, options={}
      @precision = options[:precision] || :city
      @timezone  = options[:timezone]  || false
      raise 'API key must be set first: GeoIp.api_key = \'YOURKEY\'' if self.api_key.nil?
      raise 'Invalid IP address' unless ip.to_s =~ IPV4_REGEXP
      raise 'Invalid precision'  unless [:country, :city].include?(@precision)
      raise 'Invalid timezone'   unless [true, false].include?(@timezone)
      url = "#{SERVICE_URL}#{@precision == :city || @timezone ? CITY_API : COUNTRY_API}?key=#{api_key}&ip=#{ip}&format=json&timezone=#{@timezone}"
      parsed_response = JSON.parse RestClient::Request.execute(:method => :get, :url => url, :timeout => self.timeout)
      convert_keys parsed_response
    end

    private
    def convert_keys hash
      location = {}
      location[:ip]             = hash['ipAddress']
      location[:status_code]    = hash['statusCode']
      location[:status_message] = hash['statusMessage']
      location[:country_code]   = hash['countryCode']
      location[:country_name]   = hash['countryName']
      if @precision == :city
        location[:region_name]  = hash['regionName']
        location[:city]         = hash['cityName']
        location[:zip_code]     = hash['zipCode']
        location[:latitude]     = hash['latitude']
        location[:longitude]    = hash['longitude']
        if @timezone
          location[:timezone]   = hash['timeZone']
        end
      end
      location
    end
  end
end

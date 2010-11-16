SERVICE_URL = "http://api.ipinfodb.com/v2/"
CITY_API    = "ip_query.php"
COUNTRY_API = "ip_query_country.php"
IPV4_REGEXP = /\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/

require 'json'
require 'uri'
require 'net/http'

class GeoIp

  @@api_key = nil

  def self.api_key
    @@api_key
  end

  def self.api_key=(api_key)
    @@api_key = api_key
  end

  # Retreive the remote location of a given ip address.
  #
  # It takes two optional arguments: precision and timezone
  # preceision can either be :city (default) or :country
  # timezone can either be false (default) or true
  #
  # Example:
  # GeoIp.geolocation('209.85.227.104', {:precision => :city, :timezone => true})
  def self.geolocation(ip, options={})
    @precision = options[:precision] || :city
    @timezone  = options[:timezone]  || false
    raise "API key must be set first: GeoIp.api_key = 'YOURKEY'" if self.api_key.nil?
    raise "Invalid IP address" unless ip.to_s =~ IPV4_REGEXP
    raise "Invalid precision"  unless [:country, :city].include?(@precision)
    raise "Invalid timezone"   unless [true, false].include?(@timezone)
    uri = "#{SERVICE_URL}#{@country ? COUNTRY_API : CITY_API}?key=#{self.api_key}&ip=#{ip}&output=json&timezone=#{@timezone}"
    url = URI.parse(uri)
    reply = JSON.parse(Net::HTTP.get(url))
    location = convert_keys reply
  end

  private
  def self.convert_keys(hash)
    location = {}
    location[:ip]                 = hash["Ip"]
    location[:status]             = hash["Status"]
    location[:country_code]       = hash["CountryCode"]
    location[:country_name]       = hash["CountryName"]
    if @precision == :city
      location[:region_code]      = hash["RegionCode"]
      location[:region_name]      = hash["RegionName"]
      location[:city]             = hash["City"]
      location[:zip_postal_code]  = hash["ZipPostalCode"]
      location[:latitude]         = hash["Latitude"]
      location[:longitude]        = hash["Longitude"]
      if @timezone
        location[:timezone_name]  = hash["TimezoneName"]
        location[:utc_offset]     = hash["Gmtoffset"].to_i
        location[:dst?]           = hash["Isdst"] ? true : false
      end
    end
    location
  end
end

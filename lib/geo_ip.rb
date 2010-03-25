SERVICE_URL = "http://ipinfodb.com/ip_query.php"
IPV4_REGEXP = /\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/

require 'rubygems'
require 'json'
require 'uri'
require 'net/http'

class GeoIp
  # <b>DEPRECATED:</b> Please use <tt>geolocation</tt> instead.
  def self.remote_geolocation(ip, timezone=false)
    warn "[DEPRECATION] `remote_geolocation` is deprecated and will be removed from 0.2. Use `geolocation` instead."
    geolocation(ip, timezone)
  end

  def self.geolocation(ip, timezone=false)
    raise "Invalid IP address" unless ip.to_s =~ IPV4_REGEXP
    uri = SERVICE_URL + "?ip=#{ip}&output=json&timezone=#{timezone}"
    url = URI.parse(uri)
    reply = JSON.parse(Net::HTTP.get(url))
    location = convert_keys reply
  end

  private
  def self.convert_keys(hash)
    location = {}
    location[:ip]               = hash["Ip"]
    location[:status]           = hash["Status"]
    location[:country_code]     = hash["CountryCode"]
    location[:country_name]     = hash["CountryName"]
    location[:region_code]      = hash["RegionCode"]
    location[:region_name]      = hash["RegionName"]
    location[:city]             = hash["City"]
    location[:zip_postal_code]  = hash["ZipPostalCode"]
    location[:latitude]         = hash["Latitude"]
    location[:longitude]        = hash["Longitude"]
    location[:timezone_name]    = hash["TimezoneName"] if hash["TimezoneName"]
    location[:utc_offset]       = hash["Gmtoffset"].to_i if hash["Gmtoffset"]
    location[:dst?]             = (hash["Isdst"] ? true : false) unless hash["Isdst"].nil?
    location
  end
end

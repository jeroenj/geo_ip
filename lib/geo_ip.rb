SERVICE_URL = "http://ipinfodb.com/ip_query.php"
IPV4_REGEXP = /\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/

require 'rubygems'
require 'json'
require 'uri'
require 'net/http'

class GeoIp
  def self.remote_geolocation(ip)
    raise "Invalid IP address" unless ip.to_s =~ IPV4_REGEXP
    
    uri = SERVICE_URL + "?ip=#{ip}&output=json"
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
    location[:timezone]         = hash["Timezone"]
    location[:gmt_offset]       = hash["Gmtoffset"]
    location[:dst_offset]       = hash["Dstoffset"]
    location
  end
end

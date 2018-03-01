require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
IP_GOOGLE_US = '209.85.227.104'
IP_PRIVATE = '10.0.0.1'
IP_LOCAL = '127.0.0.1'
IPV4_INVALID = '255.255.255'
IPV6_INVALID = '2001:cdba'
IPV6 = '2001:cdba:0000:0000:0000:0000:3257:9652'
# Use WebMock as default to speed up tests and for local development without a connection
# Change this to false to have tests make real http requests if you want. Perhaps to check whether IpInfoDb's API has changed
# However, you may need to increase the GeoIp.fallback_timeout variable if Timeout exceptions occur when tests are run
USE_WEBMOCK = true

describe 'GeoIp' do
  before :all do
    @ruby_19 = Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2')
    unless USE_WEBMOCK
      puts 'Running tests WITHOUT WebMock. You will need an internet connection. You may need to increase the GeoIp.fallback_timeout amount.'
      WebMock.disable!
    end
  end

  def stub_geolocation(ip, options = {}, &_block)
    headers = {
                'Accept'          => '*/*',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'Host'            => 'api.ipinfodb.com',
                'User-Agent'      => 'Ruby'
              }
    if @ruby_19
      headers.delete('Accept-Encoding')
      headers.delete('Host')
    end

    if USE_WEBMOCK
      stub_request(:get, GeoIp.lookup_url(ip, options))
        .with(headers: headers)
        .to_return(status: 200, body: yield, headers: {})
    end
  end

  before :each do
    api_config = YAML.load_file(File.dirname(__FILE__) + '/api.yml')
    GeoIp.api_key = api_config['key']
  end

  context 'api_key' do
    it 'should return the API key when set' do
      GeoIp.api_key = 'my_api_key'
      expect(GeoIp.api_key).to eq('my_api_key')
    end

    it 'should throw an error when API key is not set' do
      GeoIp.api_key = nil
      expect { GeoIp.geolocation(IP_GOOGLE_US) }.to raise_error(GeoIp::ApiKeyError)
    end
  end

  context 'city' do
    it 'should return the correct city for a public ip address' do
      stub_geolocation(IP_GOOGLE_US) do
        %({
          "statusCode" : "OK",
          "statusMessage" : "",
          "ipAddress" : "209.85.227.104",
          "countryCode" : "US",
          "countryName" : "UNITED STATES",
          "regionName" : "CALIFORNIA",
          "cityName" : "MONTEREY PARK",
          "zipCode" : "91754",
          "latitude" : "34.0505",
          "longitude" : "-118.13",
          "timeZone" : "-08:00"
        })
      end

      geolocation = GeoIp.geolocation(IP_GOOGLE_US)
      expect(geolocation[:country_code]).to eq('US')
      expect(geolocation[:country_name]).to eq('UNITED STATES')
      expect(geolocation[:city]).to eq('MONTEREY PARK')
    end

    it 'should return nothing city for a private ip address' do
      stub_geolocation(IP_PRIVATE) do
        %({
          "statusCode" : "OK",
          "statusMessage" : "",
          "ipAddress" : "10.0.0.1",
          "countryCode" : "-",
          "countryName" : "-",
          "regionName" : "-",
          "cityName" : "-",
          "zipCode" : "-",
          "latitude" : "0",
          "longitude" : "0",
          "timeZone" : "-"
        })
      end

      geolocation = GeoIp.geolocation(IP_PRIVATE)
      expect(geolocation[:country_code]).to eq('-')
      expect(geolocation[:country_name]).to eq('-')
      expect(geolocation[:city]).to eq('-')
    end

    it 'should return nothing for localhost ip address' do
      stub_geolocation(IP_LOCAL) do
        %({
          "statusCode" : "OK",
          "statusMessage" : "",
          "ipAddress" : "127.0.0.1",
          "countryCode" : "-",
          "countryName" : "-",
          "regionName" : "-",
          "cityName" : "-",
          "zipCode" : "-",
          "latitude" : "0",
          "longitude" : "0",
          "timeZone" : "-"
        })
      end

      geolocation = GeoIp.geolocation(IP_LOCAL)
      expect(geolocation[:country_code]).to eq('-')
      expect(geolocation[:country_name]).to eq('-')
      expect(geolocation[:city]).to eq('-')
    end

    it 'should return the correct city for a public ip address when explicitly requiring it' do
      stub_geolocation(IP_GOOGLE_US) do
        %({
          "statusCode" : "OK",
          "statusMessage" : "",
          "ipAddress" : "209.85.227.104",
          "countryCode" : "US",
          "countryName" : "UNITED STATES",
          "regionName" : "CALIFORNIA",
          "cityName" : "MONTEREY PARK",
          "zipCode" : "91754",
          "latitude" : "34.0505",
          "longitude" : "-118.13",
          "timeZone" : "-08:00"
        })
      end

      geolocation = GeoIp.geolocation(IP_GOOGLE_US, precision: :city)
      expect(geolocation[:country_code]).to eq('US')
      expect(geolocation[:country_name]).to eq('UNITED STATES')
      expect(geolocation[:city]).to eq('MONTEREY PARK')
    end
  end

  context 'country' do
    it 'should return the correct country for a public ip address' do
      stub_geolocation(IP_GOOGLE_US, precision: :country) do
        %({
          "statusCode" : "OK",
          "statusMessage" : "",
          "ipAddress" : "209.85.227.104",
          "countryCode" : "US",
          "countryName" : "UNITED STATES"
        })
      end
      geolocation = GeoIp.geolocation(IP_GOOGLE_US, precision: :country)
      expect(geolocation[:country_code]).to eq('US')
      expect(geolocation[:country_name]).to eq('UNITED STATES')
    end

    it 'should return nothing country for a private ip address' do
      stub_geolocation(IP_PRIVATE, precision: :country) do
        %({
          "statusCode" : "OK",
          "statusMessage" : "",
          "ipAddress" : "10.0.0.1",
          "countryCode" : "-",
          "countryName" : "-"
        })
      end
      geolocation = GeoIp.geolocation(IP_PRIVATE, precision: :country)
      expect(geolocation[:country_code]).to eq('-')
      expect(geolocation[:country_name]).to eq('-')
    end

    it 'should return nothing country for localhost ip address' do
      stub_geolocation(IP_LOCAL, precision: :country) do
        %({
          "statusCode" : "OK",
          "statusMessage" : "",
          "ipAddress" : "127.0.0.1",
          "countryCode" : "-",
          "countryName" : "-"
        })
      end
      geolocation = GeoIp.geolocation(IP_LOCAL, precision: :country)
      expect(geolocation[:country_code]).to eq('-')
      expect(geolocation[:country_name]).to eq('-')
    end

    it 'should not return the city for a public ip address' do
      stub_geolocation(IP_GOOGLE_US, precision: :country) do
        %({
          "statusCode" : "OK",
          "statusMessage" : "",
          "ipAddress" : "209.85.227.104",
          "countryCode" : "US",
          "countryName" : "UNITED STATES"
        })
      end
      geolocation = GeoIp.geolocation(IP_GOOGLE_US, precision: :country)
      expect(geolocation[:country_code]).to eq('US')
      expect(geolocation[:country_name]).to eq('UNITED STATES')
      expect(geolocation[:city]).to eq(nil)
    end
  end

  context 'timezone' do
    it 'should return the correct timezone information for a public ip address' do
      stub_geolocation(IP_GOOGLE_US, timezone: true) do
        %({
          "statusCode" : "OK",
          "statusMessage" : "",
          "ipAddress" : "209.85.227.104",
          "countryCode" : "US",
          "countryName" : "UNITED STATES",
          "regionName" : "CALIFORNIA",
          "cityName" : "MONTEREY PARK",
          "zipCode" : "91754",
          "latitude" : "34.0505",
          "longitude" : "-118.13",
          "timeZone" : "-08:00"
        })
      end
      geolocation = GeoIp.geolocation(IP_GOOGLE_US, timezone: true)
      expect(geolocation[:timezone]).to eq('-08:00') # This one is likely to break when dst changes.)
    end

    it 'should not return the timezone information when explicitly not requesting it' do
      stub_geolocation(IP_GOOGLE_US, timezone: false) do
        %({
          "statusCode" : "OK",
          "statusMessage" : "",
          "ipAddress" : "209.85.227.104",
          "countryCode" : "US",
          "countryName" : "UNITED STATES",
          "regionName" : "CALIFORNIA",
          "cityName" : "MONTEREY PARK",
          "zipCode" : "91754",
          "latitude" : "34.0505",
          "longitude" : "-118.13",
          "timeZone" : "-08:00"
        })
      end
      geolocation = GeoIp.geolocation(IP_GOOGLE_US, timezone: false)
      expect(geolocation[:timezone]).to eq(nil)
    end

    it 'should not return the timezone information when not requesting it' do
      stub_geolocation(IP_GOOGLE_US) do
        %({
          "statusCode" : "OK",
          "statusMessage" : "",
          "ipAddress" : "209.85.227.104",
          "countryCode" : "US",
          "countryName" : "UNITED STATES",
          "regionName" : "CALIFORNIA",
          "cityName" : "MONTEREY PARK",
          "zipCode" : "91754",
          "latitude" : "34.0505",
          "longitude" : "-118.13",
          "timeZone" : "-08:00"
        })
      end
      geolocation = GeoIp.geolocation(IP_GOOGLE_US)
      expect(geolocation[:timezone]).to eq(nil)
    end

    it 'should not return the timezone information when country precision is selected' do
      stub_geolocation(IP_GOOGLE_US, precision: :country, timezone: true) do
        %({
          "statusCode" : "OK",
          "statusMessage" : "",
          "ipAddress" : "209.85.227.104",
          "countryCode" : "US",
          "countryName" : "UNITED STATES",
          "regionName" : "CALIFORNIA",
          "cityName" : "MONTEREY PARK",
          "zipCode" : "91754",
          "latitude" : "34.0505",
          "longitude" : "-118.13",
          "timeZone" : "-08:00"
        })
      end
      geolocation = GeoIp.geolocation(IP_GOOGLE_US, precision: :country, timezone: true)
      expect(geolocation[:timezone]).to eq(nil)
    end
  end

  context 'timeout' do
    it 'should trigger timeout when the request is taking too long' do
      stub_request(:get, GeoIp.lookup_url(IP_GOOGLE_US)).to_timeout
      expect { GeoIp.geolocation(IP_GOOGLE_US) }.to raise_error(Timeout::Error)
    end

    it 'should trigger fallback timeout when Net::HTTP is taking too long to send the request', focus: true do
      GeoIp.fallback_timeout = 1
      allow(Net::HTTP).to receive(:get) { sleep 2 }
      expect { GeoIp.geolocation(IP_GOOGLE_US) }.to raise_error(Timeout::Error)
    end
  end

  context 'ip' do
    it 'should trigger invalid ip when invalid IPv4 address is provided' do
      allow(Net::HTTP).to receive(:get) do
        %({
          "statusCode" : "OK",
          "statusMessage" : "",
          "ipAddress" : "209.85.227.104",
          "countryCode" : "US",
          "countryName" : "UNITED STATES",
          "regionName" : "CALIFORNIA",
          "cityName" : "MONTEREY PARK",
          "zipCode" : "91754",
          "latitude" : "34.0505",
          "longitude" : "-118.13",
          "timeZone" : "-08:00"
        })
      end
      expect { GeoIp.geolocation(IPV4_INVALID) }.to raise_error(GeoIp::InvalidIpError)
    end

    it 'should not trigger invalid ip when valid IPv4 address is provided' do
      allow(Net::HTTP).to receive(:get) do
        %({
          "statusCode" : "OK",
          "statusMessage" : "",
          "ipAddress" : "209.85.227.104",
          "countryCode" : "US",
          "countryName" : "UNITED STATES",
          "regionName" : "CALIFORNIA",
          "cityName" : "MONTEREY PARK",
          "zipCode" : "91754",
          "latitude" : "34.0505",
          "longitude" : "-118.13",
          "timeZone" : "-08:00"
        })
      end
      expect { GeoIp.geolocation(IP_GOOGLE_US) }.not_to raise_error
    end

    it 'should trigger invalid ip when invalid IPv6 address is provided' do
      allow(Net::HTTP).to receive(:get) do
        %({
          "statusCode" : "OK",
          "statusMessage" : "",
          "ipAddress" : "209.85.227.104",
          "countryCode" : "US",
          "countryName" : "UNITED STATES",
          "regionName" : "CALIFORNIA",
          "cityName" : "MONTEREY PARK",
          "zipCode" : "91754",
          "latitude" : "34.0505",
          "longitude" : "-118.13",
          "timeZone" : "-08:00"
        })
      end
      expect { GeoIp.geolocation(IPV6_INVALID) }.to raise_error(GeoIp::InvalidIpError)
    end

    it 'should not trigger invalid ip when valid IPv6 address is provided' do
      allow(Net::HTTP).to receive(:get) do
        %({
          "statusCode" : "OK",
          "statusMessage" : "",
          "ipAddress" : "209.85.227.104",
          "countryCode" : "US",
          "countryName" : "UNITED STATES",
          "regionName" : "CALIFORNIA",
          "cityName" : "MONTEREY PARK",
          "zipCode" : "91754",
          "latitude" : "34.0505",
          "longitude" : "-118.13",
          "timeZone" : "-08:00"
        })
      end
      expect { GeoIp.geolocation(IPV6) }.not_to raise_error
    end
  end
end

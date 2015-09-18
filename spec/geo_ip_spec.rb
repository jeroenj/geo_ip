require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
IP_GOOGLE_US = '209.85.227.104'
IP_PRIVATE = '10.0.0.1'
IP_LOCAL = '127.0.0.1'
# Use WebMock as default to speed up tests and for local development without a connection
# Change this to false to have tests make real http requests if you want. Perhaps to check whether IpInfoDb's API has changed
# However, you may need to increase the GeoIp.fallback_timeout variable if Timeout exceptions occur when tests are run
USE_WEBMOCK = true

describe 'GeoIp' do
  before :all do
    unless USE_WEBMOCK
      puts 'Running tests WITHOUT WebMock. You will need an internet connection. You may need to increase the GeoIp.fallback_timeout amount.'
      WebMock.disable!
    end
  end

  def stub_geolocation(ip, options = {}, &_block)
    if USE_WEBMOCK
      stub_request(:get, GeoIp.lookup_url(ip, options))
        .with(headers: {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate'})
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
      GeoIp.api_key.should == 'my_api_key'
    end

    it 'should throw an error when API key is not set' do
      GeoIp.api_key = nil
      lambda { GeoIp.geolocation(IP_GOOGLE_US) }.should raise_error
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
      geolocation[:country_code].should == 'US'
      geolocation[:country_name].should == 'UNITED STATES'
      geolocation[:city].should         == 'MONTEREY PARK'
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
      geolocation[:country_code].should == '-'
      geolocation[:country_name].should == '-'
      geolocation[:city].should         == '-'
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
      geolocation[:country_code].should == '-'
      geolocation[:country_name].should == '-'
      geolocation[:city].should         == '-'
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
      geolocation[:country_code].should == 'US'
      geolocation[:country_name].should == 'UNITED STATES'
      geolocation[:city].should         == 'MONTEREY PARK'
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
      geolocation[:country_code].should == 'US'
      geolocation[:country_name].should == 'UNITED STATES'
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
      geolocation[:country_code].should == '-'
      geolocation[:country_name].should == '-'
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
      geolocation[:country_code].should == '-'
      geolocation[:country_name].should == '-'
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
      geolocation[:country_code].should == 'US'
      geolocation[:country_name].should == 'UNITED STATES'
      geolocation[:city].should         be_nil
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
      geolocation[:timezone].should == '-08:00' # This one is likely to break when dst changes.
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
      geolocation[:timezone].should be_nil
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
      geolocation[:timezone].should be_nil
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
      geolocation[:timezone].should be_nil
    end
  end

  context 'timeout' do
    it 'should trigger timeout when the request is taking too long' do
      stub_request(:get, GeoIp.lookup_url(IP_GOOGLE_US)).to_timeout
      lambda { GeoIp.geolocation(IP_GOOGLE_US) }.should raise_exception('Request Timeout')
    end

    it 'should trigger fallback timeout when RestClient is taking too long to send the request', focus: true do
      GeoIp.fallback_timeout = 1
      RestClient::Request.stub(:execute) { sleep 2 }
      lambda { GeoIp.geolocation(IP_GOOGLE_US) }.should raise_exception(Timeout::Error)
    end
  end
end

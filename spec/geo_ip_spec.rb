require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
IP_GOOGLE_US = '209.85.227.104'
IP_PRIVATE = '10.0.0.1'
IP_LOCAL = '127.0.0.1'

describe 'GeoIp' do
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
      lambda {GeoIp.geolocation(IP_GOOGLE_US)}.should raise_error
    end
  end

  context 'city' do
    it 'should return the correct city for a public ip address' do
      geolocation = GeoIp.geolocation(IP_GOOGLE_US)
      geolocation[:country_code].should == 'US'
      geolocation[:country_name].should == 'UNITED STATES'
      geolocation[:city].should         == 'MONTEREY PARK'
    end

    it 'should return nothing city for a private ip address' do
      geolocation = GeoIp.geolocation(IP_PRIVATE)
      geolocation[:country_code].should == '-'
      geolocation[:country_name].should == '-'
      geolocation[:city].should         == '-'
    end

    it 'should return nothing for localhost ip address' do
      geolocation = GeoIp.geolocation(IP_LOCAL)
      geolocation[:country_code].should == '-'
      geolocation[:country_name].should == '-'
      geolocation[:city].should         == '-'
    end

    it 'should return the correct city for a public ip address when explicitly requiring it' do
      geolocation = GeoIp.geolocation(IP_GOOGLE_US, :precision => :city)
      geolocation[:country_code].should == 'US'
      geolocation[:country_name].should == 'UNITED STATES'
      geolocation[:city].should         == 'MONTEREY PARK'
    end
  end

  context 'country' do
    it 'should return the correct country for a public ip address' do
      geolocation = GeoIp.geolocation(IP_GOOGLE_US, :precision => :country)
      geolocation[:country_code].should == 'US'
      geolocation[:country_name].should == 'UNITED STATES'
    end

    it 'should return nothing country for a private ip address' do
      geolocation = GeoIp.geolocation(IP_PRIVATE, :precision => :country)
      geolocation[:country_code].should == '-'
      geolocation[:country_name].should == '-'
    end

    it 'should return nothing country for localhost ip address' do
      geolocation = GeoIp.geolocation(IP_LOCAL, :precision => :country)
      geolocation[:country_code].should == '-'
      geolocation[:country_name].should == '-'
    end

    it 'should not return the city for a public ip address' do
      geolocation = GeoIp.geolocation(IP_GOOGLE_US, :precision => :country)
      geolocation[:country_code].should == 'US'
      geolocation[:country_name].should == 'UNITED STATES'
      geolocation[:city].should         be_nil
    end
  end

  context 'timezone' do
    it 'should return the correct timezone information for a public ip address' do
      geolocation = GeoIp.geolocation(IP_GOOGLE_US, :timezone => true)
      geolocation[:timezone].should == '-08:00' # This one is likely to break when dst changes.
    end

    it 'should not return the timezone information when explicitly not requesting it' do
      geolocation = GeoIp.geolocation(IP_GOOGLE_US, :timezone => false)
      geolocation[:timezone].should be_nil
    end

    it 'should not return the timezone information when not requesting it' do
      geolocation = GeoIp.geolocation(IP_GOOGLE_US)
      geolocation[:timezone].should be_nil
    end

    it 'should not return the timezone information when country precision is selected' do
      geolocation = GeoIp.geolocation(IP_GOOGLE_US, :precision => :country, :timezone => true)
      geolocation[:timezone].should be_nil
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
IP_GOOGLE_US = '209.85.227.104'
IP_PRIVATE = '10.0.0.1'
IP_LOCAL = '127.0.0.1'

describe "GeoIp" do
  context "city" do
    it "should return the correct city for a public ip address" do
      geolocation = GeoIp.geolocation(IP_GOOGLE_US)
      geolocation[:country_code].should == 'US'
      geolocation[:country_name].should == 'United States'
      geolocation[:city].should         == 'Mountain View'
    end

    it "should return the correct city for a private ip address" do
      geolocation = GeoIp.geolocation(IP_PRIVATE)
      geolocation[:country_code].should == 'RD'
      geolocation[:country_name].should == 'Reserved'
      geolocation[:city].should         be_empty
    end

    it "should return the correct city for localhost ip address" do
      geolocation = GeoIp.geolocation(IP_LOCAL)
      geolocation[:country_code].should == 'RD'
      geolocation[:country_name].should == 'Reserved'
      geolocation[:city].should         be_empty
    end

    it "should return the correct city for a public ip address when explicitly requiring it" do
      geolocation = GeoIp.geolocation(IP_GOOGLE_US, {:precision => :city})
      geolocation[:country_code].should == 'US'
      geolocation[:country_name].should == 'United States'
      geolocation[:city].should         == 'Mountain View'
    end
  end

  context "country" do
    it "should return the correct country for a public ip address" do
      geolocation = GeoIp.geolocation(IP_GOOGLE_US, {:precision => :country})
      geolocation[:country_code].should == 'US'
      geolocation[:country_name].should == 'United States'
    end

    it "should return the correct country for a private ip address" do
      geolocation = GeoIp.geolocation(IP_PRIVATE, {:precision => :country})
      geolocation[:country_code].should == 'RD'
      geolocation[:country_name].should == 'Reserved'
    end

    it "should return the correct country for localhost ip address" do
      geolocation = GeoIp.geolocation(IP_LOCAL, {:precision => :country})
      geolocation[:country_code].should == 'RD'
      geolocation[:country_name].should == 'Reserved'
    end

    it "should not return the city for a public ip address" do
      geolocation = GeoIp.geolocation(IP_GOOGLE_US, {:precision => :country})
      geolocation[:country_code].should == 'US'
      geolocation[:country_name].should == 'United States'
      geolocation[:city].should         be_nil
    end
  end

  context "timezone" do
    it "should return the correct timezone information for a public ip address" do
      geolocation = GeoIp.geolocation(IP_GOOGLE_US, {:timezone => true})
      geolocation[:timezone_name].should == 'America/Los_Angeles'
      geolocation[:utc_offset].should    == -25200
      geolocation[:dst?].should_not      be_nil # true if dst?, false if not dst?
    end

    it "should not return the timezone information when explicitly not requesting it" do
      geolocation = GeoIp.geolocation(IP_GOOGLE_US, {:timezone => false})
      geolocation[:timezone_name].should be_nil
      geolocation[:utc_offset].should    be_nil
      geolocation[:dst?].should          be_nil
    end

    it "should not return the timezone information when not requesting it" do
      geolocation = GeoIp.geolocation(IP_GOOGLE_US)
      geolocation[:timezone_name].should be_nil
      geolocation[:utc_offset].should    be_nil
      geolocation[:dst?].should          be_nil
    end

    it "should not return the timezone information when country precision is selected" do
      geolocation = GeoIp.geolocation(IP_GOOGLE_US, {:precision => :country, :timezone => true})
      geolocation[:timezone_name].should be_nil
      geolocation[:utc_offset].should    be_nil
      geolocation[:dst?].should          be_nil
    end
  end

  context "deprecated" do
    it "should return the correct country for a public ip address" do
      geolocation = GeoIp.remote_geolocation(IP_GOOGLE_US)
      geolocation[:country_code].should == 'US'
      geolocation[:country_name].should == 'United States'
    end
  end
end

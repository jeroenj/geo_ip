require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "GeoIp" do
  it "should return the correct country for a public ip address" do
    # 209.85.227.104 = google.be (US)
    geolocation = GeoIp.geolocation('209.85.227.104')
    geolocation[:country_code].should == 'US'
    geolocation[:country_name].should == 'United States'
  end

  it "should return the correct country for a private ip address" do
    geolocation = GeoIp.geolocation('10.0.0.1')
    geolocation[:country_code].should == 'RD'
    geolocation[:country_name].should == 'Reserved'
  end

  it "should return the correct country for localhost ip address" do
    geolocation = GeoIp.geolocation('127.0.0.1')
    geolocation[:country_code].should == 'RD'
    geolocation[:country_name].should == 'Reserved'
  end

  context "deprecated" do
    it "should return the correct country for a public ip address" do
      # 209.85.227.104 = google.be (US)
      geolocation = GeoIp.geolocation('209.85.227.104')
      geolocation[:country_code].should == 'US'
      geolocation[:country_name].should == 'United States'
    end
  end
end

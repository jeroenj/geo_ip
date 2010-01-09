require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "GeoIp" do
  it "should return the correct country for a public ip address" do
    # 209.85.227.104 = google.be (US)
    GeoIp.remote_geolocation('209.85.227.104')[:country_code].should == 'US'
    GeoIp.remote_geolocation('209.85.227.104')[:country_name].should == 'United States'
  end

  it "should return the correct country for a private ip address" do
    GeoIp.remote_geolocation('10.0.0.1')[:country_code].should == 'RD'
    GeoIp.remote_geolocation('10.0.0.1')[:country_name].should == 'Reserved'
  end

  it "should return the correct country for localhost ip address" do
    GeoIp.remote_geolocation('127.0.0.1')[:country_code].should == 'RD'
    GeoIp.remote_geolocation('127.0.0.1')[:country_name].should == 'Reserved'
  end
end

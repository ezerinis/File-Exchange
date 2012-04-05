require "#{File.dirname(__FILE__)}/../client"

describe "client account creation" do

  before :all do
    @username = "andrius"
    @password = "1234"
    @client = Client.new(@username, @password)
  end

  it "should correctly assign variables" do
    @client.username.should == @username
    @client.password.should == @password
  end

  it "should initialize ratio at 0" do
    @client.ratio.should == 0
  end
end
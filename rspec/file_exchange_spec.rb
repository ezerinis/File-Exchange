require "#{File.dirname(__FILE__)}/../file_exchange"
require "#{File.dirname(__FILE__)}/../client"
require "#{File.dirname(__FILE__)}/custom_matchers"

describe "client creation" do
  include CustomMatchers

  before :all do
    @username = "aaa"
    @password = "123"
    @file_exchange = FileExchange.new
    @file_exchange.create_client("qqq", "789")
  end

  it "should create client from parameters" do
    @file_exchange.create_client(@username, @password)
    @file_exchange.clients.should contain(@username)
  end

  it "should not create client with existing username" do
    @file_exchange.create_client(@username, @password)
    count = 0
    @file_exchange.clients.each {|c| count += 1 if c.username == @username}
    count.should == 1
  end
end

describe "client authentication" do

  before :all do
    @file_exchange = FileExchange.new
    @client1 = Client.new("aka", "1234")
    @client2 = Client.new("abc", "asdf")
    @client3 = Client.new("qwerty", "7894")
    @file_exchange.clients.add(@client1)
    @file_exchange.clients.add(@client2)
    @file_exchange.clients.add(@client3)
  end

  it "should find correct client" do
    @logged_in = @file_exchange.login("abc", "asdf")
    @logged_in.should == @client2
  end
end
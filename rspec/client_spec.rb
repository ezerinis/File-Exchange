require "#{File.dirname(__FILE__)}/../client"

describe Client do

  before :all do
    @username = "andrius"
    @password = "1234"
    @speed = 5
    @client = Client.new(@username, @password, @speed)
  end

  describe "client account creation" do

    it "should correctly assign variables" do
      @client.username.should == @username
      @client.password.should == @password
      @client.max_speed.should == @speed
      @client.speed.should == @speed
    end

    it "should initialize ratio at 0" do
      @client.ratio.should == 0
    end

    it "should raise an error if name or password lengths are incorrect" do
      lambda { Client.new("a", "123", 10) }.should raise_error
      lambda { Client.new("qwerty", "123456789456", 10) }.should raise_error
    end

    it "should raise an error if speed is negative or too big" do
      lambda { Client.new("qwerty", "123", -10) }.should raise_error
      lambda { Client.new("qwerty", "123", 100000) }.should raise_error
    end
  end

  describe "downloading speed alteration" do

    it "should correctly change download speed" do
      @client.set_speed(2)
      @client.speed.should == 2
    end

    it "should raise an error if speed is to be changed to negative" do
      lambda { @client.set_speed(-1) }.should raise_error
    end

    it "should not exceed max_speed" do
      @client.set_speed(20)
      @client.speed.should <= @client.max_speed
    end
  end
end
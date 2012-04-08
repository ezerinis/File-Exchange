require "#{File.dirname(__FILE__)}/../file_exchange"
require "#{File.dirname(__FILE__)}/../client"
require "#{File.dirname(__FILE__)}/custom_matchers"

describe FileExchange do

  before :all do
    @file_exchange = FileExchange.new
  end

  it "should initialize client and file lists to 0 elements" do
    @file_exchange.clients.should have(0).items
    @file_exchange.files.should have(0).items
  end

  describe "client account operations" do

    before :all do
      @file_exchange.create_client("aaa", "123", 5)
      @file_exchange.create_client("qqq", "789", 5)
    end

    describe "client creation" do

      before :all do
        @username = "nnn"
        @password = "asd"
        @speed = 8
      end

      it "should create client from parameters" do
        @file_exchange.create_client(@username, @password, @speed)
        @file_exchange.clients.find { |c| c.username == @username && c.password == @password && c.speed == @speed }.should_not == nil
      end

      it "should not create client with existing username" do
        @file_exchange.create_client(@username, @password, @speed)
        @file_exchange.clients.find_all { |c| c.username == @username }.size.should == 1
      end
    end

    describe "client authentication" do

      it "should find correct client" do
        username = "aaa"
        @logged_in = @file_exchange.login(username, "123")
        @logged_in.username.should == username
      end
    end
  end

  describe "file operations" do

    before :all do
      @file_exchange = FileExchange.new
      @file_exchange.create_file("file1", 100)
      @file_exchange.create_file("file2", 20)
      @file_exchange.create_file("file3", 540)
    end

    describe "file creation" do

      before :all do
        @name = "ruby"
        @size = "20"
      end

      it "should create file from parameters" do
        @file_exchange.create_file(@name, @size)
        @file_exchange.files.find { |f| f.name == @name && f.size == @size }.should_not == nil
      end

      it "should not create file with existing name" do
        @file_exchange.create_file(@name, @size)
        @file_exchange.files.find_all { |f| f.name == @name }.size.should == 1
      end

      it "should retrieve list of all file names" do
        names = Set.new
        retrieved_list = @file_exchange.get_file_list
        @file_exchange.files.each { |file| names.add(file.name) }
        names.should == retrieved_list
      end

      it "should return file by name" do
        file = @file_exchange.get_file(@name)
        file.name.should == @name
      end

      it "should return files that match the search query" do
        result = @file_exchange.search("f")
        result.find_all { |f| f.name == "file1" || f.name == "file2" || f.name == "file3" }.size.should == 3
      end
    end
  end
end
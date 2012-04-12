require "#{File.dirname(__FILE__)}/../file_exchange"
require "#{File.dirname(__FILE__)}/../client"
require "#{File.dirname(__FILE__)}/custom_matchers"

describe FileExchange do
  include CustomMatchers

  before :all do
    @file_exchange = FileExchange.new
  end

  it "should initialize client and file lists to 0 elements" do
    @file_exchange.clients.should be_empty
    @file_exchange.files.should be_empty
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
        @file_exchange.clients.should include_client(Client.new(@username, @password, @speed))
      end

      it "should not create client with existing username" do
        lambda { @file_exchange.create_client(@username, @password, @speed) }.should_not change(@file_exchange, :clients)
      end

      it "should inform if succeded" do
        @file_exchange.create_client("tata", "asdf", 2).should be_instance_of(Client)
        @file_exchange.create_client("tata", "asdf", 2).should be_nil
      end
    end

    describe "client account operations" do

      it "should login client" do
        username = "aaa"
        @logged_in = @file_exchange.login(username, "123")
        @logged_in.username.should == username
      end

      it "should unregister client" do
        temp_client = Client.new("temp", "lll", 10)
        @file_exchange.unregister(temp_client)
        @file_exchange.clients.should_not include(temp_client)
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
        @file_exchange.files.should include_file(@name)
      end

      it "should not create file with existing name" do
        lambda { @file_exchange.create_file(@name, @size) }.should_not change(@file_exchange, :files)
      end

      it "should inform if succeeded" do
        @file_exchange.create_file("test", 100).should == true
        @file_exchange.create_file("test", 100).should == false
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

      it "should return file names that match the search query" do
        result = @file_exchange.search("f")
        result.should == %W(file1 file2 file3).to_set
      end

      it "should return file names with highest ratings" do
        @file_exchange.get_file("file1").rate("aaa", 5)
        @file_exchange.get_file("file2").rate("aaa", 3)
        @file_exchange.get_file("file3").rate("aaa", 4)
        @file_exchange.get_file("ruby").rate("aaa", 4)
        @file_exchange.get_highest_rated_files.should == %W(file1 ruby file3).to_set
      end
    end

    describe "upload file" do

      before :all do
        @client = Client.new("asdf", "qwasf", 5)
        @f_name= "uploaded"
        @file_exchange.upload_file(@f_name, 5, @client)
      end

      it "should not add file to files list while it's not uploaded" do
        sleep(5 / @client.speed - 0.5)
        @file_exchange.files.should_not include_file(@f_name)
      end

      it "should add file to files list when it's uploaded" do
        sleep(0.5)
        @file_exchange.files.should include_file(@f_name)
      end

      it "should not upload file with existing name" do
        lambda { @file_exchange.upload_file(@f_name, 10, @client) }.should raise_error
      end

      it "should not upload file with invalid size" do
        lambda { @file_exchange.upload_file("new", -45, @client) }.should raise_error
        lambda { @file_exchange.upload_file("new", 10000, @client) }.should raise_error
      end
    end
  end
end
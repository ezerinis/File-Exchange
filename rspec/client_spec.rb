require "#{File.dirname(__FILE__)}/../client"
require "#{File.dirname(__FILE__)}/custom_matchers"
require "#{File.dirname(__FILE__)}/../file_descriptor"

describe Client do
  include CustomMatchers

  before :all do
    FileDescriptor.files.clear
    Client.users.clear
    @username = "andrius"
    @password = "1234"
    @speed = 5
    @client = Client.new(@username, @password, @speed)
    @old_clients = Set.new [@client]
  end

  describe "client account creation" do

    it "should correctly assign variables" do
      @client.max_speed.should == @speed
      @client.speed.should == @speed
    end

    it "should correctly initialize variables" do
      @client.downloads.should be_empty
      @client.active_downloads.should == 0
    end

    it "should add client to clients list" do
      Client.users.should include(@client)
    end

    it "should check if speed is positive and not too big" do
      lambda { Client.new("qwerty", "123", -10) }.should raise_error
      lambda { Client.new("qwerty", "123", 100000) }.should raise_error
      Client.users.should == @old_clients
    end
  end

  describe "downloads speed alteration" do

    before :all do
      @new_speed = 2
    end

    it "should correctly change download speed" do
      @client.set_speed(@new_speed)
      @client.speed.should == @new_speed
    end

    it "should not change speed to negative" do
      lambda { @client.set_speed(-1) }.should raise_error
      @client.speed.should == @new_speed
    end

    it "should not exceed max_speed" do
      @client.set_speed(@client.max_speed + 1)
      @client.speed.should <= @client.max_speed
    end
  end

  describe "file upload" do

    before :all do
      @name = "upload"
      @client.upload_file(FileDescriptor.new(@name, 5, true))
      @old_uploads = Set.new [@client.get_download("upload")]
    end

    it "should not add file to files list while it's not uploaded" do
      sleep(@client.get_download(@name).file.size / @client.speed - 0.2)
      FileDescriptor.files.should_not include_file(@name)
    end

    it "should not allow to upload more than one file at the same time" do
      lambda { @client.upload_file(FileDescriptor.new("new_upload", 20, true)) }.should raise_error
      @client.downloads == @old_uploads.should
    end

    it "should add file to files list when it's uploaded" do
      sleep(0.3)
      FileDescriptor.files.should include_file(@name)
    end

    it "should not upload file with existing name" do
      lambda { @client.upload_file(FileDescriptor.new(@name, 10)) }.should raise_error
      @client.downloads == @old_uploads.should
    end

    it "should not upload file with invalid size" do
      lambda { @client.upload_file(FileDescriptor("new", -45)) }.should raise_error
      lambda { @client.upload_file(FileDescriptor("new", 10000)) }.should raise_error
      @client.downloads == @old_uploads.should
    end
  end

  describe "unfinished downloads cancellation" do

    before :all do
      [FileDescriptor.new("file1", 0.1), FileDescriptor.new("file2", 20), FileDescriptor.new("file3", 100)].each do |f|
        @client.download_file(f)
      end
    end

    it "should cancel unfinished downloads" do
      sleep(0.2)
      @client.pause_download("file2")
      sleep(0.1)
      @client.cancel_unfinished_downloads
      @client.downloads.should include_download("file1")
    end
  end

  describe "client account deletion" do

    it "should unregister client" do
      temp_client = Client.new("temp", "lll", 10)
      Client.unregister(temp_client)
      Client.users.should_not include(temp_client)
    end
  end
end
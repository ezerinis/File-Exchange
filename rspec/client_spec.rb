require "#{File.dirname(__FILE__)}/../client"
require "#{File.dirname(__FILE__)}/custom_matchers"
require "#{File.dirname(__FILE__)}/../file_descriptor"

describe Client do
  include CustomMatchers

  before :all do
    FileDescriptor.files.clear
    Client.clients.clear
    @username = "andrius"
    @password = "1234"
    @speed = 5
    @client = Client.new(@username, @password, @speed)
    @old_clients = Set.new [@client]
  end

  describe "client account creation" do

    it "should correctly assign variables" do
      @client.username.should == @username
      @client.password.should == @password
      @client.max_speed.should == @speed
      @client.speed.should == @speed
    end

    it "should correctly initialize variables" do
      @client.downloads.should be_empty
      @client.active_downloads.should == 0
    end

    it "should add client to clients list" do
      Client.clients.should include(@client)
    end

    it "should check if name and password lengths are correct" do
      lambda { Client.new("a", "123", 10) }.should raise_error
      lambda { Client.new("too_long_username", "123", 10) }.should raise_error
      lambda { Client.new("client", "1", 10) }.should raise_error
      lambda { Client.new("client", "123456789456", 10) }.should raise_error
      Client.clients.should == @old_clients
    end

    it "should check if speed is positive and not too big" do
      lambda { Client.new("qwerty", "123", -10) }.should raise_error
      lambda { Client.new("qwerty", "123", 100000) }.should raise_error
      Client.clients.should == @old_clients
    end

    it "should not create client with existing username" do
      lambda { Client.new("andrius", "pass", "10") }.should raise_error
      Client.clients.should == @old_clients
    end
  end

  describe "client authentication" do

    it "should login client" do
      @logged_in = Client.login(@username, @password)
      @logged_in.username.should == @username
    end

    it "should not login client with wrong password" do
      @logged_in = Client.login(@username, "bad_pass")
      @logged_in.should be_nil
    end

    it "should unregister client" do
      temp_client = Client.new("temp", "lll", 10)
      Client.unregister(temp_client)
      Client.clients.should_not include(temp_client)
    end
  end

  describe "password change" do

    before :all do
      @new_pass = "new_pass"
    end

    it "should correctly change password" do
      @client.change_password(@new_pass, @new_pass)
      @client.password.should == @new_pass
    end

    it "should not change password if passwords don't match" do
      lambda { @client.change_password("new_pass", "new_pas") }.should raise_error
      @client.password.should == @new_pass
    end

    it "should not cahnge password if new password is too short or too long" do
      lambda { @client.change_password("1", "1") }.should raise_error
      lambda { @client.change_password("12345678910", "12345678910") }.should raise_error
      @client.password.should == @new_pass
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
end
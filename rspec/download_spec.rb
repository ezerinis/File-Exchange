require "#{File.dirname(__FILE__)}/../client"
require "#{File.dirname(__FILE__)}/custom_matchers"
require "#{File.dirname(__FILE__)}/../download"
require "#{File.dirname(__FILE__)}/../file_descriptor"

describe Download do
  include CustomMatchers

  before :all do
    FileDescriptor.files.clear
    Client.users.clear
    @file = FileDescriptor.new("ruby", 12)
    @client = Client.new("andrius", "123", 9)
  end

  describe "download creation" do

    before :all do
      @download = Download.new(@file, @client)
    end

    it "should correctly assign variables" do
      @download.file.should == @file
      @download.client.should == @client
    end

    it "should initialize progress to 0" do
      @download.progress.should == 0
    end
  end

  describe "single download process" do

    before :all do
      @download = Download.new(@file, @client)
      @download.start
    end

    it "should be running if enough time hasn't passed" do
      sleep(@download.file.size / @download.client.speed - 0.2)
      @download.progress.should < 100
    end

    it "should be finished if enough time has passed" do
      sleep(0.3)
      @download.progress.should == 100
    end

    after :all do
      @client.active_downloads = 0
    end
  end

  describe "multi download process" do

    before :all do
      @client.download_file(FileDescriptor.new("file1", 11))
      @client.download_file(FileDescriptor.new("file2", 2))
      @download1 = @client.get_download("file1")
      @download2 = @client.get_download("file2")
    end

    it "should proportionally decrease client's speed if multiple downloads are active" do
      @client.speed.should == @client.max_speed / 2
    end

    it "should increase download speed if some downloads have finished" do
      sleep(@download2.file.size / @client.speed + 0.1)
      @client.speed.should == @client.max_speed
    end

    after :all do
      @client.active_downloads = 0
      @client.downloads = Set.new
    end
  end

  describe "download operations" do

    before :all do
      @time = Download::SLEEP_INTERVAL + 0.1
      @name = "rubymine"
      @client.download_file(FileDescriptor.new(@name, 10))
      @download = @client.get_download(@name)
    end

    it "should add new download to downloads list when started" do
      @client.downloads.should include_download(@name)
    end

    it "should not increase active downloads when resuming already active download" do
      ad = @client.active_downloads
      @client.resume_download(@name)
      @client.active_downloads.should == ad
    end

    it "should stop increasing progress if paused" do
      sleep(@time)
      @client.pause_download(@name)
      sleep(@time)
      temp_progress = @download.progress
      sleep(@time)
      @download.progress.should == temp_progress
    end

    it "should not decrease active downloads when pausing already paused download" do
      ad = @client.active_downloads
      @client.pause_download(@name)
      @client.active_downloads.should == ad
    end

    it "should continue increasing progress if resumed" do
      temp_progress = @download.progress
      @client.resume_download(@name)
      sleep(@time)
      @download.progress.should > temp_progress
    end

    it "should stop downloading if stopped" do
      temp_progress = @download.progress
      @client.stop_download(@name)
      @download.progress.should == temp_progress
    end

    it "should be deleted from downloads list if stopped" do
      @client.downloads.should_not include(@download)
    end
  end

  describe "download operations when download finished" do

    before :all do
      @name = "netbeans"
      @client.download_file(FileDescriptor.new(@name, 2))
      sleep(@client.get_download(@name).file.size / @client.speed)
    end

    it "should not increase active downloads if resuming finished download" do
      lambda { @client.resume_download(@name) }.should_not change(@client, :active_downloads)
    end

    it "should not decrease active downloads speed if pausing finished download" do
      lambda { @client.pause_download(@name) }.should_not change(@client, :active_downloads)
    end

    it "should not decrease active downloads if stopping finished download" do
      lambda { @client.stop_download(@name) }.should_not change(@client, :active_downloads)
      end
  end

  describe "download status" do

    it "should correctly return download status" do
      download = Download.new(FileDescriptor.new("file", 1), @client)
      download.start
      download.get_status.should == "downloading"
      download.pause
      download.get_status.should == "paused"
      sleep(0.1)
      download.resume
      download.get_status.should == "downloading"
      sleep(0.2)
      download.get_status.should == "finished"
    end
  end

  describe "upload status" do

    it "should correctly return uplaod status" do
      upload = Download.new(FileDescriptor.new("upload", 0.2, true), @client, true)
      upload.start
      upload.get_status.should == "uploading"
      upload.stop
    end
  end
end
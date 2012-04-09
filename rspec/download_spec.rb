require "#{File.dirname(__FILE__)}/../client"
require "#{File.dirname(__FILE__)}/../download"
require "#{File.dirname(__FILE__)}/../file"

describe Download do

  before :all do
    @file = File.new("ruby", 15)
    @client = Client.new("aaa", "123", 9)
  end

  describe "download creation" do

    before :all do
      @download = Download.new(@file, @client)
    end

    it "should correctly assign variables" do
      @download.file.should == @file
      @download.client.should == @client
    end

    it "should correctly initialize variables" do
      @download.progress.should == 0
      @download.paused.should == false
    end
  end

  describe "single download process" do

    before :all do
      @download = Download.new(@file, Client.new("bbb", "456", 9))
      @download.start
    end

    it "should be running if enough time hasn't passed" do
      sleep(@download.file.size.to_f / @download.client.speed - 0.2)
      @download.progress.should < 100
    end

    it "should be finished if enough time has passed" do
      sleep(@download.file.size.to_f / @download.client.speed)
      @download.progress.should == 100
    end
  end

  describe "multi download process" do

    before :all do
      @client.new_download(File.new("new1", 15))
      @client.new_download(File.new("new2", 12))
      @download1 = @client.get_download("new1")
      @download2 = @client.get_download("new2")
    end

    it "should proportionally decrease client's speed if multiple downloads are active" do
      @client.speed.should == @client.max_speed / 2
    end

    it "should increase download speed if some downloads have finished" do
      sleep(@download2.file.size.to_f / @client.speed)
      @client.speed.should == @client.max_speed
    end
  end

  describe "download operations" do

    before :all do
      @name = "big file"
      @time = Download::SLEEP_INTERVAL + 0.1
      @client.new_download(File.new(@name, 10))
      @download = @client.get_download(@name)
    end

    it "should add new download to downloads list when started" do
      @client.downloads.find { |d| d.file.name == @name }.should_not == nil
    end

    it "should stop increasing progress if paused" do
      sleep(@time)
      @client.pause_download(@name)
      sleep(@time)
      temp_progress = @download.progress
      sleep(@time)
      @download.progress.should == temp_progress
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
end
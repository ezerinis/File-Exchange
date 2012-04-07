require "#{File.dirname(__FILE__)}/../client"
require "#{File.dirname(__FILE__)}/../download"
require "#{File.dirname(__FILE__)}/../file"

describe File do

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

    it "should initialize progress at 0" do
      @download.progress.should == 0
    end
  end

  describe "download process" do

    before :each do
      @download = Download.new(@file, @client)
    end

    it "should be finished if enough time has passed" do
      sleep((@download.file.size.to_f / @download.client.speed) + 0.3)
      @download.progress.should == 100
    end

    it "should be running if enough time hasn't passed" do
      sleep((@download.file.size.to_f / @download.client.speed) - 0.1)
      @download.progress.should < 100
    end
  end

  describe "download operations" do

    before :all do
      @download = Download.new(@file, @client)
      @time = Download::SLEEP_INTERVAL + 0.1
    end

    it "should stop increasing progress if paused" do
      sleep(@time)
      @download.pause
      sleep(@time)
      temp_progress = @download.progress
      sleep(@time)
      @download.progress.should == temp_progress
    end

    it "should continue increasing progress if resumed" do
      temp_progress = @download.progress
      @download.resume
      sleep(@time)
      @download.progress.should > temp_progress
    end

    it "should stop downloading" do
      temp_progress = @download.progress
      @download.stop
      @download.progress.should == temp_progress
    end

    it "should not resume if stopped" do
      @download.resume
      sleep(@time)
      @downlaod.should == nil
    end
  end
end
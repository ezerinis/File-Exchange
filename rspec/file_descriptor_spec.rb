require "#{File.dirname(__FILE__)}/../client"
require "#{File.dirname(__FILE__)}/../file_descriptor"

describe FileDescriptor do

  before :all do
    FileDescriptor.files.clear
    Client.users.clear
    @name = "ruby"
    @size = 20
    @file = FileDescriptor.new(@name, @size)
  end

  describe "file creation" do

    before :all do
      @old_files = Set.new [@file]
    end

    it "should correctly assign variables" do
      @file.name.should == @name
      @file.size.should == @size
    end

    it "should correctly assign current date" do
      @file.date.should == Date.today
    end

    it "should assign rating to 0" do
      @file.rating.should == 0
    end

    it "should add file to files list" do
      FileDescriptor.files.should include(@file)
    end

    it "should check if file name length is correct" do
      lambda { FileDescriptor.new("", 10) }.should raise_error
      lambda { FileDescriptor.new("12345678910111213", 10) }.should raise_error
      FileDescriptor.files.should == @old_files
    end

    it "should check if file size isn't negative or too big" do
      lambda { FileDescriptor.new("some_file", -1) }.should raise_error
      lambda { FileDescriptor.new("some_file", FileDescriptor.MAX_SIZE + 1) }.should raise_error
      FileDescriptor.files.should == @old_files
    end

    it "should not create file with existing name" do
      lambda { FileDescriptor.new("ruby", 10) }.should raise_error
      FileDescriptor.files.should == @old_files
    end
  end

  describe "file rating" do

    before :all do
      @file.rate("client1", 5)
      @file.rate("client2", 4)
      @file.rate("client3", 3)
      @correct_rating = (5 + 4 + 3) /3
    end

    it "should take average of all ratings" do
      @file.rating.should == @correct_rating
    end

    it "should not allow to rate for the same client twice" do
      lambda { @file.rate("client1", 2) }.should raise_error
      @file.rating.should == @correct_rating
    end

    it "should not accept ratings out of range" do
      lambda { @file.rate("some_client", FileDescriptor.MAX + 1) }.should raise_error
      lambda { @file.rate("some_client", FileDescriptor.MIN - 1) }.should raise_error
      @file.rating.should == @correct_rating
    end

    it "should only accept integer values" do
      lambda { @file.rate("some_client", 2.2) }.should raise_error
      @file.rating.should == @correct_rating
    end
  end

  describe "file operations" do

    before :all do
      FileDescriptor.new("file1", 100)
      FileDescriptor.new("file2", 20)
      FileDescriptor.new("file3", 540)
    end

    it "should retrieve list of all file names" do
      retrieved_list = FileDescriptor.get_file_list
      retrieved_list.should == %W(ruby file1 file2 file3).to_set
    end

    it "should return file by name" do
      file = FileDescriptor.get_file(@name)
      file.name.should == @name
    end

    it "should return file names that match the search query" do
      result = FileDescriptor.search("file")
      result.should == %W(file1 file2 file3).to_set
    end

    it "should return file names with highest ratings" do
      FileDescriptor.get_file("file1").rate("aaa", 5)
      FileDescriptor.get_file("file2").rate("aaa", 3)
      FileDescriptor.get_file("file3").rate("aaa", 5)
      FileDescriptor.get_highest_rated_files.should == %W(file1 ruby file3).to_set
    end
  end
end
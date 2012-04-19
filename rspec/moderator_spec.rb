require "#{File.dirname(__FILE__)}/../file_descriptor"
require "#{File.dirname(__FILE__)}/../moderator"

describe Moderator do

  before :all do
    FileDescriptor.files.clear
    @mod = Moderator.new("mod", "0000")
  end

  describe "client operations" do

    before :all do
      @client1 = Client.new("and", "123", 5)
      @client2 = Client.new("pau", "456", 10)
    end

    it "should get client list" do
      clients = @mod.get_client_list
      clients.should == [@client1, @client2]
    end

    it "should find client" do
      client = @mod.find_client("and")
      client.should == @client1
    end

    it "should not find moderators" do
      mod = @mod.find_client("mod")
      mod.should be_nil
    end

    it "should delete client" do
      @mod.delete_client(@client1)
      Client.users.should_not include(@client1)
    end
  end

  describe "file operations" do

    before :all do
      @file1 = FileDescriptor.new("file1", 5)
      @file2 = FileDescriptor.new("file2", 10)
    end

    it "should delete file" do
      @mod.delete_file(@file1)
      FileDescriptor.files.should_not include(@file1)
    end
  end
end
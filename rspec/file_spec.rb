require "#{File.dirname(__FILE__)}/../File"

describe "file creation" do

  name = "ruby"
  size = "20"
  file = File.new(name, size)

  it "should correctly assign variables" do
    file.name.should == name
    file.size.should == size
  end

  it "should correctly assign current date" do
    file.date.should == Date.today
  end
end
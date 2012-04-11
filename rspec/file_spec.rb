require "#{File.dirname(__FILE__)}/../file"

describe File do

  before :all do
    @name = "ruby"
    @size = "20"
    @file = File.new(@name, @size)
  end

  describe "file creation" do

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

    describe "file rating" do

      before :all do
        @file.rate("aaa", 5)
        @file.rate("bbb", 4)
        @file.rate("ccc", 3)
      end

      it "should take average of all ratings" do
        @file.rating.should == (5 + 4 + 3) /3
      end

      it "should not allow to rate for the same client twice" do
        lambda { @file.rate("aaa", 2) }.should raise_error
      end

      it "should not accept ratings out of range" do
        lambda { @file.rate("qqq", File::MAX + 1) }.should raise_error
        lambda { @file.rate("qqq", File::MIN - 1) }.should raise_error
      end
    end
  end
end
require "#{File.dirname(__FILE__)}/../user"

describe User do

  before :all do
    User.users.clear
    @username = "andrius"
    @password = "1234"
    @user = User.new(@username, @password)
    User.users.add(@user)
    @old_users = Set.new [@user]
  end

  describe "user account creation" do

    it "should correctly assign variables" do
      @user.username.should == @username
      @user.password.should == @password
    end

    it "should check if name and password lengths are correct" do
      lambda { User.new("a", "123") }.should raise_error
      lambda { User.new("too_long_username", "123") }.should raise_error
      lambda { User.new("user", "1") }.should raise_error
      lambda { User.new("user", "123456789456") }.should raise_error
      User.users.should == @old_users
    end

    it "should not create user with existing username" do
      lambda { User.new("andrius", "pass") }.should raise_error
      User.users.should == @old_users
    end
  end

  describe "user authentication" do

    it "should login user" do
      @logged_in = User.login(@username, @password)
      @logged_in.username.should == @username
    end

    it "should not login user with wrong password" do
      @logged_in = User.login(@username, "bad_pass")
      @logged_in.should be_nil
    end
  end

  describe "password change" do

    before :all do
      @new_pass = "new_pass"
    end

    it "should correctly change password" do
      @user.change_password(@new_pass, @new_pass)
      @user.password.should == @new_pass
    end

    it "should not change password if passwords don't match" do
      lambda { @user.change_password("new_pass", "new_pas") }.should raise_error
      @user.password.should == @new_pass
    end

    it "should not cahnge password if new password is too short or too long" do
      lambda { @user.change_password("1", "1") }.should raise_error
      lambda { @user.change_password("12345678910", "12345678910") }.should raise_error
      @user.password.should == @new_pass
    end
  end
end
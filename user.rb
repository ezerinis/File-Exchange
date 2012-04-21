require 'set'

class User
  attr_accessor :username, :password

  @@users = Set.new

  MIN_LENGTH = 3
  MAX_LENGTH = 10

  def initialize(username, password)
    raise "Username length should be between [#{MIN_LENGTH}..#{MAX_LENGTH}]" if !username.length.between?(MIN_LENGTH, MAX_LENGTH)
    raise "Password's length should be between [#{MIN_LENGTH}..#{MAX_LENGTH}]" if !password.length.between?(MIN_LENGTH, MAX_LENGTH)
    raise "User with this username already exists" if @@users.find { |c| c.username == username }
    @username = username
    @password = password
  end

  def self.login(username, password)
    @@users.find { |c| c.username == username && c.password == password }
  end

  def change_password(pass1, pass2)
    raise "Passwords don't match" if pass1 != pass2
    raise "Password's length should be between [#{MIN_LENGTH}..#{MAX_LENGTH}]" if !pass1.length.between?(MIN_LENGTH, MAX_LENGTH)
    @password = pass1
  end

  def self.load
    @@users = File.open("#{File.dirname(__FILE__)}/users.yaml", "r") { |object| YAML::load(object) }
  end

  def self.users
    @@users
  end

  def self.users=(users)
    @@users = users
  end
end
require "#{File.dirname(__FILE__)}/download"
require 'set'

class Client
  attr_accessor :username, :password, :max_speed, :speed, :downloads

  MIN_LENGTH = 3
  MAX_LENGTH = 10
  MAX_SPEED = 100

  def initialize(username, password, speed)
    raise "Username length should be between [#{MIN_LENGTH}..#{MAX_LENGTH}]" if !username.length.between?(MIN_LENGTH, MAX_LENGTH)
    raise "Password's length should be between [#{MIN_LENGTH}..#{MAX_LENGTH}]" if !password.length.between?(MIN_LENGTH, MAX_LENGTH)
    raise "Download speed can't be negative" if speed < 0
    raise "Download speed can't be over #{MAX_SPEED}" if speed > MAX_SPEED
    @username = username
    @password = password
    @max_speed = speed
    @speed = speed
    @downloads = Set.new
  end

  def set_speed(speed)
    raise "Download speed can't be negative" if speed < 0
    if speed > @max_speed
      @speed = @max_speed
    else
      @speed = speed
    end
  end

  def new_download(file, client)
    @downloads.add(Download.new(file, client))
  end

  def change_password(pass1, pass2)
    raise "Passwords don't match" if pass1 != pass2
    raise "Password's length should be between [#{MIN_LENGTH}..#{MAX_LENGTH}]" if !pass1.length.between?(MIN_LENGTH, MAX_LENGTH)
    @password = pass1
  end
end
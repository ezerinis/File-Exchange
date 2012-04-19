require "#{File.dirname(__FILE__)}/download"
require 'set'

class Client
  attr_accessor :username, :password, :max_speed, :speed, :downloads, :active_downloads

  @@clients = Set.new

  MIN_LENGTH = 3
  MAX_LENGTH = 10
  MAX_SPEED = 100

  def initialize(username, password, speed)
    raise "Username length should be between [#{MIN_LENGTH}..#{MAX_LENGTH}]" if !username.length.between?(MIN_LENGTH, MAX_LENGTH)
    raise "Password's length should be between [#{MIN_LENGTH}..#{MAX_LENGTH}]" if !password.length.between?(MIN_LENGTH, MAX_LENGTH)
    raise "Download speed can't be negative" if speed < 0
    raise "Download speed can't be over #{MAX_SPEED}" if speed > MAX_SPEED
    raise "Client with this username already exists" if @@clients.find { |c| c.username == username }
    @username = username
    @password = password
    @max_speed = speed.to_f
    @speed = speed.to_f
    @downloads = Set.new
    @active_downloads = 0
    @@clients.add(self)
  end

  def self.login(username, password)
    @@clients.find { |c| c.username == username && c.password == password }
  end

  def change_password(pass1, pass2)
    raise "Passwords don't match" if pass1 != pass2
    raise "Password's length should be between [#{MIN_LENGTH}..#{MAX_LENGTH}]" if !pass1.length.between?(MIN_LENGTH, MAX_LENGTH)
    @password = pass1
  end

  def self.unregister(client)
    @@clients.delete(client)
  end

  def set_speed(speed)
    raise "Download speed can't be negative" if speed < 0
    if speed > @max_speed
      @speed = @max_speed
    else
      @speed = speed.to_f
    end
    @speed = @speed / @active_downloads if @active_downloads > 0
  end

  def download_file(file, is_upload = false)
    download = Download.new(file, self, is_upload)
    @downloads.add(download)
    decrease_speed
    download.start
  end

  def upload_file(file)
    found = @downloads.find { |d| d.is_upload && d.get_status != "finished" }
    raise "Can't have more than one upload at the same time" if found
    download_file(file, true)
  end

  def get_download(name)
    @downloads.find { |d| d.file.name == name }
  end

  def pause_download(name)
    download = get_download(name)
    download.pause
  end

  def resume_download(name)
    download = get_download(name)
    download.resume
  end

  def stop_download(name)
    download = get_download(name)
    download.stop
    @downloads.delete(download)
  end

  def increase_speed
    @speed = (@speed * @active_downloads) / (@active_downloads - 1) if @active_downloads > 1
    @active_downloads -= 1
  end

  def decrease_speed
    @speed = (@speed * @active_downloads) / (@active_downloads + 1) if @active_downloads > 0
    @active_downloads += 1
  end

  def cancel_unfinished_downloads
    @downloads.each { |d| stop_download(d.file.name) if d.get_status != "finished"}
  end

  def self.clients
    @@clients
  end

  def self.clients=(clients)
    @@clients = clients
  end
end
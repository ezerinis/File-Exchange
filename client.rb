require "#{File.dirname(__FILE__)}/download"
require "#{File.dirname(__FILE__)}/user"

class Client < User
  attr_accessor :max_speed, :speed, :downloads, :active_downloads

  MAX_SPEED = 100

  def initialize(username, password, speed)
    super(username, password)
    raise "Download speed can't be negative" if speed < 0
    raise "Download speed can't be over #{MAX_SPEED}" if speed > MAX_SPEED
    @max_speed = speed.to_f
    @speed = speed.to_f
    @downloads = Set.new
    @active_downloads = 0
    @@users.add(self)
  end

  def self.unregister(client)
    @@users.delete(client)
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

  def get_total_speed
    return @speed * @active_downloads if @active_downloads > 1
    @speed
  end

  def download_file(file, is_upload = false)
    download = Download.new(file, self, is_upload)
    @downloads.add(download)
    decrease_speed
    download.start
  end

  def upload_file(file)
    found = @downloads.find { |d| d.is_upload && d.get_status != Status::FIN }
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
    @downloads.each { |d| stop_download(d.file.name) if d.get_status != Status::FIN }
  end
end
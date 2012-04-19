require "#{File.dirname(__FILE__)}/status"

class Download
  attr_accessor :file, :client, :progress, :is_upload

  SLEEP_INTERVAL = 0.1

  def initialize(file, client, is_upload = false)
    @file = file
    @client = client
    @is_upload = is_upload
    @progress = 0
    @paused = false
    @thread = nil
  end

  def start
    @thread = Thread.new do
      while @progress < 100
        Thread.stop if @paused
        start_time = Time.now
        portion = (@client.speed * (SLEEP_INTERVAL) * 100) / @file.size
        if portion + @progress <= 100
          sleep(SLEEP_INTERVAL - (Time.now - start_time))
          @progress += portion
        else
          sleep(((100 - @progress) * @file.size) / (@client.speed * 100) - (Time.now - start_time))
          @progress = 100
        end
      end
      @client.speed = (@client.speed * @client.active_downloads) / (@client.active_downloads - 1) if @client.active_downloads > 1
      @client.active_downloads -= 1
      FileDescriptor.files.add(@file) if @is_upload
      @thread = nil
    end
  end

  def pause
    if get_status == Status::DOW
      @paused = true
      @client.increase_speed
    end
  end

  def resume
    if get_status == Status::PAU
      @paused = false
      @client.decrease_speed
      @thread.wakeup
    end
  end

  def stop
    if get_status != Status::FIN
      @thread.kill
      @client.increase_speed unless @paused
    end
  end

  def get_status
    return Status::FIN if @progress == 100
    return Status::PAU if @paused
    return Status::UPL if is_upload
    Status::DOW
  end
end
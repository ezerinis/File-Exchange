class Download
  attr_accessor :file, :client, :progress

  SLEEP_INTERVAL = 0.1

  def initialize(file, client)
    @file = file
    @client = client
    @progress = 0
    @paused = false
    @thread = nil
  end

  def start
    @thread = Thread.new do
      while @progress < 100
        Thread.stop if @paused
        speed = @client.speed.to_f / (@client.downloads.find_all { |d| d.progress < 100 && !d.paused }.size)
        portion = (speed * (SLEEP_INTERVAL) * 100) / @file.size
        start_time = Time.now
        if portion + @progress <= 100
          sleep(SLEEP_INTERVAL - (Time.now - start_time))
          @progress += portion
        else
          sleep(((100 - @progress) * @file.size) / (speed * 100) - (Time.now - start_time))
          @progress = 100
        end
      end
    end
  end

  def pause
    @paused = true
  end

  def resume
    if @thread.status == "sleep"
      @paused = false
      @thread.wakeup
    end
  end

  def stop
    @thread.kill
    @client.downloads.delete(self)
  end
end
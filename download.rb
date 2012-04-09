class Download
  attr_accessor :file, :client, :progress, :paused

  SLEEP_INTERVAL = 0.1

  def initialize(file, client, file_exchange = nil)
    @file = file
    @client = client
    @file_exchange = file_exchange
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
      @client.speed = (@client.speed * @client.active_downloads).to_f / (@client.active_downloads - 1) if @client.active_downloads > 1
      @client.active_downloads -= 1
      @file_exchange.files.add(@file) if @file_exchange != nil
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
  end
end
class Client
  attr_accessor :username, :password, :max_speed, :speed, :ratio

  def initialize(username, password, speed)
    @username = username
    @password = password
    @max_speed = speed
    @speed = speed
    @ratio = 0
  end

  def set_speed(speed)
    raise "Download speed can't be negative" if speed < 0
    if speed > @max_speed
      @speed = @max_speed
    else
      @speed = speed
    end
  end
end
class Client
  attr_accessor :username, :password, :ratio

  def initialize(username, password)
    @username = username
    @password = password
    @ratio = 0
  end
end
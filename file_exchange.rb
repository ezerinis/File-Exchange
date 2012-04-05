require 'set'

class FileExchange
  attr_accessor :clients

  def initialize
    @clients = Set.new
  end

  def create_client(username, password)
    found = false
    @clients.each do |c|
      if c.username == username
        found = true
        next
      end
    end
    @clients.add(Client.new(username, password)) if !found
  end

  def login(username, password)
    @clients.each {|c| return c if c.username == username && c.password == password}
  end
end

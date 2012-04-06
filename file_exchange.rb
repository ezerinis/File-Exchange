require 'set'

class FileExchange
  attr_accessor :clients, :files

  def initialize
    @clients = Set.new
    @files = Set.new
  end

  def create_client(username, password)
    exists = @clients.find { |c| c.username == username }
    @clients.add(Client.new(username, password)) if !exists
  end

  def login(username, password)
    @clients.find { |c| c.username == username && c.password == password }
  end

  def create_file(name, size)
    exists = @files.find { |c| c.name == name }
    @files.add(File.new(name, size)) if !exists
  end

  def get_file_list
    list = Set.new
    files.each{ |file| list.add(file.name) }
    return list
  end
end

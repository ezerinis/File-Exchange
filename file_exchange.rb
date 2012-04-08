require "#{File.dirname(__FILE__)}/client"
require "#{File.dirname(__FILE__)}/file"
require 'set'

class FileExchange
  attr_accessor :clients, :files

  def initialize
    @clients = Set.new
    @files = Set.new
  end

  def create_client(username, password, speed)
    exists = @clients.find { |c| c.username == username }
    @clients.add(Client.new(username, password, speed)) if !exists
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
    list
  end

  def get_file(name)
    @files.find { |f| f.name == name }
  end

  def search(query)
    @files.find_all { |f| /#{query}/.match(f.name) }
  end
end
